#!/usr/bin/env bash
# vim: ft=bash
#
# @description Options minicom (or installs it), and conects to the last modified device under /dev
# @args Any arguments you would pass to minicom, eg,
# @example Spool the session to a log file:
#   serial.console 
#

BashmaticSerial__DefaultBaud=9600
BashmaticSerial__DefaultDevice=

function serial.baud() {
  if [[ -n $1 ]]; then
    is.number "$1" && export BashmaticSerial__DefaultBaud="$1"
  fi
  h2 "Current Baud Rate:" "${bldylw}${BashmaticSerial__DefaultBaud} Bits/Second"
}

function serial.device() {
  if [[ -n $1 && $1 =~ ^/dev ]]; then
    export BashmaticSerial__DefaultDevice="$1"
  else
    export BashmaticSerial__DefaultDevice=$(ls -1 /dev/cu.* | grep -vi bluetooth | tail -1)
  fi
  h3 "Current Device is:" "${bldylw}${BashmaticSerial__DefaultDevice}"
}

function serial.console {
  command -v mimicom >/dev/null || {
    command -v brew >/dev/null && {
      info "Installing missing software: ${bldylw}minicom$(txt-info)..." >&2
      brew install minicom 
    }
  }

  [[ -z "${BashmaticSerial__DefaultDevice}" ]] && serial.device
  [[ -z "${BashmaticSerial__DefaultBaud}"   ]] && serial.baud

  local baud=${BashmaticSerial__DefaultBaud}
  local modem=${BashmaticSerial__DefaultDevice}

  if [ ! -z "$modem" ]; then
    hr 
    h3 "minicom -D $modem  -b $baud $*"
    sleep 1
    minicom -D "$modem"  -b "$baud" "$@"
  else
    echo "No USB modem device found in /dev"
  fi
}


