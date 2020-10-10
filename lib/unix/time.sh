#!/usr/bin/env bash
#——————————————————————————————————————————————————————————————————————————————
# © 2016-2020 Konstantin Gredeskoul, All rights reserved. MIT License.
# Ported from the licensed under the MIT license Project Pullulant, at
# https://github.com/kigster/pullulant
#
# Any modifications, © 2016-2020 Konstantin Gredeskoul, All rights reserved. MIT License.
#——————————————————————————————————————————————————————————————————————————————

export _bashmatic_os=${_bashmatic_os:-$(uname -s)}

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
  local date_runnable
  date_runnable='date'
  if [[ "${_bashmatic_os}" == "Darwin" ]]; then
    [[ -z $(command -v gdate) ]] && .time.osx.coreutils
    [[ -n $(command -v gdate) ]] && date_runnable='gdate'
  fi
  ${date_runnable} '+%s%3N'
}

# milliseconds
function time.now.with-ms() {
  local date_runnable
  date_runnable='date'
  if [[ "${_bashmatic_os}" == "Darwin" ]]; then
    [[ -z $(command -v gdate) ]] && .time.osx.coreutils
    [[ -n $(command -v gdate) ]] && date_runnable='gdate'
  fi
  ${date_runnable} '+%T.%3N'
}

# Returns the date command that constructs a date from a given
# epoch number. Appears to be different on Linux vs OSX.
time.date-from-epoch() {
  local epoch_ts="$1"
  if [[ "${_bashmatic_os}" == "Darwin" ]]; then
    printf "date -r ${epoch_ts}"
  else
    printf "date --date='@${epoch_ts}'"
  fi
}

time.now.db() {
  date '+%F.%T' | tr -d '[-.:]'  
}

time.now.file-extension() {
  time.now.db
}

time.epoch-to-iso() {
  local epoch_ts=$1
  eval "$(time.date-from-epoch ${epoch_ts}) -u \"+%Y-%m-%dT%H:%M:%S%z\"" | sed 's/0000/00:00/g'
}

time.epoch-to-local() {
  local epoch_ts=$1
  [[ -z ${epoch_ts} ]] && epoch_ts=$(epoch)
  eval "$(time.date-from-epoch ${epoch_ts}) \"+%m/%d/%Y, %r\""
}

time.epoch.minutes-ago() {
  local mins=${1}

  [[ -z ${mins} ]] && mins=1
  local seconds=$((${mins} * 60))
  local epoch=$(epoch)
  echo $((${epoch} - ${seconds}))
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
  local hours=$((${seconds} / 3600))
  local remainder=$((${seconds} - ${hours} * 3600))
  local mins=$((${remainder} / 60))
  local secs=$((${seconds} - ${hours} * 3600 - ${mins} * 60))
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
