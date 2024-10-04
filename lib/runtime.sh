#!/usr/bin/env bash
#——————————————————————————————————————————————————————————————————————————————
# © 2016-2024 Konstantin Gredeskoul, All rights reserved. MIT License.
# Ported from the licensed under the MIT license Project Pullulant, at
# https://github.com/kigster/pullulant
#
# Any modifications, © 2016-2024 Konstantin Gredeskoul, All rights reserved. MIT License.
#——————————————————————————————————————————————————————————————————————————————

# The following "global" variables define how the run framework executes
# the commands, what it does if the commands fail, etc.
# This variable is set by each call to #run()
export LibRun__LastExitCode=${False}
export LibRun__Detail=${False}
export LibRun__CommandLength=0
# You can globally set these constants below to alternatives, and they will be
# used after each #run() call as the basis for the library variables that
# control the next call to #run().

export LibRun__Inspect__SkipFalseOrBlank=${False}

export LibRun__AbortOnError__Default=${False}
export LibRun__ShowCommandOutput__Default=${False}
export LibRun__AskOnError__Default=${False}
export LibRun__ShowCommand__Default=${True}

export LibRun__CommandColorBg__Default="${bakgrn}"
export LibRun__CommandColorFg__Default="${txtblk}"
export LibRun__CommandColor__Default="${LibRun__CommandColorFg__Default}${LibRun__CommandColorBg__Default}"

# Maximum number of Retries that can be set via the
# LibRun__RetryCount variable before running the command.
# After running the command, RetryCount is reset to RetryCountDefault.
export LibRun__RetryCount__Default=${LibRun__RetryCount__Default:-0}
export LibRun__RetryCountMax=3

function .run.initializer() {
  export LibRun__AbortOnError=${LibRun__AbortOnError__Default}
  export LibRun__AskOnError=${LibRun__AskOnError__Default}
  export LibRun__ShowCommandOutput=${LibRun__ShowCommandOutput__Default}
  export LibRun__ShowCommand=${LibRun__ShowCommand__Default}
  export LibRun__RetrySleep=${LibRun__RetrySleep:-"0.1"} # sleep between failed retries
  export LibRun__RetryCount="${LibRun__RetryCount__Default}"
  export LibRun__CommandColor="${LibRun__CommandColor__Default}"
  export LibRun__PromptColor="${bldwht}${LibRun__CommandColorBg__Default}"

  declare -a LibRun__RetryExitCodes
  export LibRun__RetryExitCodes=()
}

trap "kill $$" INT

export SENSITIVE_VARS_REGEX="(password|api_key|token)"

export LibRun__DryRun=${False}
export LibRun__Verbose=${False}

export commands_ignored=0
export commands_failed=0
export commands_completed=0

# Run it while the library is loading.
.run.initializer

function .run.env() {
  export run_stdout=/tmp/bash-run.$$.stdout
  export run_stderr=/tmp/bash-run.$$.stderr

  export commands_ignored=${commands_ignored:-0}
  export commands_failed=${commands_failed:-0}
  export commands_completed=${commands_completed:-0}
}

function .run.cleanup() {
  rm -f ${run_stdout}
  rm -f ${run_stderr}
}

# To print and not run, set ${LibRun__DryRun}
.run() {
  local cmd="$*"
  export LibRun__CommandLength=0
  .run.env

  if [[ ${LibRun__DryRun} -eq ${True} ]]; then
    info "${clr}$(run.dry-run-prefix) ${bldgrn}${cmd}"
    return 0
  else
    export LibRun__LastExitCode=
    .run.exec "$@"

    return "${LibRun__LastExitCode}"
  fi
}

function .run.bundle.exec.with-output() {
  export LibRun__ShowCommandOutput="${True}"
  .run.bundle.exec "$@"
}

# Runs the command in the context of the "bundle exec",
# and aborts on error.
function .run.bundle.exec() {
  local cmd="$*"
  .run.env
  local w=$(($(.output.screen-width) - 10))
  if [[ ${LibRun__DryRun} -eq ${True} ]]; then
    local line="${clr}$(run.dry-run-prefix) bundle exec ${bldgrn}${cmd}"
    info "${line:0:${w}}..."
    return 0
  else
    .run.exec "bundle exec ${cmd}"
  fi
}

function .run.retry.enforce-max() {
  [[ -n ${LibRun__RetryCount} && ${LibRun__RetryCount} -gt ${LibRun__RetryCountMax} ]] &&
    export LibRun__RetryCount="${LibRun__RetryCountMax}"
}

function .run.retry.only-codes() {
  export LibRun__RetryExitCodes=("$@")
}

