#!/usr/bin/env bash
# vim: ft=bash
#
# file: lib/init.sh
# 
# @description
#    This is primary loading file to access ALL or almost all of the Bashmatic functions.
#    At the time of this writing, this encompasses 826 funcitions, and takes 756ms on my
#    machine without the caching enabled.
#
# @see https://github.com/kigster/bashmatic#4-installing-bashmatic

set +ex

if [[ -n ${ZSH_EVAL_CONTEXT} && ${ZSH_EVAL_CONTEXT} =~ :file$ ]] ||
  [[ -n $BASH_VERSION && $0 != "${BASH_SOURCE[0]}" ]] ; then
  readonly __run_as_script=0 2>/dev/null
else
  readonly __run_as_script=1 2>/dev/null
fi

#————————————————————————————————————————————————————————————————————————————————————————————————————
# Initialization and Setup
#————————————————————————————————————————————————————————————————————————————————————————————————————

export SCRIPT_SOURCE="$(cd "$(/usr/bin/dirname "${BASH_SOURCE[0]:-"${(%):-%x}"}")" || exit 1; pwd -P)"
export PATH="${PATH}:/usr/local/bin:/usr/bin:/bin:/sbin:${SCRIPT_SOURCE}/bin"
export BASHMATIC_HOME="${SCRIPT_SOURCE}"
export BASHMATIC_MAIN="${BASHMATIC_HOME}/init.sh"
export BASHMATIC_LIB="${BASHMATIC_HOME}/lib"

export BASHMATIC_QUIET=0
export BASHMATIC_DEBUG=0
export BASHMATIC_LOADED=${BASHMATIC_LOADED:-0}

[[ $* =~ -r || $* =~ --reload ]] && export BASHMATIC_LOADED=0
[[ $* =~ -q || $* =~ --quiet ]] && export BASHMATIC_QUIET=1
[[ $* =~ -d || $* =~ --debug ]] && {
  export BASHMATIC_DEBUG=1
  export DEBUG=1
}

function is-debug() {
  [[ $((DEBUG + BASHMATIC_DEBUG + BASHMATIC_PATH_DEBUG)) -gt 0 ]] 
}

function is-quiet() {
  [[ ${BASHMATIC_QUIET} -gt 0 ]]
}

function not-quiet() {
  [[ ${BASHMATIC_QUIET} -eq 0 ]]
}

function log.err() {
  is-debug || return 0
  printf "$(pfx) ${blderr}[ERROR] --> ${bldylw}$*${clr}\n"
}

function log.inf() {
  is-debug || return 0
  printf "$(pfx) ${bldblu}[INFO]  --> ${bldgrn}$*${clr}\n"
}


function __bashmatic.print-path-config() {
  is-debug && not-quiet && printf "${BASHMATIC_PREFIX}\n"
  is-debug || return 0
  echo "BASHMATIC_HOME[${BASHMATIC_HOME}]"
  echo "BASHMATIC_MAIN[${BASHMATIC_MAIN}]" 
  command -v pstree >/dev/null  &&  $(command -v pstree) -p $$ -w
}

# @description
function __bashmatic.dealias() {
  for cmd in printf echo grep tr ps kill ; do unalias ${cmd} 2>/dev/null >/dev/null || true; done

  if [[ -f "${BASHMATIC_HOME}/.bash_safe_source" ]] ; then 
    source "${BASHMATIC_HOME}/.bash_safe_source"
    cp -p  "${BASHMATIC_HOME}/.bash_safe_source" "${HOME}/.bash_safe_source" 2>/dev/null
  fi
}

function __bashmatic.load-time() {
  [[ -n $(type millis 2>/dev/null) ]] || source "${BASHMATIC_HOME}/lib/time.sh"
  export __bashmatic_start_time="$(millis)"
}


function __bashmatic.init.darwin() {
  local -a required_binares=(gdate gsed)
  for binary in "${required_binares[@]}"; do
    command -v "${binary}" >/dev/null || brew install "${binary}"
  done
}

