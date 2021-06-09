#!/usr/bin/env bash
# vim: ft=bash
PATH="/usr/local/bin:/usr/bin:/bin:/sbin:/usr/sbin:/opt/local/bin"
export PATH

set +e
export SHELL_COMMAND
# deterministicaly figure out our currently loaded shell.
SHELL_COMMAND="$(/bin/ps -p $$ -o args | /usr/bin/grep -v -E 'ARGS|COMMAND' | /usr/bin/cut -d ' ' -f 1 | /usr/bin/sed -E 's/-//g')"

[[ -n "${BASHMATIC_HOME}" && -d "${BASHMATIC_HOME}" && -f "${BASHMATIC_HOME}/init.sh" ]] || {
  if [[ "${SHELL_COMMAND}" =~ zsh ]]; then
    ((DEBUG)) && echo "Detected zsh version ${ZSH_VERSION}, source=$0:A"
    BASHMATIC_HOME="$(dirname "$0:A")"
  elif [[ "${SHELL_COMMAND}" =~ bash ]]; then
    ((DEBUG)) && echo "Detected bash version ${BASH_VERSION}, source=${BASH_SOURCE[0]}"
    BASHMATIC_HOME="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && printf '%s\n' "$(pwd -P)")"
  else
    echo "WARNING: Detected an unsupported shell type: ${SHELL_COMMAND}"
    BASHMATIC_HOME="$(cd -P -- "$(dirname -- "$0")" && printf '%s\n' "$(pwd -P)")"
  fi
}

export BASHMATIC_HOME
((DEBUG)) && echo "INFO: BASHMATIC_HOME=${BASHMATIC_HOME}"

BASHMATIC_LIBDIR="${BASHMATIC_HOME}/lib"
export BASHMATIC_LIBDIR

BASHMATIC_OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
export BASHMATIC_OS

ln -nfs "${BASHMATIC_HOME}/.bash_safe_source" "${HOME}/.bash_safe_source"

function .bashmatic.load-time() {
  [[ -n $(type millis 2>/dev/null) ]] && return 0

  [[ -f ${BASHMATIC_HOME}/lib/time.sh ]] && source "${BASHMATIC_HOME}/lib/time.sh"
  export __bashmatic_start_time="$(millis)"
}


function source-if-exists() {
  [[ -n $(type safe-source 2>/dev/null) ]] || source "${BASHMATIC_HOME}/.bash_safe_source"
  safe-source "$@"
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

function bashmatic.set-is-not-loaded() {
  __bashmatic_load_state=0
}

function bashmatic.init-core() {
  # DEFINE CORE VARIABLES
  export BASHMATIC_URL="https://github.com/kigster/bashmatic"
  export BASHMATIC_OS="${BASHMATIC_OS}"

  # shellcheck disable=2046
  export BASHMATIC_TEMP="/tmp/${USER}/.bashmatic"
  [[ -d ${BASHMATIC_TEMP} ]] || mkdir -p "${BASHMATIC_TEMP}"
  
  if [[ -f ${BASHMATIC_HOME}/init.sh ]] ; then
    export BASHMATIC_INIT="${BASHMATIC_HOME}/init.sh"
  else
    printf "${bldred}ERROR: —> Can't determine BASHMATIC_HOME, giving up sorry!${clr}\n"
    return 1
  fi
  
  [[ -n $DEBUG ]] && {
    [[ -f ${BASHMATIC_HOME}/lib/time.sh ]] && source "${BASHMATIC_HOME}/lib/time.sh"
    export __bashmatic_start_time=$(millis)
  }
  
  # If defined BASHMATIC_AUTOLOAD_FILES, we source these files together with BASHMATIC
  for _init in ${BASHMATIC_AUTOLOAD_FILES}; do
    [[ -s "${PWD}/${_init}" ]] && {
      [[ -n $DEBUG ]] && echo "sourcing in ${PWD}/${_init}"
      source "${PWD}/${_init}"
    }
  done
  
  # shellcheck disable=SC2155
  export BASHMATIC_VERSION="$(head -1 "${BASHMATIC_HOME}/.version")"
  [[ ${PATH} =~ ${BASHMATIC_HOME}/bin ]] || export PATH="${PATH}:${BASHMATIC_HOME}/bin"
  unalias grep 2>/dev/null || true
  export GrepCommand="$(command -v grep) -E "
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

function bashmatic.init() {
  local init_func=".bashmatic.init.${BASHMATIC_OS}"
  
  [[ -n $(type "${init_func}" 2>/dev/null) ]] && ${init_func}

  local setup_script="${BASHMATIC_LIBDIR}/bashmatic.sh"
  
  if [[ -s "${setup_script}" ]]; then
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
    local __bashmatic_end_time=$(millis)
    notice "Bashmatic library took $((__bashmatic_end_time - __bashmatic_start_time)) milliseconds to load."
  fi

  unset __bashmatic_end_time
  unset __bashmatic_start_time

  bashmatic.set-is-loaded
}

echo "$*" | grep -E -q 'reload|force|refresh' && bashmatic.set-is-not-loaded

bashmatic.init-core 
bashmatic.is-loaded || bashmatic.init "$@"

