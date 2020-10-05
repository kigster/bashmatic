#!/usr/bin/env bash
# vim: ft=sh

# DEFINE CORE VARIABLES
export BASHMATIC_URL="https://github.com/kigster/bashmatic"
export BASHMATIC_INIT="${BASH_SOURCE[0]}"

[[ -z "${BASHMATIC_HOME}" ]] && {
  BASHMATIC_HOME="$(
    cd "$(dirname "${BASHMATIC_INIT}")" || exit
    pwd
  )"
  export BASHMATIC_HOME
}

[[ -f ${BASHMATIC_HOME}/init.sh ]] && export BASHMATIC_INIT="${BASHMATIC_HOME}/init.sh"

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

declare -A BashMatic__LoadCache 2>/dev/null
export BashMatic__LoadCache
export GrepCommand="$(which grep) -E -e "
export True=1
export False=0
export LoadedShown=${LoadedShown:-1}
export LibGit__QuietUpdate=1

main() {
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
}

main "$@"
