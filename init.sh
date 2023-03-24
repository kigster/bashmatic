#!/usr/bin/env bash
# vim: ft=bash
# file: init.sh
#
# @description
#    This is primary loading file to access ALL or almost all of the Bashmatic functions.
#    At the time of this writing, this encompasses 826 funcitions, and takes 756ms on my
#    machine without the caching enabled.
#
# @see https://github.com/kigster/bashmatic#4-installing-bashmatic
if [[ -n ${ZSH_EVAL_CONTEXT} && ${ZSH_EVAL_CONTEXT} =~ :file$ ]] ||
  [[ -n $BASH_VERSION && $0 != "${BASH_SOURCE[0]}" ]] ; then
  export __run_as_script=0 2>/dev/null
else
  export __run_as_script=1 2>/dev/null
fi

export BASHMATIC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd -P)"
export BASHMATIC_HOME="${BASHMATIC_DIR}"
export BASHMATIC_LIB="${BASHMATIC_HOME}/lib"

source "${BASHMATIC_LIB}/util.sh"

export BASH_MAJOR_VERSION="${BASH_VERSION:0:1}"
export GLOBAL="declare "

if [[ ${BASH_MAJOR_VERSION} -eq 3 ]] ; then
  export GLOBAL="declare"
elif [[ ${BASH_MAJOR_VERSION} -gt 3 ]] ; then
  export GLOBAL="declare -g"
elif [[ $SHELL =~ zsh ]]; then
  typeset -gx GLOBAL
  GLOBAL="typeset -gx "
else
  export GLOBAL="declare"
fi

eval "
  ${GLOBAL} DEBUG                         ;
  ${GLOBAL} BASHMATIC_DEBUG               ;
  ${GLOBAL} BASHMATIC_HELP                ;
  ${GLOBAL} BASHMATIC_OS                  ;
  ${GLOBAL} BASHMATIC_OS_NAME             ;
  ${GLOBAL} BASHMATIC_HOME                ;
  ${GLOBAL} BASHMATIC_INIT                ;
  ${GLOBAL} BASHMATIC_LIB                 ;
  ${GLOBAL} BASHMATIC_SHOW_BANNER_SECS    ;
"

system.save-os-name

# Every 5 minutes, since it's in seconds
export BASHMATIC_SHOW_BANNER_SECS=$(( 5 * 60 ))
eval "${GLOBAL} bashmatic_showed_banner_at"

declare -a OBFUSCATED_VARIABLES
export OBFUSCATED_VARIABLES=()
export GLOBAL

#————————————————————————————————————————————————————————————————————————————————————————————————————
# Initialization and Setup
#————————————————————————————————————————————————————————————————————————————————————————————————————

function bdate() {
  if [[ "${BASHMATIC_OS:=$(uname -s | tr '[:upper:]' '[:lower:]')}" == "darwin" ]]; then
    command -v gdate >/dev/null || gdate.install >/dev/null
    command -v gdate >/dev/null && {
      command -v gdate
      return
    }
  fi
  command -v date
}

function gdate.install() {
  [[ "${BASHMATIC_OS:=$(uname -s | tr '[:upper:]' '[:lower:]')}" == "darwin" ]] || return 0

  command -v gdate >/dev/null && return
  command -v brew  >/dev/null && brew install -q coreutils
  command -v gdate >/dev/null && ln -sv "$(command -v gdate)" /usr/local/bin/date
}

function date.now.humanized() {
  $(bdate) '+%d %b %Y | %T.%3N %P'
}