function __bashmatic.init.linux() {
  return 0
}

if ! declare -f -F source_if_exists >/dev/null; then
  source "${BASHMATIC_HOME}/.bash_safe_source"
fi

function __bashmatic.home.is-valid() {
  [[ -n ${BASHMATIC_HOME} && -d ${BASHMATIC_HOME} && -s ${BASHMATIC_HOME}/init.sh ]]
}

function year() {
  date '+%Y'
}

function __bashmatic.init-core() {
  __bashmatic.dealias

  # DEFINE CORE VARIABLES
  export BASHMATIC_URL="https://github.com/kigster/bashmatic"
  export BASHMATIC_OS="${BASHMATIC_OS}"

  # shellcheck disable=2046
  export BASHMATIC_TEMP="/tmp/${USER}/__bashmatic"
  [[ -d ${BASHMATIC_TEMP} ]] || mkdir -p "${BASHMATIC_TEMP}"

  if [[ -f ${BASHMATIC_HOME}/init.sh ]]; then
    export BASHMATIC_INIT="${BASHMATIC_MAIN}"
  else
    printf "${BASHMATIC_PREFIX}${bldred}ERROR: —> Can't determine BASHMATIC_HOME, giving up sorry!${clr}\n"
    return 1
  fi

  is-debug && __bashmatic.load-time
  is-quiet || printf "\n${BASHMATIC_PREFIX}\n\n"

  local init_func="__bashmatic.init.${BASHMATIC_OS}"
  [[ -n $(type "${init_func}" 2>/dev/null) ]] && ${init_func}

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

  # LOAD ALL BASHMATIC SCRIPTS AT ONCE
  # This is the fastest method that only takes about 110ms
  is-debug && not-quiet && printf "$(pfx) evaluating the library..."
  eval "$(/bin/cat "${BASHMATIC_HOME}"/lib/*.sh)"

  is-debug && not-quiet && {
    local __bashmatic_end_time=$(millis)
    echo
    h6 "Bashmatic library took $((__bashmatic_end_time - __bashmatic_start_time)) milliseconds to load."
  }
}


#————————————————————————————————————————————————————————————————————————————————————————————————————
# Argument Parsing in case they loaded us with , eg. .
# source init.sh reload
#————————————————————————————————————————————————————————————————————————————————————————————————————

function __bashmatic.parse-arguments() {
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
    fi
  done
}

#————————————————————————————————————————————————————————————————————————————————————————————————————
# Help
#————————————————————————————————————————————————————————————————————————————————————————————————————
[[ $* =~ -h || $* =~ --help  ]] && {
  [[ -f ${BASHMATIC_LIB}/color.sh ]] && source ${BASHMATIC_LIB}/color.sh
  printf "\n${BASHMATIC_PREFIX}\n"

  printf "
  ${bldylw}USAGE:${clr}
    ${bldgrn}source <bashmatic-home>/.init.sh  [ -q | --quiet ] \\
                                      [ -d | --debug ] \\
                                      [ -r | --reload ]

  ${bldylw}FLAGS:${clr}
    -q | --quiet         Supress output
    -d | --debug         Print lots of output
    -r | --reload        Reload the BashMatic library

  ${bldylw}DESCRIPTION:${clr}
    Loads the entire BashMatic™ Framework into the BASH memory.

"

  ((__run_as_script)) && exit 0
  return 0
}

#————————————————————————————————————————————————————————————————————————————————————————————————————
# Public functions
#————————————————————————————————————————————————————————————————————————————————————————————————————

function source-if-exists() {
  [[ -n $(type source_if_exists 2>/dev/null) ]] || source "${BASHMATIC_HOME}/.bash_safe_source"
  source_if_exists "$@"
}

function bashmatic.load() {
  __bashmatic.parse-arguments "$@"
  __bashmatic.init-core
  bashmatic.current-os >/dev/null
  export BASHMATIC_LOADED=1
  return 0
}

