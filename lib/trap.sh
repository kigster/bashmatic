#!/usr/bin/env bash
# vi: ft=sh
#
# USAGE:
#
#   trap-setup INT
#   while true; do
#     trap-was-fired && {
#       abort;
#       return 1
#     }
#     # regular loop work
#   done
#
#

.trap-cleanup() {
  [[ -f "${__int_marker__}" ]] && rm -f "${__int_marker__}"
  unset __int_marker__
  export __int_flag__=0
}

.trap-catch() {
  export __int_marker__=$(mktemp -t "interrupt.$$")
  export __int_flag__=1
  trap '.trap-cleanup' EXIT
}

.trap-remove() {
  .trap-cleanup
  if [[ -n "${__int_signal__}" ]]; then
    trap - "${__int_signal__}"
    unset __int_signal__
  fi
}

#————————————————————————————————————————————————————————————
# Public
#————————————————————————————————————————————————————————————

# Configure a trap
trap-setup() {
  .trap-remove
  local signal="${1:-"SIGINT"}"
  trap '.trap-catch' "${signal}"
  export __int_signal__="${signal}"
}

# Using a temp file
trap-was-fired() {
  if [[ -n "${__int_marker__}" && -f "${__int_marker__}" ]]; then
    rm -f "${__int_marker__}"
    #.trap-remove
    return 0
  fi
  return 1
}

# Using a variable
trapped() {
  if [[ ${__int_flag__} -eq 1 ]]; then
    unset __int__flag__
    #.trap-remove
    return 0
  fi
  return 1
}