function year() {
  date '+%Y'
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

function cursor.up() {
  printf "\e[${1:-"1"}A"
}

function inline.ok() {
  printf " ${txtblk}${bakgrn} ✔︎ ${clr} "
}


function log.err() {
  is-debug || return 0
  printf "$(pfx) ${txtblk}${bakred}${txtwht}${bakred} ERROR ${clr}${txtred}${clr}${bldred} $*${clr}\n"
}

function log.inf() {
  is-debug || return 0
  printf "$(pfx) ${txtblk}${bakblu}${txtwht}${bakblu} INFO  ${clr}${txtblu}${clr}${bldblu} $*${clr}\n"
}

function log.ok() {
  cursor.up 1
  inline.ok
  echo
}

function log.not-ok() {
  cursor.up 1
  inline.not-ok
  echo
}

# shellcheck disable=SC2296
export SCRIPT_SOURCE="$(cd "$(/usr/bin/dirname "${BASH_SOURCE[0]:-"${(%):-%x}"}")" || exit 1; pwd -P)"
export PATH="${PATH}:/usr/local/bin:/usr/bin:/bin:/sbin:${SCRIPT_SOURCE}/bin"
export BASHMATIC_HOME="${SCRIPT_SOURCE}"
export BASHMATIC_INIT="${BASHMATIC_HOME}/init.sh"
export BASHMATIC_LIB="${BASHMATIC_HOME}/lib"

export BASHMATIC_QUIET=0
export BASHMATIC_DEBUG=0
export BASHMATIC_HELP=0

[[ "$*" =~ (-q|--quiet) ]] && export BASHMATIC_QUIET=1
[[ "$*" =~ (-d|--debug) ]] && export BASHMATIC_DEBUG=1
[[ "$*" =~ (-h|--help)  ]] && export BASHMATIC_HELP=1

eval "${GLOBAL} -a BASHMATIC_REQUIRED_LIBS"
export BASHMATIC_REQUIRED_LIBS=( time output util color output-admonitions output-boxes output-utils )
export __bashmatic_prerequisites_loaded=false

# @description sources in some of the library files required for handling init.sh
function __bashmatic.prerequisites() {
  ${__bashmatic_prerequisites_loaded} && {
    return 0
  }

  export __bashmatic_prerequisites_loaded=true
  for lib in "${BASHMATIC_REQUIRED_LIBS[@]}"; do
    file="${BASHMATIC_HOME}/lib/${lib}.sh"
    # is-debug && not-quiet && log.inf    "Checking lib: [${file}]..."
    if [[ -f "${file}" ]]; then
      is-debug && not-quiet && log.inf  "Sourcing lib: [${file}]..."
      # shellcheck disable=SC1090
      source "${file}"
      __bashmatic.debug-conclusion $?
    else
      log.err "Can't find lib: [${file}]... (ignoring)"
    fi
  done

  # shellcheck disable=SC2002
  export BASHMATIC_VERSION="$(/bin/cat "${BASHMATIC_HOME}/.version" | /usr/bin/tr -d '\n')"
  export BASHMATIC_PREFIX="            ${txtgrn}${txtblk}${bakgrn}  bashmatic.sh \
  ${txtblk}${bakylw} ® 2015-$(year) Konstantin Gredeskoul   \
  ${txtwht}${bakblu}   v${BASHMATIC_VERSION}   ${clr}${txtblu}${clr}"
}

#————————————————————————————————————————————————————————————————————————————————————————————————————
# Argument Parsing in case they loaded us with , eg. .
# source init.sh reload
#————————————————————————————————————————————————————————————————————————————————————————————————————

function __bashmatic.parse-arguments() {
  [[ $* =~ (-r|--reload|-f|--force) ]] && export BASHMATIC_LOADED=0
  [[ $* =~ (-q|--quiet) ]] && {
    unset BASHMATIC_DEBUG
    unset DEBUG
    export BASHMATIC_QUIET=1
  }
  [[ $* =~ (-d|--debug) ]] && {
    export BASHMATIC_DEBUG=1
    export DEBUG=1
  }
  [[ $* =~ (-h|--help) ]] && {
    export BASHMATIC_HELP=1
    unset BASHMATIC_DEBUG
    unset DEBUG
  }

  for file in "$@"; do
    [[ $0 =~ $file ]] && {
      log.inf "skipping the first file ${file}"
      continue
    }
    local env_file="${BASHMATIC_HOME}/.envrc.${file}"
    if [[ -s "${env_file}" ]]; then
      log.inf "sourcing env file [${env_file}]"
      source "${env_file}"
    fi

    if [[ "$file" =~ (reload|force|refresh|-f) ]]; then
      log.inf "force-reloading bashmatic library..."; log.ok
    fi
  done
}

function __bashmatic.print-path-config() {
  is-debug && not-quiet && printf "${BASHMATIC_PREFIX}\n"
  is-debug || return 0
  echo "BASHMATIC_HOME[${BASHMATIC_HOME}]"
  echo "BASHMATIC_INIT[${BASHMATIC_INIT}]"
  command -v pstree >/dev/null  &&  $(command -v pstree) -p $$ -w
}

# @description
function __bashmatic.unalias() {
  for cmd in printf echo grep tr ps kill ; do unalias ${cmd} 2>/dev/null >/dev/null || true; done

  if [[ -f "${BASHMATIC_HOME}/.bash_safe_source" ]] ; then
    # shellcheck source=./.bash_safe_source
    source "${BASHMATIC_HOME}/.bash_safe_source"
    cp -p  "${BASHMATIC_HOME}/.bash_safe_source" "${HOME}/.bash_safe_source" 2>/dev/null
  fi
}

function __bashmatic.debug-conclusion() {
  local code="${1:-0}"
  is-debug && not-quiet && {
    ((code)) && log.not-ok
    ((code)) || log.ok
  }
}

# shellcheck disable=SC2120 source=./lib/util.sh
# shellcheck disable=SC2120 source=./lib/time.sh
function __bashmatic.eval-library() {

  source "${BASHMATIC_LIB}/time.sh"
  source "${BASHMATIC_LIB}/util.sh"

  local __bashmatic_start_time="$(millis)"

  # LOAD ALL BASHMATIC SCRIPTS AT ONCE
  # This is the fastest method that only takes about 80ms
  eval "$(/bin/cat "${BASHMATIC_LIB}"/*.sh)"
  source "${BASHMATIC_LIB}/runtime.sh"
  __bashmatic.debug-conclusion $?

  is-debug && not-quiet && {
    local __bashmatic_end_time=$(millis)
    log.inf "Bashmatic library took $((__bashmatic_end_time - __bashmatic_start_time)) milliseconds to load."
    log.ok
  }
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
  # shellcheck source=./.bash_safe_source
  source "${BASHMATIC_HOME}/.bash_safe_source"
fi

function __bashmatic.home.is-valid() {
  [[ -n ${BASHMATIC_HOME} && -d ${BASHMATIC_HOME} && -s ${BASHMATIC_HOME}/init.sh ]]
}

function __bashmatic.init-core() {
  __bashmatic.unalias

  # DEFINE CORE VARIABLES
  export BASHMATIC_URL="https://github.com/kigster/bashmatic"
  export BASHMATIC_UNAME="$(system.uname)"

  # bashsupport disable=BP2001
  # shellcheck disable=2046
  export BASHMATIC_TEMP="/tmp/${USER}/__bashmatic"
  [[ -d ${BASHMATIC_TEMP} ]] || mkdir -p "${BASHMATIC_TEMP}"

  if [[ -f ${BASHMATIC_HOME}/init.sh ]]; then
    export BASHMATIC_INIT="${BASHMATIC_INIT}"
  else
    printf "${BASHMATIC_PREFIX}${bldred}ERROR: —> Can't determine BASHMATIC_HOME, giving up sorry!${clr}\n"
    return 1
  fi

  local init_func="__bashmatic.init.${BASHMATIC_OS_NAME}"
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

  # Load all library files into an array. This isn't really used besides showing the total
  # number of files, but it can come handy later. Plus, mapfile takes 26ms.
  if [[ $SHELL =~ zsh || ${BASH_MAJOR_VERSION} -lt 4 ]]; then
    warning "Please, for the love of technology and the larger cosmos, " \
      "do yourself a favor and upgrade your BASH already..." \
      "You are running version $(bash --version | head -1)"
    is-debug && not-quiet && log.inf "Evaluating the library, total of $(ls -1 "${BASHMATIC_LIB}"/*.sh | wc -l | tr -d '\n ') sources to load..."
  else
    local -a sources=( $(find "${BASHMATIC_HOME}/lib" -name '*.sh') )
    is-debug && not-quiet && log.inf "Evaluating the library, total of ${#sources[@]} sources to load..." && log.ok
  fi
}

#————————————————————————————————————————————————————————————————————————————————————————————————————
# Banner
#————————————————————————————————————————————————————————————————————————————————————————————————————


function __bashmatic.banner.show() {
  export bashmatic_showed_banner_at=$(millis)
  printf "\n${BASHMATIC_PREFIX}\n\n"
}

# @description Show Bashmatic Banner if and only if:
#              • it wasn't shown yet
#              • this is not an SSH session
#              • this is a proper interactive TTY
#              • no --quiet/-q flag was passed.
# @arguments [ true|false, true|false ]
# @example
#      __bashmatic.banner true
function __bashmatic.banner() {
  __bashmatic.prerequisites

  local force_show=${1:-false}
  # bashsupport disable=BP2001
  export bashmatic_showed_banner_at=${bashmatic_showed_banner_at:-0}

  local now=$(millis)
  local seconds_passed=$(( ( now - bashmatic_showed_banner_at) / 1000 ))

  if ${force_show}; then
    __bashmatic.banner.show
  else
    # reasons NOT to show it
    output.is-ssh                     && return 2
    (not-quiet && output.is-tty)      || return 3
    [[ ${seconds_passed} -lt ${BASHMATIC_SHOW_BANNER_SECS} ]] && return 1
  fi
  __bashmatic.banner.show
}

#————————————————————————————————————————————————————————————————————————————————————————————————————
# Help
#————————————————————————————————————————————————————————————————————————————————————————————————————

function __bashmatic.init-help() {
  printf "
${bldylw}USAGE:${clr}
  ${bldgrn}source <bashmatic-home>/init.sh  [  flags  ]
  ${bldgrn}<bashmatic-home>/init.sh         [  flags  ]

${bldylw}FLAGS:${clr}
  -q | --quiet         Supress output
  -d | --debug         Print lots of output
  -r | --reload        Reload the BashMatic library
  -f | --force         Reload the BashMatic library
  -h | --help          Print this help message.

${bldylw}DESCRIPTION:${clr}
  Loads the entire BashMatic™ Framework into the BASH memory.

"
  ((__run_as_script)) && exit 0
}

#————————————————————————————————————————————————————————————————————————————————————————————————————
# Public functions
#————————————————————————————————————————————————————————————————————————————————————————————————————

function source-if-exists() {
  [[ -n $(type source_if_exists 2>/dev/null) ]] || source "${BASHMATIC_HOME}/.bash_safe_source"
  source_if_exists "$@"
}

function bashmatic.load() {
  __bashmatic.prerequisites
  __bashmatic.parse-arguments "$@"
  ((BASHMATIC_HELP)) && __bashmatic.init-help && return 1
  __bashmatic.eval-library
  __bashmatic.init-core

  return 0
}

function pfx() {
  printf "      ${txtgrn}${txtblk}${bakgrn}  BashMatic™ ${txtblk}${bakylw} $(date.now.humanized) ${clr}${txtylw} ${clr}"
}

function os.info() {
  source "${BASHMATIC_HOME}/platform/os.bash"
  os.determine-system-type && os.print-system-type
}

function os.yaml() {
  source "${BASHMATIC_HOME}/platform/os.bash"
  command -v yq >/dev/null || brew install yq -q
  os.determine-system-type && os.print-system-yaml  | yq eval
}

#———————————————————————————————————————————————————————————————————————————
# Main Flow
#———————————————————————————————————————————————————————————————————————————


# resolve BASHMATIC_HOME if necessary
__bashmatic.prerequisites
__bashmatic.banner false
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

# grab our shell command
export SHELL_COMMAND="$(/bin/ps -p $$ -o args | ${GREP_CMD} -v -E 'ARGS|COMMAND' | /usr/bin/cut -d ' ' -f 1 | sed -E 's/-//g')"

bashmatic.load "$@"
source ${BASHMATIC_HOME}/lib/runtime.sh
