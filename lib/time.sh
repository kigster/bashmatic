#!/usr/bin/env bash
#——————————————————————————————————————————————————————————————————————————————
# © 2016-2017 Author: Konstantin Gredeskoul
# Ported from the licensed under the MIT license Project Pullulant, at
# https://github.com/kigster/pullulant
#
# Any modifications, © 2017 Konstantin Gredeskoul, Inc. All rights reserved.
#——————————————————————————————————————————————————————————————————————————————

export AppCurrentOS=${AppCurrentOS:-$(uname -s)}

# Install necessary dependencies on OSX
__lib::time::osx::coreutils() {
  # install gdate quietly
  brew install coreutils 2>&1 |cat > /dev/null
  code=$?
  if [[ ${code} != 0 || -z $(which gdate) ]]; then
    error "Can not install coreutils brew package, exit code ${code}"
    printf "Please run ${bldylw}brew install coreutils${clr} to install gdate utility."
    exit ${code}
  fi
}

# milliseconds
__lib::run::millis() {
  if [[ "${AppCurrentOS}" == "Darwin" ]] ; then
    [[ -z $(which gdate) ]] && __lib::time::osx::coreutils
    printf $(($(gdate +%s%N)/1000000 - 1000000000000))
  else
    printf $(($(date +%s%N)/1000000 - 1000000000000))
  fi
}

# Returns the date command that constructs a date from a given
# epoch number. Appears to be different on Linux vs OSX.
lib::time::date-from-epoch() {
  local epoch_ts="$1"
  if [[ "${AppCurrentOS}" == "Darwin" ]] ; then
    printf "date -r ${epoch_ts}"
  else
    printf "date --date='@${epoch_ts}'"
  fi
}
lib::time::epoch-to-iso() {
  local epoch_ts=$1
  eval "$(lib::time::date-from-epoch ${epoch_ts}) -u \"+%Y-%m-%dT%H:%M:%S%z\"" | sed 's/0000/00:00/g'
}

lib::time::epoch-to-local() {
  local epoch_ts=$1
  [[ -z ${epoch_ts} ]] && epoch_ts=$(epoch)
  eval "$(lib::time::date-from-epoch ${epoch_ts}) \"+%m/%d/%Y, %r\""
}

lib::time::epoch::minutes-ago() {
  local mins=${1}

  [[ -z ${mins} ]] && mins=1
  local seconds=$(( ${mins} * 60 ))
  local epoch=$(epoch)
  echo $(( ${epoch} - ${seconds} ))
}

lib::time::duration::humanize() {
  local seconds=${1}
  local hours=$(( ${seconds} / 3600 ))
  local remainder=$(( ${seconds} - ${hours} * 3600 ))
  local mins=$(( ${remainder} / 60 ))
  local secs=$(( ${seconds} - ${hours} * 3600 - ${mins} * 60 ))
  local prefixed=0
  [[ ${hours} -gt 0 ]] && { printf "%02dh:" ${hours}; prefixed=1; }
  [[ ${mins} -gt 0 || ${prefixed} == 1 ]] && { printf "%02dm:" ${mins}; prefixed=1; }
  { printf "%02ds" ${secs}; }
}

epoch() {
  date +%s
}

millis() {
  __lib::run::millis
}

today() {
  date +'%Y-%m-%d'
}
