#!/usr/bin/env bash
# vim: ft=sh

# DEFINE CORE VARIABLES
export BASHMATIC_URL="https://github.com/kigster/bashmatic"
# shellcheck disable=2046
export BASHMATIC_HOME="$(cd $(dirname "${BASH_SOURCE[0]:-${(%):-%x}}") || exit 1; pwd -P)"

# [[ -z "${BASHMATIC_HOME}" ]] && {
#   BASHMATIC_HOME="$(
#     cd "$(dirname "${BASHMATIC_INIT}")" || exit
#     pwd
#   )"
#   export BASHMATIC_HOME
# }

if [[ -f ${BASHMATIC_HOME}/init.sh ]] ; then 
  export BASHMATIC_INIT="${BASHMATIC_HOME}/init.sh"
else
  echo "Can't determine BASHMATIC_HOME, giving up sorry!"
  return
fi

[[ -n $DEBUG ]] && {
  [[ -f ${BASHMATIC_HOME}/lib/time.sh ]] && source "${BASHMATIC_HOME}/lib/time.sh"
  start=$(millis)
}

# If defined BASHMATIC_AUTOLOAD_FILES, we source these files together with BASHMATIC
for _init in ${BASHMATIC_AUTOLOAD_FILES}; do
  [[ -s "${PWD}/${_init}" ]] && {
    [[ -n $DEBUG ]] && echo "sourcing in ${PWD}/${_init}"
    source "${PWD}/${_init}"
  }
done

# shellcheck disable=SC2155
export BASHMATIC_VERSION="$(cat "${BASHMATIC_HOME}/.version" | head -1)"
export BASHMATIC_LIBDIR="${BASHMATIC_HOME}/lib"
export PATH="${PATH}:${BASHMATIC_HOME}/bin"

export GrepCommand="$(which grep) -E -e "
export True=1
export False=0
export LoadedShown=${LoadedShown:-1}
export LibGit__QuietUpdate=1

osx-dependencies() {
  [[ $(uname -s) == "Darwin" ]] || return

  if command -v brew >/dev/null && command -v gdate >/dev/null ; then
    return
  else
    source "${BASHMATIC_HOME}/bin/bootstrap" init
    set +e
    bootstrap-dependencies
  fi
}

main() {
  set +e
  osx-dependencies || true

  local setup_script="${BASHMATIC_LIBDIR}/bashmatic.sh"

  if [[ -s "${setup_script}" ]]; then
    # shellcheck disable=SC1090
    source "${setup_script}"
    bashmatic.setup
  else
    echo "  ⛔️ ERROR:"
    echo "  🙁 Bashmatic appears to be broken, file not found: ${setup_script}"
    return 1
  fi
  if [[ -n $DEBUG ]]; then
    end=$(millis)
    attention "Bashmatic Library took $((end - start)) milliseconds to load."
  fi
}

main "$@"
