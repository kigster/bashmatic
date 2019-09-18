#!/usr/bin/env bash
#——————————————————————————————————————————————————————————————————————————————
# © 2016-2017 Author: Konstantin Gredeskoul
# Ported from the licensed under the MIT license Project Pullulant, at
# https://github.com/kigster/pullulant
#
# Any modifications, © 2017 PioneerWorks, Inc. All rights reserved.
#——————————————————————————————————————————————————————————————————————————————

# The following "global" variables define how the run framework executes
# the commands, what it does if the commands fail, etc.
# This variable is set by each call to #run()
export LibRun__LastExitCode=${False}
export LibRun__Detail=${False}

# You can globally set these constants below to alternatives, and they will be
# used after each #run() call as the basis for the library variables that
# control the next call to #run().

export LibRun__AbortOnError__Default=${False}
export LibRun__ShowCommandOutput__Default=${False}
export LibRun__AskOnError__Default=${False}

# Maximum number of Retries that can be set via the
# LibRun__RetryCount variable before running the command.
# After running the command, RetryCount is reset to RetryCountDefault.
export LibRun__RetryCount__Default=${LibRun__RetryCount__Default:-0}
export LibRun__RetryCountMax=3

__lib::run::initializer() {
  export LibRun__AbortOnError=${LibRun__AbortOnError__Default}
  export LibRun__AskOnError=${LibRun__AskOnError__Default}
  export LibRun__ShowCommandOutput=${LibRun__ShowCommandOutput__Default}

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
__lib::run::initializer

__lib::run::env() {
  export run_stdout=/tmp/bash-run.$$.stdout
  export run_stderr=/tmp/bash-run.$$.stderr

  export commands_ignored=${commands_ignored:-0}
  export commands_failed=${commands_failed:-0}
  export commands_completed=${commands_completed:-0}
}

__lib::run::cleanup() {
  rm -f ${run_stdout}
  rm -f ${run_stderr}
}

# To print and not run, set ${LibRun__DryRun}
__lib::run() {
  local cmd="$*"
  __lib::run::env

  if [[ ${LibRun__DryRun} == ${True} ]]; then
    info "${clr}[dry run] ${bldgrn}${cmd}"
    return 0
  else
    export LibRun__LastExitCode=
    __lib::run::exec "$@"


    return ${LibRun__LastExitCode}
  fi
}

__lib::run::bundle::exec::with-output() {
  export LibRun__ShowCommandOutput=${True}
  __lib::run::bundle::exec "$@"
}

# Runs the command in the context of the "bundle exec",
# and aborts on error.
__lib::run::bundle::exec() {
  local cmd="$*"
  __lib::run::env
  local w=$(( $(__lib::output::screen-width) - 10 ))
  if [[ ${LibRun__DryRun} == ${True} ]]; then
    local line="${clr}[dry run] bundle exec ${bldgrn}${cmd}"
    info "${line:0:${w}}..."
    return 0
  else
    __lib::run::exec "bundle exec ${cmd}"
  fi
}

__lib::run::retry::enforce-max() {
  [[ -n ${LibRun__RetryCount} &&
        ${LibRun__RetryCount} -gt ${LibRun__RetryCountMax} ]] &&
    export LibRun__RetryCount="${LibRun__RetryCountMax}"
}

__lib::run::retry::only-codes() {
  export LibRun__RetryExitCodes=($@)
}

__lib::run::should-retry-exit-code() {
  local code=$1
  if [[ -n ${LibRun__RetryExitCodes[*]} ]]; then
    lib::array::contains-element "${code}" "${array[@]}"
  else
    return 0
  fi
}

__lib::run::eval() {
  local stdout=$1; shift
  local stderr=$1; shift
  local command="$*"

  if [[ ${LibRun__ShowCommandOutput} -eq ${True} ]]; then
    echo
    eval "${command}"
  else
    eval "${command}" 2>${stderr} 1>${stdout}
  fi

  export LibRun__LastExitCode=$?
}
#
# This is the workhorse of the entire BASH library.
# It basically executes a statement, while processing it's output, error output,
# and status code in a consistent way, controllable via several global variables.
# These variables are reset back to defaults after each run. The defaults hide
# both stdout and error, and do NOT abort on failure.
#
# See: #__lib::run::initializer for the list of global variables.
__lib::run::exec() {
  command="$*"

  if [[ -n ${DEBUG} && ${LibRun__Verbose} -eq ${True} ]] ; then
    lib::run::inspect
  fi

  [[ -z ${CI} ]] && w=$(( $(__lib::output::screen-width) - 15 ))
  [[ -n ${CI} ]] && w=10000

  printf "         ${clr}❯ ${bldylw}%s " "${command:0:${w}}"
  lib::output::color::on
  set +e

  local tries=0

  start=$(millis)

  __lib::run::eval "${run_stdout}" "${run_stderr}" "${command}"

  while [[
    -n ${LibRun__LastExitCode} && ${LibRun__LastExitCode} -ne 0 &&
    -n ${LibRun__RetryCount}   && ${LibRun__RetryCount}   -gt 0 ]]; do
    tries=$(( ${tries} + 1 ))

    __lib::run::retry::enforce-max

    export LibRun__RetryCount="$(( ${LibRun__RetryCount} - 1 ))"
    [[ -n ${LibRun__RetrySleep} ]] && sleep ${LibRun__RetrySleep}

    [[ ${tries} -eq 1 ]] && {
      not_ok
      echo
    }

    info "last command failed with exit code ${bldred}${LibRun__LastExitCode} " \
      "${txtblu} and ${bldylw}${LibRun__RetryCount} retries left."

    __lib::run::eval "${run_stdout}" "${run_stderr}" "${command}"
  done

  duration=$(( $(millis) - ${start}))

  if [[ ${LibRun__LastExitCode} -eq 0 ]] ; then
    ok
    duration ${duration}; echo
    commands_completed=$((${commands_completed} + 1))
  else
    not_ok
    duration ${duration}; echo
    warn " ${txtblk}${bakylw}[ exit code = ${LibRun__LastExitCode} ]${clr}"

    # Print stderr generated during command execution.
    [[ ${LibRun__ShowCommandOutput} -eq ${False} && -s ${run_stderr} ]] \
      && echo && stderr ${run_stderr}

    if [[ ${LibRun__AskOnError} == ${True} ]] ; then
      lib::run::ask 'Ignore this error and continue?'

    elif [[ ${LibRun__AbortOnError} == ${True} ]] ; then
      export commands_failed=$(($commands_failed + 1))
      error "Aborting, due to 'abort on error' being set to true."
      info "Failed command: ${bldylw}${command}"
      echo

      [[ -s ${run_stdout} ]] && {
        hr
        printf "${clr}Standard Output:${bldgrn}\n"
        cat ${run_stdout}
      }

      [[ -s ${run_stderr} ]] && {
        hr
        printf "${clr}Standard Error:${bldred}\n"
        cat ${run_stderr}
      }

      exit ${LibRun__LastExitCode}
    else
      export commands_ignored=$(($commands_ignored + 1))
    fi
  fi

  __lib::run::initializer
  __lib::run::cleanup
  printf ${clr}
  return ${LibRun__LastExitCode}
}

# This errors out if the command provided finishes successfully, but quicker than
# expected. Expected duration is the first numeric argument, command is the rest.
lib::run::with-min-duration() {
  local min_duration=$1; shift
  local command="$*"

  local started=$(millis)
  info "starting a command with the minimum duration of ${bldylw}${min_duration} seconds"
  run "${command}"
  local result=$?

  local duration=$((  ( $(millis) - ${started} ) / 1000 ))

  if [[ ${result} -eq 0 && ${duration} -lt ${min_duration} ]]; then
    local cmd="$(echo ${command} | hbsed 's/\"//g')"
    error "An operation finished too quickly. The threshold was set to ${bldylw}${min_duration} sec." \
        "The command took ${bldylw}${duration}${txtred} secs." \
        "${bldylw}${cmd}${txtred}"

    (( ${__ran_as_script} )) && exit 1 || return 1
  elif [[ ${duration} -gt ${min_duration} ]]; then
    info "minimum duration operation ran in ${duration} seconds."
  fi

  return ${result}
}

press-any-key-to-continue() {
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
lib::run::ask() {
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
    info "${bldblu}Great answer! Although, I hope you know what you are doing ..."
    hr
    echo
  else
    info "${bldylw}Good idea, who knows what would happen?"
    info "${bldred}Abort! Abandon ship!  🛳  "
    hr
    echo
    exit 1
  fi
}

export LibRun__Inspect__SkipFalseOrBlank=${False}

lib::run::inspect::set-skip-false-or-blank() {
  local value="${1}"
  [[ -n "${value}" ]] && export LibRun__Inspect__SkipFalseOrBlank=${value}
  [[ -z "${value}" ]] && export LibRun__Inspect__SkipFalseOrBlank=${True}
}

lib::run::inspect-variable() {
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
    if [[ ${lcase_var_name} =~ 'exit' ]] ; then
      if [[ ${var_value} -eq 0 ]]; then
        value=${value_check}; color="${bldgrn}"
      else
        print_value=1
        value=${var_value}
        color="${bldred}"
      fi
    elif [[ "${var_value}" == "${True}" ]] ; then
      value="${value_check}"; color="${bldgrn}"
    elif [[ "${var_value}" == "${False}" ]] ; then
      value="${value_off}" ; color="${bldred}"
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
    if [[ -n "${value}" ]] ; then
      printf "%*.*s" ${avail_len} ${avail_len} "${value}"
    elif $(lib::util::is-numeric "${var_value}"); then
      avail_len=$(( ${avail_len} - 5 ))
      if [[ "${var_value}" =~ '.' ]]; then
        printf "%*.2f" ${avail_len} "${var_value}"
      else
        printf "%*d" ${avail_len} "${var_value}"
      fi
    else
      avail_len=$(( ${avail_len} - 5 ))
      printf "%*.*s" ${avail_len} ${avail_len} "${var_value}"
    fi
  else
    printf "%*.*s" ${avail_len} ${avail_len} "${value}"
  fi
  echo
}

lib::run::print-variable() {
  lib::run::inspect-variable $1
}

lib::run::inspect-variables() {
  local title=${1}; shift
  hl::subtle "${title}"
  for var in $@; do
    lib::run::inspect-variable "${var}"
  done
}

lib::run::print-variables() {
  local title=${1}; shift
  hl::yellow "${title}"
  for var in $@; do
    lib::run::print-variable "${var}"
  done
}

lib::run::variables-starting-with() {
  local prefix="${1}"
  env | egrep "^${prefix}" | grep '=' | hbsed 's/=.*//g' | sort
}

lib::run::variables-ending-with() {
  local suffix="${1}"
  env | egrep ".*${suffix}=.*\$" | grep '=' | hbsed 's/=.*//g' | sort
}


# Usage: lib::run::inspect-variables-that-are starting-with LibRun
lib::run::inspect-variables-that-are() {
  local pattern_type="${1}" # starting-with or ending-with
  local pattern="${2}" # actual pattern
  lib::run::inspect-variables "VARIABLES $(echo ${pattern_type} | tr 'a-z' 'A-Z') ${pattern}" \
    $(lib::run::variables-${pattern_type} ${pattern} | tr '\n' ' ')
}

lib::run::inspect() {
  if [[ ${#@} -eq 0 || $(array-contains-element config "$@") == "true" ]]; then
    lib::run::inspect-variables-that-are starting-with LibRun
  fi

  if [[ ${#@} -eq 0 || $(array-contains-element "totals" "$@") == "true" ]]; then
    hl::subtle "TOTALS"
    info "${bldgrn}${commands_completed} commands completed successfully"
    [[ ${commands_failed} -gt 0 ]] && info "${bldred}${commands_failed} commands failed"
    [[ ${commands_ignored} -gt 0 ]] && info "${bldylw}${commands_ignored} commands failed, but were ignored."
    echo
  fi

  if [[ ${#@} -eq 0 || $(array-contains-element "current" "$@") == "true" ]]; then
    lib::run::inspect-variables-that-are ending-with __LastExitCode
  fi

  reset-color
}

lib::run() {
  __lib::run $@
  return ${LibRun__LastExitCode}
}

with-min-duration() {
  lib::run::with-min-duration "$@"
}

with-bundle-exec() {
  __lib::run::bundle::exec "$@"
}

with-bundle-exec-and-output() {
  __lib::run::bundle::exec::with-output "$@"
}

# These are borrowed from
# /usr/local/Homebrew/Library/Homebrew/brew.sh
onoe() {
  if [[ -t 2 ]] # check whether stderr is a tty.
  then
    echo -ne "\033[4;31mError\033[0m: " >&2 # highlight Error with underline and red color
  else
    echo -n "Error: " >&2
  fi
  if [[ $# -eq 0 ]]
  then
    /bin/cat >&2
  else
    echo "$*" >&2
  fi
}

odie() {
  onoe "$@"
  exit 1
}

safe_cd() {
  cd "$@" >/dev/null || odie "Error: failed to cd to $*!"
}

is_verbose() {
  [[ ${LibRun__Verbose} -eq ${True} ]]
}

is_detail() {
  [[ ${LibRun__Detail} -eq ${True} ]]
}

is_ask_on_error() {
  [[ ${LibRun__AskOnError} -eq ${True} ]]
}
