#!/usr/bin/env bash
# vim: ft=sh

export BASHMATIC_HOME="$(cd $(dirname "${BASH_SOURCE[0]:-${(%):-%x}}") || exit 1; pwd -P)"
export BASHMATIC_LIBDIR="${BASHMATIC_HOME}/lib"
export AppCurrentOS="$(uname -s | tr '[:upper:]' '[:lower:]')"

function source-if-exists() {
  local file
  for file in "$@"; do
    [[ -f "${file}" ]] && source "${file}"
  done
}

# Set initial state to 0
# This can not be exported, because then subshells don't initialize correctly
__bashmatic_load_state=${__bashmatic_load_state:=0}

function bashmatic.is-loaded() {
  [[ $SHELL =~ bash ]] && ((__bashmatic_load_state))
}

function bashmatic.set-is-loaded() {
  __bashmatic_load_state=1
}

function bashmatic.reset-is-loaded() {
  __bashmatic_load_state=0
}

function .bashmatic.core() {
  # DEFINE CORE VARIABLES
  export BASHMATIC_URL="https://github.com/kigster/bashmatic"
  export BASHMATIC_OS="${AppCurrentOS}"

  # shellcheck disable=2046
  export BASHMATIC_TEMP="/tmp/${USER}/.bashmatic"
  [[ -d ${BASHMATIC_TEMP} ]] || mkdir -p "${BASHMATIC_TEMP}"
  
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
  [[ ${PATH} =~ ${BASHMATIC_HOME}/bin ]] || export PATH="${PATH}:${BASHMATIC_HOME}/bin"
  export GrepCommand="$(which grep) -E -e "
  export True=1
  export False=0
  export LoadedShown=${LoadedShown:-1}
  
  # Future CLI flags, but for now just vars
  export LibGit__QuietUpdate=${LibGit__QuietUpdate:-1}
  export LibGit__ForceUpdate=${LibGit__ForceUpdate:-0}
}

function .bashmatic.init.darwin() {
  local -a required_binares
  required_binares=( brew gdate gsed )
  local some_missing=0
  for binary in "${required_binares[@]}"; do
    command -v "${binary}">/dev/null && continue
    some_missing=$((some_mising + 1))
  done

  if [[ ${some_missing} -gt 0 ]]; then
    set +e
    source "${BASHMATIC_HOME}/bin/bashmatic-install"
    darwin-requirements
  fi
}

function .bashmatic.init.linux() {
  return 0
}

function .bashmatic.initialize() {
  set -e
  local init_func=".bashmatic.init.${AppCurrentOS}"
  
  [[ -n $(type "${init_func}" 2>/dev/null) ]] && ${init_func}

  local setup_script="${BASHMATIC_LIBDIR}/bashmatic.sh"
  
  if [[ -s "${setup_script}" ]]; then
    set +e
    source "${setup_script}"
    bashmatic.setup
    local code=$?
    ((code)) && echo "bashmatic.setup returned exit code [${code}]"
  else
    echo "  ⛔️ ERROR:"
    echo "  🙁 Bashmatic appears to be broken, file not found: ${setup_script}"
    return 1
  fi

  if [[ -n $DEBUG ]]; then
    end=$(millis)
    attention "Bashmatic Library took $((end - start)) milliseconds to load."
  fi

  return 0
}

function bashmatic.init() {
  .bashmatic.initialize "$@" 
  bashmatic.set-is-loaded
}

echo "$1" | grep -E -q 'reload|force|refresh' && bashmatic.reset-is-loaded

.bashmatic.core
bashmatic.is-loaded || bashmatic.init "$@"
