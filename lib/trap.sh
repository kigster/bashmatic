#!/usr/bin/env bash
# vi: ft=sh
#
# USAGE:
#
#   lib::trap-setup INT
#   while true; do 
#     lib::trap-fired && {
#       abort;
#       return 1
#     }
#     # regular loop work
#   done
#        
#     

__lib::trap-cleanup() {
  [[ -f "${__int_marker__}" ]] && rm -f "${__int_marker__}"
  export __int_flag__=0
}

__lib::trap-catch() {
  export __int_marker__=$(mktemp -t "interrupt.$$")
  export __int_flag__=1
  trap '__lib::trap-cleanup' EXIT
}

__lib::trap-remove() {
  __lib::trap-cleanup
  if [[ -n "${__int_signal__}" ]]; then
    trap - "${__int_signal__}"
    unset __int_signal__
  fi
}

#————————————————————————————————————————————————————————————
# Public
#————————————————————————————————————————————————————————————

# Configure a trap
lib::trap-setup() {
  __lib::trap-remove
  local signal="${1:-"SIGINT"}"
  trap '__lib::trap-catch' "${signal}"
  export __int_signal__="${signal}"
}

# Using a temp file
lib::trap-was-fired() {
  if [[ -f ${__int_marker__} ]]; then
    rm -f "${__int_marker__}"
    #__lib::trap-remove
    return 0
  fi
  return 1
}

# Using a variable
lib::trapped() {
  if [[ ${__int_flag__} -eq 1 ]]; then
    unset __int__flag__
    #__lib::trap-remove
    return 0
  fi
  return 1
}

