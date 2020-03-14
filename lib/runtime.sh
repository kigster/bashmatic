#!/usr/bin/env bash
#——————————————————————————————————————————————————————————————————————————————
# © 2016-2020 Konstantin Gredeskoul, All rights reserved. MIT License.
# Ported from the licensed under the MIT license Project Pullulant, at
# https://github.com/kigster/pullulant
#
# Any modi  fications, © 2016-2020 Konstantin Gredeskoul, All rights reserved. MIT License.
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

export LibRun__AbortOnError__Default=${False}
export LibRun__ShowCommandOutput__Default=${False}
export LibRun__AskOnError__Default=${False}
export LibRun__ShowCommand__Default=${True}

# Maximum number of Retries that can be set via the
# LibRun__RetryCount variable before running the command.
# After running the command, RetryCount is reset to RetryCountDefault.
export LibRun__RetryCount__Default=${LibRun__RetryCount__Default:-0}
export LibRun__RetryCountMax=3

.run.initializer() {
  export LibRun__AbortOnError=${LibRun__AbortOnError__Default}
  export LibRun__AskOnError=${LibRun__AskOnError__Default}
  export LibRun__ShowCommandOutput=${LibRun__ShowCommandOutput__Default}
  export LibRun__ShowCommand=${LibRun__ShowCommand__Default}
  export LibRun__RetrySleep=${LibRun__RetrySleep:-"0.1"} # sleep between failed retries
  export LibRun__RetryCount="${LibRun__RetryCount__Default}"

  declare -a LibRun__RetryExitCodes
  export LibRun__RetryExitCodes=()
}

export LibRun__DryRun=${False}
export LibRun__Verbose=${False}

export commands_ignored=0
export commands_failed=0
export commands_completed=0

# Run it while the library is loading.
.run.initializer

.run.env() {
  export run_stdout=/tmp/bash-run.$$.stdout
  export run_stderr=/tmp/bash-run.$$.stderr

  export commands_ignored=${commands_ignored:-0}
  export commands_failed=${commands_failed:-0}
  export commands_completed=${commands_completed:-0}
}

.run.cleanup() {
  rm -f ${run_stdout}
  rm -f ${run_stderr}
}

# To print and not run, set ${LibRun__DryRun}
.run() {
  local cmd="$*"
  export LibRun__CommandLength=0
  .run.env

  if [[ ${LibRun__DryRun} -eq ${True} ]]; then
    info "${clr}[dry run] ${bldgrn}${cmd}"
    return 0
  else
    export LibRun__LastExitCode=
    .run.exec "$@"

    return ${LibRun__LastExitCode}
  fi
}

.run.bundle.exec.with-output() {
  export LibRun__ShowCommandOutput=${True}
  .run.bundle.exec "$@"
}

# Runs the command in the context of the "bundle exec",
# and aborts on error.
.run.bundle.exec() {
  local cmd="$*"
  .run.env
  local w=$(($(.output.screen-width) - 10))
  if [[ ${LibRun__DryRun} -eq ${True} ]]; then
    local line="${clr}[dry run] bundle exec ${bldgrn}${cmd}"
    info "${line:0:${w}}..."
    return 0
  else
    .run.exec "bundle exec ${cmd}"
  fi
}

.run.retry.enforce-max() {
  [[ -n ${LibRun__RetryCount} && ${LibRun__RetryCount} -gt ${LibRun__RetryCountMax} ]] &&
    export LibRun__RetryCount="${LibRun__RetryCountMax}"
}

.run.retry.only-codes() {
  export LibRun__RetryExitCodes=("$@")
}

.run.should-retry-exit-code() {
  local code=$1
  if [[ -n ${LibRun__RetryExitCodes[*]} ]]; then
    array.includes "${code}" "${array[@]}"
  else
    return 0
  fi
}

