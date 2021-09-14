#!/usr/bin/env bash
# vim: ft=bash
# file: lib/init.bash
# 
# @description
#    This is primary loading file to access ALL or almost all of the Bashmatic functions.
#    At the time of this writing, this encompasses 826 funcitions, and takes 756ms on my
#    machine without the caching enabled.
#
# The scripts that rely on Bashmatic, will typically have the following three lines at the top:
#     [[ -z ${BASHMATIC_HOME} ]] && export BASHMATIC_HOME="${HOME}/.bashmatic"
#     [[ -d ${BASHMATIC_HOME} ]] || bash -c "$(curl -fsSL https://bashmatic.re1.re); bashmatic-install              "
#     [[ -d ${BASHMATIC_HOME} ]] || {
#       echo "Can't find Bashmatic, even after attempting an installation."
#       echo "Please install Bashmatic with the following command line:"
#       echo 'bash -c "$(curl -fsSL https://bashmatic.re1.re); bashmatic-install"'
#       exit 1
#     }
# The meaning of this installation procedure is described in detail in the Bashmatic README:
# https://github.com/kigster/bashmatic#4-installing-bashmatic

set +ex

export SCRIPT_SOURCE="$(cd "$(/usr/bin/dirname "${BASH_SOURCE[0]:-"${(%):-%x}"}")" || exit 1; pwd -P)"

export PATH="${PATH}:/usr/local/bin:/usr/bin:/bin:/sbin"
export BASHMATIC_HOME=${BASHMATIC_HOME:-${SCRIPT_SOURCE}}
export BASHMATIC_MAIN=${BASHMATIC_HOME}/init.sh

function bashmatic.home.valid() {
  [[ -n $BASHMATIC_HOME && -d ${BASHMATIC_HOME} && -s ${BASHMATIC_HOME}/init.sh ]]
}

export BASHMATIC_PREFIX="[${bldpur}bashmatic® ${bldylw}${italic}${BASHMATIC_VERSION}]${clr} "