if [[ ${BASHMATIC_LOADED} -ne 1 ]] ; then
  #————————————————————————————————————————————————————————————————————————————————————————————————————
  # Main Flow
  #————————————————————————————————————————————————————————————————————————————————————————————————————

  [[ -f "${BASHMATIC_HOME}/lib/time.sh" ]] && source "${BASHMATIC_HOME}/lib/time.sh"

  export BASHMATIC_PREFIX="${txtred}${txtwht}${bakred}  BashMatic™ Framework for BASH v4+  ${txtblk}${bakylw} ® 2015-$(year) Konstantin Gredeskoul ${txtwht}${bakblu} Version ${BASHMATIC_VERSION}   ${clr}${txtblu}${clr}"

  function pfx() {
    printf "${txtred}${txtwht}${bakred}  BashMatic™ $(date.now.humanized) ${clr}${bldred} ${clr}"
  }

  # resolve BASHMATIC_HOME if necessary
  __bashmatic.home.is-valid || {
    log.inf "Resolving BASHMATIC_HOME as the current one is invalid: ${BASHMATIC_HOME}"
    if [[ "${SHELL_COMMAND}" =~ zsh ]]; then
      is-debug && \
        printf "${BASHMATIC_PREFIX} Detected zsh version ${ZSH_VERSION}, source=$0:A\n"
      export BASHMATIC_HOME="$(/usr/bin/dirname "$0:A")"
    elif [[ "${SHELL_COMMAND}" =~ bash ]]; then
      is-debug && \
        printf "${BASHMATIC_PREFIX} Detected bash version ${BASH_VERSION}, source=${BASH_SOURCE[0]}\n"
        export BASHMATIC_HOME="$(cd -P -- "$(/usr/bin/dirname -- "${BASH_SOURCE[0]}")" && printf '%s\n' "$(pwd -P)")"
    else
        printf "${BASHMATIC_PREFIX} WARNING: Detected an unsupported shell type: ${SHELL_COMMAND}, continue.\n" >&2
        export BASHMATIC_HOME="$(cd -P -- "$(/usr/bin/dirname -- "$0")" && printf '%s\n' "$(pwd -P)")"
    fi

    log.inf "Resolved BASHMATIC_HOME to [${BASHMATIC_HOME}]"
  }

  __bashmatic.home.is-valid || {
    log.err "ERROR: Can't determine BASHMATIC installation path."
    __bashmatic.print-path-config
    return 1
  }

  export GREP_CMD="$(command -v /usr/bin/grep || command -v /bin/grep || command -v /usr/local/bin/grep || echo grep)"
  # shellcheck disable=SC2002
  export BASHMATIC_VERSION="$(/bin/cat "${BASHMATIC_HOME}/.version" | /usr/bin/tr -d '\n')"
  export BASHMATIC_LIBDIR="${BASHMATIC_HOME}/lib"

  source ${BASHMATIC_LIBDIR}/util.sh

  export BASHMATIC_UNAME=$(system.uname)
  export BASHMATIC_OS="$($BASHMATIC_UNAME -s | /usr/bin/tr '[:upper:]' '[:lower:]')"

  # grab our shell command
  export SHELL_COMMAND="$(/bin/ps -p $$ -o args | ${GREP_CMD} -v -E 'ARGS|COMMAND' | /usr/bin/cut -d ' ' -f 1 | sed -E 's/-//g')"

  bashmatic.load "$@"

  export BASHMATIC_LOADED=1
else
  source "${BASHMATIC_LIB}/output-admonitions.sh"
  not-quiet && {
    echo
    divider
    is-debug && printf "$(pfx) BashMatic is already loaded.\n"
    is-debug && printf "$(pfx) Use function ${bldylw}bashmatic.reload()\n"
    is-debug && printf "$(pfx) if you want to reload all the sources.\n"
    divider
    echo
  } || true
fi
