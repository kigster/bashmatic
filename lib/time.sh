#!/usr/bin/env bash
# vim: set ft=bash
#——————————————————————————————————————————————————————————————————————————————
# © 2016-2024 Konstantin Gredeskoul, All rights reserved. MIT License.
# Ported from the licensed under the MIT license Project Pullulant, at
# https://github.com/kigster/pullulant
#
# Any modifications, © 2016-2024 Konstantin Gredeskoul, All rights reserved. MIT License.
#——————————————————————————————————————————————————————————————————————————————

# Install necessary dependencies on OSX
.time.osx.coreutils() {
  # install gdate quietly
  brew install coreutils 2>&1 | cat >/dev/null
  code=$?
  if [[ ${code} != 0 || -z $(which gdate) ]]; then
    error "Can not install coreutils brew package, exit code ${code}"
    printf "Please run ${bldylw}brew install coreutils${clr} to install gdate utility."
    exit ${code}
  fi
}

# milliseconds
.run.millis() {
  util.os
  local date_runnable
  date_runnable='date'
  if [[ "${BASHMATIC_OS}" == "darwin" ]]; then
    command -v gdate >/dev/null || .time.osx.coreutils
    [[ -z $(command -v gdate) ]] && .time.osx.coreutils
    [[ -n $(command -v gdate) ]] && date_runnable='gdate'
    date_runnable=$(command -v gdate || command -v date)
  fi
  eval "${date_runnable} '+%s%3N'"
}

# milliseconds
function time.now.with-ms() {
  util.os
  local date_runnable
  date_runnable='date'
  if [[ "${BASHMATIC_OS}" == "darwin" ]]; then
    [[ -z $(command -v gdate) ]] && .time.osx.coreutils
    [[ -n $(command -v gdate) ]] && date_runnable='gdate'
  fi
  ${date_runnable} '+%T.%3N'
}

# @description Prints the complete date with time up to milliseconds
# @example
#      2022-05-03 14:29:52.302
function date.now.with-time() {
  date '+%F ' | tr -d '\n'
  time.now.with-ms
}

function date.now.with-time.and.zone() {
  (
    date '+%F '
    time.now.with-ms
    date '+ %z'
  ) | tr -d '\n';
}

# @description Starts a time for a given name space
# @example
#       time.with-duration.start moofie
#       # ... time passes
#       time.with-duration.end   moofie 'Moofie is now this old: '
#       # ... time passes
#       time.with-duration.end   moofie 'Moofie is now very old: '
#       time.with-duration.clear moofie
function time.with-duration.start() {
  local name="$1"
  if [[ -z ${name} ]]; then
    name="_default"
  else
    name="${name/ /_}"
  fi
  eval "export __bashmatic_with_duration_ms${name}=$(millis)"
}

function time.with-duration.end() {
  local name="$1"
  shift
  if [[ -z ${name} ]]; then
    name="_default"
  else
    name="${name/ /_}"
  fi
  local var="__bashmatic_with_duration_ms${name}"
  local started=$(.subst ${var})
  [[ -z ${started} ]] && started=${!var}
  [[ -z ${started} ]] && {
    error "No start time recorded for namespace ${name}."
    return 1
  }
  local finished="$(millis)"
  local duration=$((finished - started))

  duration="$(time.duration.millis-to-secs "${duration}")"
  printf -- "$* %s\n" "${duration} sec"
}

function time.with-duration.clear() {
  local name="$1"
  eval "unset __bashmatic_with_duration_ms${name}"
}