function .run.should-retry-exit-code() {
  local code=$1
  if [[ -n ${LibRun__RetryExitCodes[*]} ]]; then
    array.includes "${code}" "${array[@]}"
  else
    return 0
  fi
}

function .run.eval() {
  local stdout="$1"
  shift
  local stderr="$1"
  shift
  local command="$*"

  if [[ ${LibRun__ShowCommandOutput} -eq ${True} ]]; then
    echo
    cursor.at.x 0
    hr
    cursor.at.x 7
    printf "${LibRun__PromptColor} ❯  ${LibRun__CommandColor}${command} ${clr}"
    cursor.down 2
    printf "\n${txtcyn}\n"
    eval "${command}"
    export LibRun__LastExitCode=$?
    echo
    run.print-command "${command}"
  else
    run.print-command "${command}"
    eval "${command}" 2>"${stderr}" 1>"${stdout}"
    export LibRun__LastExitCode=$?
  fi
}

function run.dry-run-prefix() {
  if [[ ${LibRun__DryRun} == ${True} ]]; then
    printf "${txtcyn}${italic}« dry run »${clr} "
  fi
}

function run.print-command() {
  local command="$1"
  local max_width=${2:-"150"}
  local min_width=60
  local w
  w=$(($(screen-width) - 10))

  [[ ${w} -gt ${max_width} ]] && w=${max_width}

  export LibRun__AssignedWidth=${w}

  local prefix="${LibOutput__LeftPrefix}${clr}"
  local ascii_cmd
  local command_prompt="${prefix} ❯ "
  local command_width=$((w - 25))

  [[ ${command_width} -lt ${min_width} ]] && command_width=${min_width}

  # record length of the command
  ascii_cmd="$(printf "${command_prompt}$(run.dry-run-prefix)%-.${command_width}s " "${command:0:${command_width}}")"

  # if printing command output don't show dots leading to duration
  export LibRun__CommandLength=${#ascii_cmd}

  if [[ "${LibRun__ShowCommand}" -eq ${False} ]]; then
    printf -- "${prefix}${LibRun__PromptColor} ❯ ${LibRun__CommandColor} %-.${command_width}s " "$(.output.replicate-to "■" ${command_width})"
  else
    printf -- "${prefix}${LibRun__PromptColor} ❯ ${LibRun__CommandColor} %-.${command_width}s " "${command:0:${command_width}}"
  fi
}

function run.print-command-full-screen() {
  run.print-long-command "$1" "$(screen.width)"
}

function command-spacer() {
  local color="${LibRun__CommandColor}"
  [[ ${LibRun__LastExitCode} -ne 0 ]] && color="${txtred}"

  [[ -z ${LibRun__AssignedWidth} || -z ${LibRun__CommandLength} ]] && return

  printf "%s${color}" ""

  # shellcheck disable=SC2154
  local __width=$((LibRun__AssignedWidth - LibRun__CommandLength - 10))
  # shellcheck disable=SC2154

  [[ ${__width} -gt 0 ]] && .output.replicate-to "${LibRun__CommandColor} " "${__width}"
  printf "${clr}"
}

function run.print-long-command() {
  local command="$1"
  local max_width=${2:-"150"}
  local w
  w=$(($(.output.screen-width) - 10))
  [[ ${w} -gt ${max_width} ]] && w=${max_width}

  export LibRun__AssignedWidth=${w}

  local prefix="${LibRun__PromptColor}${LibOutput__LeftPrefix}${clr}"
  local ascii_cmd
  local command_prompt="${prefix}❯ $(run.dry-run-prefix)"
  local command_width=$((w - 10))

  printf "${prefix}❯ ${bldylw}"
  printf "${command}" | fold -s -w"${w}" |
    awk 'NR > 1 {printf "            "}; { printf "%s\n", $0}'
}

function run.post-command-with-output() {
  local duration="$1"
  if [[ ${LibRun__ShowCommand} -eq ${True} ]]; then
    command-spacer
    duration "${duration}" ${LibRun__LastExitCode}
  fi
}

#
# This is the workhorse of the entire BASH library.
# It basically executes a statement, while processing it's output, error output,
# and status code in a consistent way, controllable via several global variables.
# These variables are reset back to defaults after each run. The defaults hide
# both stdout and error, and do NOT abort on failure.
#
# See: #.run.initializer for the list of global variables.
function .run.exec() {
  local command="$*"

  if ((INSPECT)) || [[ -n ${BASHMATIC_DEBUG} && ${LibRun__Verbose} -eq ${True} ]]; then
    run.inspect
  fi

  local __Previous__ShowCommandOutput=${LibRun__ShowCommandOutput}
  set +e
  local ts_start
  ts_start=$(millis)

  local tries=1

  .run.eval "${run_stdout}" "${run_stderr}" "${command}"

  while [[ -n ${LibRun__LastExitCode} && ${LibRun__LastExitCode} -ne 0 ]] &&
    [[ -n ${LibRun__RetryCount} && ${LibRun__RetryCount} -gt 0 ]]; do

    [[ ${tries} -gt 1 && ${__Previous__ShowCommandOutput} -eq ${True} ]] &&
      export LibRun__ShowCommandOutput=${False}

    .run.retry.enforce-max

    export LibRun__RetryCount="$((LibRun__RetryCount - 1))"
    [[ -n ${LibRun__RetrySleep} ]] && sleep "${LibRun__RetrySleep}"

    info "warning: command exited with code ${bldred}${LibRun__LastExitCode}" \
      "$(txt-info)and ${LibRun__RetryCount} retries left."

    .run.eval "${run_stdout}" "${run_stderr}" "${command}"

    tries=$((tries + 1))
  done

  local ts_end=$(millis)
  local duration=$(ruby -e "puts ${ts_end} - ${ts_start}")

  export LibRun__ShowCommandOutput=${__Previous__ShowCommandOutput}

  if [[ ${LibRun__LastExitCode} -eq 0 ]]; then
    run.post-command-with-output "${duration}"
    ui.closer.ok
    commands_completed=$((commands_completed + 1))
    echo
  else
    run.post-command-with-output "${duration}"
    ui.closer.not-ok
    echo
    local stderr_printed=false
    # Print stderr generated during command execution.
    [[ ${LibRun__ShowCommandOutput} -eq ${False} && -s ${run_stderr} ]] && {
      stderr_printed=true
      echo && stderr ${run_stderr}
    }

    if [[ ${LibRun__AskOnError} -eq ${True} ]]; then
      run.ui.ask 'Ignore this error and continue?'

    elif [[ ${LibRun__AbortOnError} -eq ${True} ]]; then
      export commands_failed=$((commands_failed + 1))
      error "Aborting, due to 'abort on error' being set to true."
      info "Failed command: ${bldylw}${command}"
      echo

      [[ -s ${run_stdout} ]] && {
        echo && stdout ${run_stdout}
      }

      ${stderr_printed} || [[ -s ${run_stderr} ]] && {
        echo && stderr ${run_stderr}
      }

      printf "${clr}\n"
      exit ${LibRun__LastExitCode}
    else
      export commands_ignored=$((commands_ignored + 1))
    fi
  fi

  .run.initializer
  .run.cleanup

  printf "${clr}"
  return ${LibRun__LastExitCode}
}

# This errors out if the command provided finishes successfully, but quicker than
# expected. Expected duration is the first numeric argument, command is the rest.
function run.with.minimum-duration() {
  local min_duration=$1
  shift
  local command="$*"

  local started=$(millis)
  info "starting a command with the minimum duration of ${bldylw}${min_duration} seconds"
  run "${command}"
  local result=$?

  local now=$(millis)
  # shellcheck disable=SC2079
  local duration=$(ruby -e "puts (${now} - ${started})/1000.0")

  if [[ ${result} -eq 0 && ${duration} -lt ${min_duration} ]]; then
    local cmd="$(echo "${command}" | sedx 's/\"//g')"
    error "An operation finished too quickly. The threshold was set to ${bldylw}${min_duration} sec." \
      "The command took ${bldylw}${duration}${txtred} secs." \
      "${bldylw}${cmd}${txtred}"

    ((BASH_IN_SUBSHELL)) && exit 1 || return 1
  elif [[ ${duration} -gt ${min_duration} ]]; then
    info "minimum duration operation ran in ${duration} seconds."
  fi

  return ${result}
}

function run.ui.press-any-key() {
  local prompt="$*"
  [[ -z ${prompt} ]] && prompt="Press any key to continue..."
  br
  printf "    ${txtgrn}${italic}${prompt} ${clr}  "
  read -r -s -n1 key
  cursor.rewind
  printf "                                                           "
  cursor.up 2
  cursor.rewind
  echo
}

function run.inspect.set-skip-false-or-blank() {
  local value="${1}"
  [[ -n "${value}" ]] && export LibRun__Inspect__SkipFalseOrBlank=${value}
  [[ -z "${value}" ]] && export LibRun__Inspect__SkipFalseOrBlank=${True}
}

function run.add-obfuscated-var() {
  while true; do
    local variable="$1"
    shift
    [[ -n ${variable} ]] || break
    export OBFUSCATED_VARIABLES+=("${variable}")
  done
  export OBFUSCATED_VARIABLES=($(array.uniq "${OBFUSCATED_VARIABLES[@]}"))
}

function run.obfuscate-string-value() {
  local value="$1"
  local len="30"
  local sha=$(echo "${value}" | sha512sum | cut -d ' ' -f 1)

  printf "%s" "${sha:0:${len}}"
}

function run.print-obfuscated-vars() {
  for var in "${OBFUSCATED_VARIABLES[@]}"; do
    run.inspect-variable "${var}"
  done
}

function var.is-truthy() {
  local value="${1}"
  [[ "${value}" == "${True}" || "${value}" == "1" || ${value} == "true" ]]
}

function var.is-falsy() {
  local value="${1}"
  [[ -z "${value}" || "${value}" == "${False}" || "${value}" == "0" || ${value} == "false" ]]
}

function run.inspect-variable() {
  local var_name=${1}
  local var_value=${!var_name}
  local value=""

  local print_value
  local obfuscated_value
  local max_len=100
  local avail_len=$(($(screen.width.actual) - 45))
  local lcase_var_name="$(echo "${var_name}" | tr '[:upper:]' '[:lower:]')"

  print_value=1

  local print_value

  array.includes "${var_name}" "${OBFUSCATED_VARIABLES[@]}" && obfuscated_value=$(run.obfuscate-string-value "${var_name}")
  array.includes "${lcase_var_name}" "${OBFUSCATED_VARIABLES[@]}" && obfuscated_value=$(run.obfuscate-string-value "${lcase_var_name}")

  local color="${txtblk}${bakpur}"

  local value_off=" ✘ "
  local value_check=" ✔︎  "
  local value_color=""

  [[ -n ${obfuscated_value} ]] && {
    obfuscated_value="<obfuscated-value-${obfuscated_value}>"
    value_color="${italic}${txtred}"
  }

  if [[ -n "${var_value}" ]]; then
    if [[ ${var_name} =~ ${SENSITIVE_VARS_REGEX} || ${var_name} =~ ${SENSITIVE_VARS_REGEX^^} ]]; then
      var_value="$(run.obfuscate-string-value ${var_name}) [obfuscated]"
      color="${itawht}${italic}${bakcyn}"
    elif [[ ${lcase_var_name} =~ 'exit' ]]; then
      if [[ ${var_value} -eq 0 ]]; then
        var_value="${value_check} [zero]"
        color="${bakgrn}"
      else
        print_value=1
        var_value=${var_value}
        color="${bakred}"
        avail_len=$((avail_len + 5))
      fi
      avail_len=$((avail_len + 5))
    elif var.is-truthy "${var_value}"; then
      var_value="${value_check} [true]"
      color="${bakgrn}"
      avail_len=$((avail_len + 5))
    elif var.is-falsy "${var_value}"; then
      var_value="${value_off} [false]"
      color="${bakred}"
      avail_len=$((avail_len + 2))
    fi
  else
    var_value=" ─  [empty]"
    color="${bakpur}"
    avail_len=$((avail_len + 2))
  fi

  #  if [[ ${LibRun__Inspect__SkipFalseOrBlank} -eq ${True} && "${value}" == "${value_off}" ]]; then
  #    return 0
  #  fi

  printf -- "  ❯${txtylw} %-40s ${txtblk}${color} " "${var_name}"

  [[ ${avail_len} -gt ${max_len} ]] && avail_len=${max_len}

  # Counts the number of dots present in the numeric argument
  local dot_count="$(echo "${var_value}" | sedx -E 's/[^.]//g' | tr -d '\n' | wc -c)"

  if [[ "${print_value}" -eq 1 ]]; then
    if [[ -n ${obfuscated_value} ]]; then
      print_value="${obfuscated_value}"
      var_value="${obfuscated_value}"
      value="${obfuscated_value}"
    fi

    if [[ -n "${value}" ]] && ! is.numeric "${var_value}"; then
      # printf -- "${value_color}%-*.*s" ${avail_len} ${avail_len} "${var_value}"
      echo "XXX"
    elif is.numeric "${var_value}"; then
      avail_len=$((avail_len))
      if [[ ${dot_count} -gt 1 || ${dot_count} -gt 1 ]]; then
       echo "XXX"
       printf -- "${value_color}[%-*.*s]" "${avail_len}" "${avail_len}" "${var_value}"
      else
        if [[ "${var_value}" =~ \. ]]; then
          printf -- "${value_color}%-*.2f" "$((avail_len))" "${var_value}"
        else
          printf -- "${value_color}%-*d" "$((avail_len))" "${var_value}"
        fi
      fi
    else
      printf -- "${value_color}%-*.*s" "${avail_len}" "${avail_len}" "${var_value}"
    fi
  else
    avail_len=$((avail_len))
    printf -- "${value_color}%-*.*s" "${avail_len}" "${avail_len}" "${var_value}"
  fi
  printf "${clr}\n"
}

function run.print-variable() {
  run.inspect-variable "$1"
}

function run.inspect-variables() {
  local title=${1}
  shift
  output.constrain-screen-width 100
  h3bg "${title}"
  # trunk-ignore(shellcheck/SC2068)
  # shellcheck disable=SC2068
  for var in $@; do
    run.inspect-variable "${var}"
  done
}

# @description Adds a variable to the list of the variables to be obfuscated
function run.print-variables() {
  local title="${1}"
  shift
  hl.yellow "${title}"
  # trunk-ignore(shellcheck/SC2068)
  # shellcheck disable=SC2068
  for var in $@; do
    run.print-variable "${var}"
  done
}

function run.register-obfuscated-vars() {
  run.add-obfuscated-var password api_key secret token
}

# shellcheck disable=SC2120
function run.filter-out-sensitive-vars() {
  local a="${1:-""}"
  if [[ "$a" == "-" ]]; then
    read -r a
  elif [[ -f "${a}" ]]; then
    grep -v -E "${SENSITIVE_VARS_REGEX}" "${a}"
  else
    echo | grep -v -E "${SENSITIVE_VARS_REGEX}"
  fi
}

function run.variables-starting-with() {
  local prefix="${1}"
  env | \
    grep -E -e "^${prefix}" | \
    grep '=' | \
    sedx 's/=.*//g' | \
    grep -v -E "${SENSITIVE_VARS_REGEX}" | \
    sort
}

function run.variables-ending-with() {
  local suffix="${1}"
  env | \
    grep -E -e ".*${suffix}=.*\$" | \
    grep -v -E "${SENSITIVE_VARS_REGEX}" | \
    grep '=' | \
    sedx 's/=.*//g' | \
    sort
}

# Usage: run.inspect-variables-that-are starting-with LibRun
function run.inspect-variables-that-are() {
  local pattern_type="${1}" # starting-with or ending-with
  local pattern="${2}"      # actual pattern
  run.inspect-variables \
    "VARIABLES $(echo "${pattern_type}" | tr '[:lower:]' '[:upper:]') ${pattern}" \
    "$(run.variables-"${pattern_type}" "${pattern}" | tr '\n' ' ')"
}

# @description Prints values of all variables starting with prefixes in args
# @example Print all bashmatic variables:
#
#     run.inspect-vars BAxSHMATIC_
#
function run.inspect-vars() {
  for var in "$@"; do
    run.inspect-variables-that-are starting-with "$var"
  done
}

# shellcheck disable=SC2120
function run.inspect() {
  if [[ ${#@} -eq 0 || $(array.has-element "config" "$@") == "true" ]]; then
    run.inspect-variables-that-are starting-with LibRun
  fi

  if [[ ${#@} -eq 0 || $(array.has-element "totals" "$@") == "true" ]]; then
    hl.subtle "TOTALS"
    info "${bldgrn}${commands_completed} commands completed successfully"
    [[ ${commands_failed} -gt 0 ]] && info "${bldred}${commands_failed} commands failed"
    [[ ${commands_ignored} -gt 0 ]] && info "${bldylw}${commands_ignored} commands failed, but were ignored."
    echo
  fi

  if [[ ${#@} -eq 0 || $(array.has-element "current" "$@") == "true" ]]; then
    run.inspect-variables-that-are ending-with __LastExitCode
  fi

  reset-color
}

run() {
  .run "$@"
  return ${LibRun__LastExitCode}
}

function run.with.ruby-bundle() {
  .run.bundle.exec "$@"
}

function run.with.ruby-bundle-and-output() {
  .run.bundle.exec.with-output "$@"
}

function run.config.is-dry-run() {
  [[ ${LibRun__DryRun} -eq ${True} ]]
}

function run.config.verbose-is-enabled() {
  [[ ${LibRun__Verbose} -eq ${True} ]]
}

function run.config.detail-is-enabled() {
  [[ ${LibRun__Detail} -eq ${True} ]]
}

function run.on-error.ask-is-enabled() {
  [[ ${LibRun__AskOnError} -eq ${True} ]]
}

function run.was-successful() {
  [[ ${LibRun__LastExitCode} -eq 0 ]]
}