# resolve BASHMATIC_HOME if necessary
bashmatic.home.valid || {
  log.inf "Resolving BASHMATIC_HOME as the current one is invalid: ${BASHMATIC_HOME}"
  if [[ "${SHELL_COMMAND}" =~ zsh ]]; then
    ((BASHMATIC_DEBUG)) && \
      printf "${BASHMATIC_PREFIX} Detected zsh version ${ZSH_VERSION}, source=$0:A\n"
    BASHMATIC_HOME="$(/usr/bin/dirname "$0:A")"
  elif [[ "${SHELL_COMMAND}" =~ bash ]]; then
    ((BASHMATIC_DEBUG)) && \
      printf "${BASHMATIC_PREFIX} Detected bash version ${BASH_VERSION}, source=${BASH_SOURCE[0]}\n"
    BASHMATIC_HOME="$(cd -P -- "$(/usr/bin/dirname -- "${BASH_SOURCE[0]}")" && printf '%s\n' "$(pwd -P)")"
  else
    printf "${BASHMATIC_PREFIX} WARNING: Detected an unsupported shell type: ${SHELL_COMMAND}, continue.\n" >&2
    BASHMATIC_HOME="$(cd -P -- "$(/usr/bin//usr/bin/dirname -- "$0")" && printf '%s\n' "$(pwd -P)")"
  fi

  log.inf "Resolved BASHMATIC_HOME to [${BASHMATIC_HOME}]"
}

bashmatic.home.valid || { 
  log.err "ERROR: Can't determine BASHMATIC installation path."
  .bashmatic.print-path-config
  return 1
}

export GREP_CMD="$(command -v /usr/bin/grep || command -v /bin/grep || command -v /usr/local/bin/grep || echo grep)"
# shellcheck disable=SC2002
export BASHMATIC_VERSION="$(cat "${BASHMATIC_HOME}/.version" | /usr/bin/tr -d '\n')"
export BASHMATIC_LIBDIR="${BASHMATIC_HOME}/lib"
export BASHMATIC_OS="$(/usr/bin/uname -s | /usr/bin/tr '[:upper:]' '[:lower:]')"

# grab our shell command
export SHELL_COMMAND="$(/bin/ps -p $$ -o args | ${GREP_CMD} -v -E 'ARGS|COMMAND' | /usr/bin/cut -d ' ' -f 1 | sed -E 's/-//g')"

function log.err() {
  ((BASHMATIC_DEBUG + BASHMATIC_PATH_DEBUG)) || return 0
  printf "${blderr}[ERROR] --> ${bldylw}$*${clr}\n"
}

function log.inf() {
  ((BASHMATIC_DEBUG + BASHMATIC_PATH_DEBUG)) || return 0
  printf "${bldblu}[INFO]  --> ${bldgrn}$*${clr}\n"
}


function .bashmatic.print-path-config {
  ((BASHMATIC_PATH_DEBUG)) || return 0
  echo "BASHMATIC_HOME[${BASHMATIC_HOME}]"
  echo "BASHMATIC_MAIN[${BASHMATIC_MAIN}]" 
  command -v pstree >/dev/null  &&  $(command -v pstree) -p $$ -w
}


# @description
function bashmatic.dealias() {
  for cmd in printf eche grep tr ps kill ; do unalias ${cmd} 2>/dev/null >/dev/null || true; done

  if [[ -f "${BASHMATIC_HOME}/.bash_safe_source" ]] ; then 
    source "${BASHMATIC_HOME}/.bash_safe_source"
    cp -p  "${BASHMATIC_HOME}/.bash_safe_source" "${HOME}/.bash_safe_source" 2>/dev/null
  fi

  src "${BASHMATIC_HOME}/lib/is.sh"
  src "${BASHMATIC_HOME}/lib/color.sh"
  src "${BASHMATIC_HOME}/lib/output-repeat-char.sh"
  src "${BASHMATIC_HOME}/lib/output.sh"
  src "${BASHMATIC_HOME}/lib/output-utils.sh"
  src "${BASHMATIC_HOME}/lib/output-boxes.sh"
  src "${BASHMATIC_HOME}/lib/util.sh"
  src "${BASHMATIC_HOME}/lib/time.sh"
}

function .bashmatic.load-time() {
  [[ -n $(type millis 2>/dev/null) ]] && return 0

  [[ -f ${BASHMATIC_HOME}/lib/time.sh ]] && source "${BASHMATIC_HOME}/lib/time.sh"
  export __bashmatic_start_time="$(millis)"
}

function source-if-exists() {
  [[ -n $(type src 2>/dev/null) ]] || source "${BASHMATIC_HOME}/.bash_safe_source"
  src "$@"
}

# Set initial state to 0
# This can not be exported, because then subshells don't initialize correctly
export __bashmatic_load_state=${__bashmatic_load_state:=0}

function bashmatic.is-loaded() {
  [[ $SHELL =~ bash ]] && ((__bashmatic_load_state))
  return 0
}

function bashmatic.set-is-loaded() {
  export __bashmatic_load_state=1
}

function bashmatic.set-is-not-loaded() {
  export __bashmatic_load_state=0
}

function bashmatic.init-core() {
  log.inf calling .bashhmatic.pre-init
  bashmatic.dealias

  # DEFINE CORE VARIABLES
  export BASHMATIC_URL="https://github.com/kigster/bashmatic"
  export BASHMATIC_OS="${BASHMATIC_OS}"

  # shellcheck disable=2046
  export BASHMATIC_TEMP="/tmp/${USER}/.bashmatic"
  [[ -d ${BASHMATIC_TEMP} ]] || mkdir -p "${BASHMATIC_TEMP}"

  if [[ -f ${BASHMATIC_HOME}/init.sh ]]; then
    export BASHMATIC_INIT="${BASHMATIC_MAIN}"
  else
    printf "${BASHMATIC_PREFIX}${bldred}ERROR: —> Can't determine BASHMATIC_HOME, giving up sorry!${clr}\n"
    return 1
  fi

  [[ -n ${BASHMATIC_DEBUG} ]] && {
    [[ -f "${BASHMATIC_HOME}/lib/time.sh" ]] && source "${BASHMATIC_HOME}/lib/time.sh"
    export __bashmatic_start_time=$(millis)
  }

  # If defined BASHMATIC_AUTOLOAD_FILES, we source these files together with BASHMATIC
  for _init in ${BASHMATIC_AUTOLOAD_FILES}; do
    [[ -s "${PWD}/${_init}" ]] && {
      [[ -n ${BASHMATIC_DEBUG} ]] && \
      printf "${BASHMATIC_PREFIX} sourcing in <—— [${bldblu}${PWD}/${_init}${clr}]"
      source "${PWD}/${_init}"
    }
  done

  # Load BASHMATIC library
  ((BASHMATIC_DEBUG)) && {
     printf "${BASHMATIC_PREFIX} evaluating all shell files under ${bldylw}${BASHMATIC_HOME}/lib...${clr}\n"
  }

  find "${BASHMATIC_HOME}/lib" -name '[a-z]*.sh' -type f -exec cat   {} \; | eval

  # shellcheck disable=SC2155
  [[ ${PATH} =~ ${BASHMATIC_HOME}/bin ]] || export PATH=${PATH}:${BASHMATIC_HOME}/bin
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
  required_binares=(brew gdate gsed)
  local some_missing=0
  for binary in "${required_binares[@]}"; do
    command -v "${binary}" >/dev/null && continue
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

function bashmatic.init.paths() {
  declare -a paths=()
  for p in $(path.dirs "${PATH}"); do
    paths+=("$p")
  done

  ((BASHMATIC_PATH_DEBUG)) && {
    h3bg "The current \$PATH components are:"
    for p in "${paths[@]}"; do
      printf " • [$(printf "%40.40s\n" "${p}")]\n"
    done
  }
  return 0
}


function bashmatic.init() {
  for file in "$@"; do
    [[ $0 =~ $file ]] && {
      log.inf "skipping the first file ${file}"
      continue 
    }
    local env_file="${BASHMATIC_HOME}/.envrc.${file}"
    if [[ -f $env_file ]]; then
     log.inf "sourcing env file ${env_file}"
      source "$env_file"
    fi
    if [[ "$file" =~ (reload|force|refresh) ]]; then
      log.inf "setting to is-not-loaded"
      bashmatic.set-is-not-loaded
    fi
  done
  
  log.inf "calling bashhmatic.init-core"
  bashmatic.init-core  
  log.inf "calling bashhmatic.is-loaded"
  bashmatic.is-loaded || {
    log.inf "calling bashhmatic.init"
    bashmatic.init "$@"
  } 

  local init_func=".bashmatic.init.${BASHMATIC_OS}"

  [[ -n $(typle "${init_func}" 2>/dev/null) ]] && ${init_func}

  local setup_script="${BASHMATIC_LIBDIR}/bashmatic.sh"

  if [[ -s "${setup_script}" ]]; then
    source "${setup_script}"
    bashmatic.setup
    local code=$?
    ((code)) && printf "${BASHMATIC_PREFIX} Function ${bldred}bashmatic.setup${clr} returned exit code [${code}]"
  else
    log.err "  ⛔️  Bashmatic appears to be broken:"
    log.err "      File not found: ${setup_script}"

    .bashmatic.print-path-config
    return 1
  fi

  if [[ -n ${BASHMATIC_DEBUG} ]]; then
    local __bashmatic_end_time=$(millis)
    ((BASHMATIC_DEBUG)) && notice "Bashmatic library took $((__bashmatic_end_time - __bashmatic_start_time)) milliseconds to load."
  fi

  unset __bashmatic_end_time
  unset __bashmatic_start_time

  bashmatic.set-is-loaded

  export BASHMATIC_CACHE_INIT=1
  return 0
}

bashmatic.init "$@"

