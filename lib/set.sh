#!/usr/bin/env bash
# vi: ft=sh

# Utilities related to BASH's set

# This function is based on the fact that if set -e is set,
# the piped command before wc prints only "two", while if +e is set
# the overall output is "one\ntwo\n"

set-e-status() {
  set -o | grep errexit | awk '{print $2}'
}

set-e-save() {
  export __bash_set_errexit_status=$(mktemp -t 'errexit')
  rm -f "${__bash_set_errexit_status}" 2>/dev/null
  set-e-status >"${__bash_set_errexit_status}"
}

set-e-restore() {
  [[ -f ${__bash_set_errexit_status} ]] && {
    error "You must first save it with the function:s ${bldgrn}set-e-save"
    return 1
  }
  local status=$(cat "${__bash_set_errexit_status}" | tr -d '\n')
  if [[ ${status} != 'on' && ${status} != 'off' ]]; then
    error "Invalid data in the set -e tempfile:" "$(cat "${__bash_set_errexit_status}")"
    return 1
  fi
  set -o errexit "${status}"
  rm -f "${__bash_set_errexit_status}" 2>/dev/null
}