.run.eval() {
  local stdout="$1"
  shift
  local stderr="$1"
  shift
  local command="$*"

  if [[ ${LibRun__ShowCommandOutput} -eq ${True} ]]; then
    printf "${clr}\n"
    eval "${command}"
    export LibRun__LastExitCode=$?
  else
    eval "${command}" 2>${stderr} 1>${stdout}
    export LibRun__LastExitCode=$?
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
.run.exec() {
  command="$*"

  if [[ -n ${DEBUG} && ${LibRun__Verbose} -eq ${True} ]]; then
    run.inspect
  fi

  local max_width=100
  local w
  w=$(($(.output.screen-width) - 10))

  [[ ${w} -gt ${max_width} ]] && w=${max_width}

  export LibRun__AssignedWidth=${w}

  local prefix="${LibOutput__LeftPrefix}${clr}"
  local ascii_cmd
  local command_prompt="${prefix}❯ "
  local command_width=$((w - 30))

  # record length of the command
  ascii_cmd="$(printf "${command_prompt}%-.${command_width}s " "${command:0:${command_width}}")"

  # if printing command output don't show dots leading to duration
  export LibRun__CommandLength=${#ascii_cmd}

  [[ ${LibRun__ShowCommandOutput} -eq ${True} ]] && {
    export LibRun__AssignedWidth=$((w - 3))
    export LibRun__CommandLength=1
    printf "${prefix}${txtblk}# Command below will be shown with its output:${clr}\n"
  }

  if [[ "${LibRun__ShowCommand}" -eq ${False} ]]; then
    printf "${prefix}❯ ${bldylw}%-.${command_width}s " "$(.output.replicate-to "*" 40)"
  else
    printf "${prefix}❯ ${bldylw}%-.${command_width}s " "${command:0:${command_width}}"
  fi

  sleep 1

  local __Previous__ShowCommandOutput=${LibRun__ShowCommandOutput}
  set +e
  start=$(millis)

  local tries=1

  .run.eval "${run_stdout}" "${run_stderr}" "${command}"

  while [[ -n ${LibRun__LastExitCode} && ${LibRun__LastExitCode} -ne 0 ]] &&
    [[ -n ${LibRun__RetryCount} && ${LibRun__RetryCount} -gt 0 ]]; do

    [[ ${tries} -gt 1 && ${__Previous__ShowCommandOutput} -eq ${True} ]] && {
      export LibRun__ShowCommandOutput=${False}
    }
    .run.retry.enforce-max

    export LibRun__RetryCount="$((LibRun__RetryCount - 1))"
    [[ -n ${LibRun__RetrySleep} ]] && sleep ${LibRun__RetrySleep}

    info "Warning: command exited with code ${bldred}${LibRun__LastExitCode}" \
      "$(txt-info)and ${LibRun__RetryCount} retries left."

    .run.eval "${run_stdout}" "${run_stderr}" "${command}"

    tries=$((tries + 1))
  done

  duration=$(($(millis) - start))

  export LibRun__ShowCommandOutput=${__Previous__ShowCommandOutput}

  [[ ${LibRun__ShowCommandOutput} -eq ${True} ]] && { echo; }

  if [[ ${LibRun__LastExitCode} -eq 0 ]]; then
    if [[ ${LibRun__ShowCommand} -eq ${True} ]]; then
      command-spacer
      duration ${duration} ${LibRun__LastExitCode}
    fi
    ok
    commands_completed=$((commands_completed + 1))
    echo
  else
    if [[ ${LibRun__ShowCommand} -eq ${True} ]]; then
      command-spacer
      duration ${duration} ${LibRun__LastExitCode}
    fi
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
run.with.minimum-duration() {
  local min_duration=$1
  shift
  local command="$*"

  local started=$(millis)
  info "starting a command with the minimum duration of ${bldylw}${min_duration} seconds"
  run "${command}"
  local result=$?

  local duration=$((($(millis) - ${started}) / 1000))

  if [[ ${result} -eq 0 && ${duration} -lt ${min_duration} ]]; then
    local cmd="$(echo ${command} | sedx 's/\"//g')"
    error "An operation finished too quickly. The threshold was set to ${bldylw}${min_duration} sec." \
      "The command took ${bldylw}${duration}${txtred} secs." \
      "${bldylw}${cmd}${txtred}"

    ((${BASH_IN_SUBSHELL})) && exit 1 || return 1
  elif [[ ${duration} -gt ${min_duration} ]]; then
    info "minimum duration operation ran in ${duration} seconds."
  fi

  return ${result}
}

run.ui.press-any-key() {
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

# Ask the user if they want to proceed, defaulting to Yes.
# Choosing no exits the program. The arguments are printed as a question.
run.ui.ask() {
  local question=$*
  echo
  inf "${bldcyn}${question}${clr} [Y/n] ${bldylw}"

  read a 2>/dev/null
  code=$?
  if [[ ${code} != 0 ]]; then
    error "Unable to read from STDIN."
    exit 12
  fi
  echo
  if [[ ${a} == 'y' || ${a} == 'Y' || ${a} == '' ]]; then
    info "${bldblu}Roger that."
    info "Let's just hope it won't go nuclear on us :) 💥"
    hr
    echo
  else
    info "${bldred}(Great idea!) Abort! Abandon ship!  🛳  "
    hr
    echo
    exit 1
  fi
}

export LibRun__Inspect__SkipFalseOrBlank=${False}

run.inspect.set-skip-false-or-blank() {
  local value="${1}"
  [[ -n "${value}" ]] && export LibRun__Inspect__SkipFalseOrBlank=${value}
  [[ -z "${value}" ]] && export LibRun__Inspect__SkipFalseOrBlank=${True}
}

run.inspect-variable() {
  local var_name=${1}
  local var_value=${!var_name}
  local value=""

  local print_value=
  local max_len=120
  local avail_len=$(($(screen.width) - 45))
  local lcase_var_name="$(echo ${var_name} | tr 'A-Z' 'a-z')"

  local print_value=1
  local color="${bldblu}"

  local value_off=" ✘   "
  local value_check="✔︎"

  if [[ -n "${var_value}" ]]; then
    if [[ ${lcase_var_name} =~ 'exit' ]]; then
      if [[ ${var_value} -eq 0 ]]; then
        value=${value_check}
        color="${bldgrn}"
      else
        print_value=1
        value=${var_value}
        color="${bldred}"
      fi
    elif [[ "${var_value}" == "${True}" ]]; then
      value="${value_check}"
      color="${bldgrn}"
    elif [[ "${var_value}" == "${False}" ]]; then
      value="${value_off}"
      color="${bldred}"
    fi
  else
    value="${value_off}"
    color="${bldred}"
  fi

  if [[ ${LibRun__Inspect__SkipFalseOrBlank} -eq ${True} && "${value}" == "${value_off}" ]]; then
    return 0
  fi

  printf "    ${bldylw}%-35s ${txtblk}${color} " ${var_name}
  [[ ${avail_len} -gt ${max_len} ]] && avail_len=${max_len}

  if [[ "${print_value}" -eq 1 ]]; then
    if [[ -n "${value}" ]]; then
      printf "%*.*s" ${avail_len} ${avail_len} "${value}"
    elif $(util.is-numeric "${var_value}"); then
      avail_len=$((${avail_len} - 5))
      if [[ "${var_value}" =~ '.' ]]; then
        printf "%*.2f" ${avail_len} "${var_value}"
      else
        printf "%*d" ${avail_len} "${var_value}"
      fi
    else
      avail_len=$((${avail_len} - 5))
      printf "%*.*s" ${avail_len} ${avail_len} "${var_value}"
    fi
  else
    printf "%*.*s" ${avail_len} ${avail_len} "${value}"
  fi
  echo
}

run.print-variable() {
  run.inspect-variable $1
}

run.inspect-variables() {
  local title=${1}
  shift
  hl.subtle "${title}"
  for var in $@; do
    run.inspect-variable "${var}"
  done
}

run.print-variables() {
  local title=${1}
  shift
  hl.yellow "${title}"
  for var in $@; do
    run.print-variable "${var}"
  done
}

run.variables-starting-with() {
  local prefix="${1}"
  env | egrep "^${prefix}" | grep '=' | sedx 's/=.*//g' | sort
}

run.variables-ending-with() {
  local suffix="${1}"
  env | egrep ".*${suffix}=.*\$" | grep '=' | sedx 's/=.*//g' | sort
}

# Usage: run.inspect-variables-that-are starting-with LibRun
run.inspect-variables-that-are() {
  local pattern_type="${1}" # starting-with or ending-with
  local pattern="${2}"      # actual pattern
  run.inspect-variables "VARIABLES $(echo ${pattern_type} | tr 'a-z' 'A-Z') ${pattern}" \
    "$(run.variables-${pattern_type} ${pattern} | tr '\n' ' ')"
}

# shellcheck disable=SC2120
run.inspect() {
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

run.with.ruby-bundle() {
  .run.bundle.exec "$@"
}

run.with.ruby-bundle-and-output() {
  .run.bundle.exec.with-output "$@"
}

run.config.verbose-is-enabled() {
  [[ ${LibRun__Verbose} -eq ${True} ]]
}

run.config.detail-is-enabled() {
  [[ ${LibRun__Detail} -eq ${True} ]]
}

run.on-error.ask-is-enabled() {
  [[ ${LibRun__AskOnError} -eq ${True} ]]
}
