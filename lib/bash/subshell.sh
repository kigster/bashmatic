#!/usr/bin/env bash
#
# This library detects whether a given script is sourced in or ran
# in a subshell.
#
# USAGE:
#
#     1. In a script to reject sourcing in, and only support running it:
#
#           #!/usr/bin/env bash
#           source ~/.bashmatic/init.sh
#           bashmatic.validate-subshell || return 1
#
#     2. Reject running as a script, but only support sourcing in:
#
#           #!/usr/bin/env bash
#           source ~/.bashmatic/init.sh
#           bashmatic.validate-sourced-in || exit 1

bashmatic.subshell-init() {
  export BASH_SUBSHELL_DETECTED=
}

bashmatic.detect-subshell() {
  bashmatic.subshell-init

  [[ -n ${BASH_SUBSHELL_DETECTED} && -n ${BASH_IN_SUBSHELL} ]] &&
    return "${BASH_IN_SUBSHELL}"

  unset BASH_IN_SUBSHELL
  export BASH_SUBSHELL_DETECTED=true

  local len="${#BASH_SOURCE[@]}"
  local last_index=$((len - 1))

  [[ -n ${BASHMATIC_DEBUG} ]] && {
    echo "BASH_SOURCE[*] = ${BASH_SOURCE[*]}" >&2
    echo "BASH_SOURCE[${last_index}] = ${BASH_SOURCE[${last_index}]}" >&2
    echo "\$0            = $0" >&2
  }

  if [[ -n ${ZSH_EVAL_CONEXT} && ${ZSH_EVAL_CONTEXT} =~ :file$ ]] ||
    [[ -n ${BASH_VERSION} && "$0" != "${BASH_SOURCE[${last_index}]}" ]]; then
    export BASH_IN_SUBSHELL=0
  else
    export BASH_IN_SUBSHELL=1
  fi

  return ${BASH_IN_SUBSHELL}
}

bashmatic.validate-sourced-in() {
  bashmatic.detect-subshell
  [[ ${BASH_IN_SUBSHELL} -eq 0 ]] || {
    echo "This script is meant to be sourced in, not run in a subshell." >&2
    return 1
  }

  return 0
}

bashmatic.validate-subshell() {
  bashmatic.detect-subshell
  [[ ${BASH_IN_SUBSHELL} -eq 1 ]] || {
    echo "This script is meant to be run, not sourced-in" >&2
    return 1
  }

  return 0
}