# @description Runs the given command and prints the time it took
# @arg1 [quiet] to silence command output
# @arg2 [verbose] to print the command before running the
# @arg3 [secret] do not print the command before running it (in case sensitive)
# @example
#      time.with-duration quiet "{ sleep 1; ls -al; sleep 2; date; sleep 1; }"
#      time.with-duration quiet verbose "{ sleep 1; ls -al; sleep 2; date; sleep 1; }"
function time.with-duration() {
  local quiet=false
  local verbose=false
  local secret=false

  [[ "$1" == quiet ]] && {
    shift
    quiet=true
  }
  [[ "$1" == verbose ]] && {
    shift
    verbose=true
  }
  [[ "$1" == secret ]] && {
    shift
    secret=true
  }

  local -a command=("$@")
  local marker="$(util.random-string 10)"

  time.with-duration.start "${marker}"

  local cmd="${command[*]}"
  ${quiet} && cmd+=">/dev/null 2>&1"
  if ${secret}; then
    ${verbose} && inf "🤞🏼 Running Command: ${txtblk}${bakblu}[REDACTED]"
  else
    ${verbose} && inf "🤞🏼 Running Command: ${txtblk}${bakblu}${cmd}"
  fi

  set +e
  local code=0
  /usr/bin/env bash -c "${cmd}"
  code=$?
  if ${verbose}; then
    if [[ ${code} -eq 0 ]]; then
      ok:
      hr
      info "⏳ Total time taken: ${bldgrn}$(time.with-duration.end "${marker}"), command successful."
    else
      not-ok:
      hr
      info "⏳ Total time taken: ${bldred}$(time.with-duration.end "${marker}"), exit code: ${bldred}${code}"
    fi
  fi
  return ${code}
}

# @description
#   This function receives a command to execute as an argument.
#   The command is executed as 'eval "$@"'; meanwhile the start/end
#   times are measured, and the following string is printed at the end:
#   eg. "4 minutes 24.345 seconds"
# @args Command to run
function time.a-command() {
  local start="$(millis)"
  eval "$*"
  local end="$(millis)"
  local ruby_expr="secs=(0.0 + ${end} - ${start}).to_f/1000.0; mins=secs/60; secs=( secs - secs/60 ) if mins > 0 ; printf('%d minutes %2.3f seconds', mins, secs)"
  local duration=$(ruby -e "${ruby_expr}")
  echo -en "${duration}"
}

# Returns the date command that constructs a date from a given
# epoch number. Appears to be different on linux vs OSX.
time.date-from-epoch() {
  local epoch_ts
  epoch_ts="$1"
  printf "date --date='@${epoch_ts}'"
}

time.now.db() {
  date '+%F.%T.%S   ' | tr -d '\:\-\.'
}

time.now.file-extension() {
  time.now.db
}

time.epoch-to-iso() {
  local epoch_ts=$1
  eval "$(time.date-from-epoch "${epoch_ts}") -u \"+%Y-%m-%dT%H:%M:%S%z\"" | sed 's/0000/00:00/g'
}

time.epoch-to-local() {
  local epoch_ts=$1
  [[ -z ${epoch_ts} ]] && epoch_ts=$(epoch)
  eval "$(time.date-from-epoch "${epoch_ts}") \"+%m/%d/%Y, %r\""
}

time.epoch.minutes-ago() {
  local mins=${1}

  [[ -z ${mins} ]] && mins=1
  local seconds=$((mins * 60))
  local now_epoch=$(epoch)
  echo $((now_epoch - seconds))
}

time.duration.millis-to-secs() {
  local duration="$1"
  local format="${2:-"%d.%d"}"
  local seconds=$((duration / 1000))
  local leftover=$((duration - 1000 * seconds))
  printf "${format}" ${seconds} ${leftover}
}

time.duration.humanize() {
  local seconds=${1}
  local hours=$((seconds / 3600))
  local remainder=$((seconds - hours * 3600))
  local mins=$((remainder / 60))
  local secs=$((seconds - hours * 3600 - mins * 60))
  local prefixed=0
  [[ ${hours} -gt 0 ]] && {
    printf "%02dh:" ${hours}
    prefixed=1
  }
  [[ ${mins} -gt 0 || ${prefixed} == 1 ]] && {
    printf "%02dm:" ${mins}
    prefixed=1
  }
  { printf "%02ds" ${secs}; }
}

epoch() {
  date +%s
}

millis() {
  .run.millis
}

today() {
  date +'%Y-%m-%d'
}
