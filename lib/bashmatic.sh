#!/usr/bin/env bash
# vi: ft=sh
#
# Public Functions

# True if .envrc.local file is present. We take it as a sign 
# you may be developing bashmatic.

bashmatic.is-developer() {
  [[ ${BASHMATIC_DEVELOPER} -eq 1 || -f ${BASHMATIC_HOME}/.envrc.local ]]
}

bashmatic.reload() {
  source "${BASHMATIC_INIT}"
}

bashmatic.version() {
  cat "$(dirname "${BASHMATIC_INIT}")/.version"
}

bashmatic.load-at-login() {
  local file="${1}"
  [[ -z ${file} ]] && file="$(user.login-shell-init-file)"

  grep -q -E 'BASHMATIC_HOME' "${file}" || {
    {
      echo "export BASHMATIC_HOME=\"${BASHMATIC_HOME:-"~/.bashmatic"}\""
      echo '[[ -f ${BASHMATIC_HOME}/init.sh ]] && source ${BASHMATIC_HOME}/init.sh'
      echo 'export PATH="${PATH}:${BASHMATIC_HOME}/bin"'
    } >>"${file}"
    
    source "${file}"
  }
}

bashmatic.functions-from() {
  local pattern="${1}"

  [[ -n ${pattern} ]] && shift
  [[ -z ${pattern} ]] && pattern="[a-z]*.sh"

  cd "${BASHMATIC_HOME}/lib" >/dev/null || return 1

  export SCREEN_WIDTH=$(screen-width)

  if [[ ! ${pattern} =~ * && ! ${pattern} =~ .sh$ ]]; then
    pattern="${pattern}.sh"
  fi

  ${GrepCommand} '^[_a-zA-Z0-9]+.*\(\)' ${pattern} |
    sedx 's/^(lib\/)?.*\.sh://g' |
    sedx 's/^function //g' |
    sedx 's/\(\) *\{.*$//g' |
    tr -d '()' |
    sedx '/^ *$/d' |
    ${GrepCommand} '^(_|\.)' -v |
    sort |
    uniq |
    columnize "$@"

  cd - >/dev/null || return 1
}

# pass number of columns to print, default is 2
bashmatic.functions() {
  bashmatic.functions-from '*.sh' "$@"
}

bashmatic.functions.output() {
  bashmatic.functions-from 'output.sh' "$@"
}

bashmatic.functions.runtime() {
  bashmatic.functions-from 'run*.sh' "$@"
}

# Setup
bashmatic.bash.version() {
  echo "${BASH_VERSION/[^0-9]*/}"
}

bashmatic.bash.version-four-or-later() {
  [[ $(bashmatic.bash.version) -gt 3 ]]
}

bashmatic.bash.exit-unless-version-four-or-later() {
  bashmatic.bash.version-four-or-later || {
    error "Sorry, this functionality requires BASH version 4 or later."
    exit 1 >/dev/null
  }
}

CacheEnabled=0

#——————————————————————————————————————————————————————
# CACHING
#——————————————————————————————————————————————————————
function bashmatic.cache.init() {
  return
  if bashmatic.bash.version-four-or-later ; then
    declare -A BashMatic__LoadCache 2>/dev/null
    export BashMatic__LoadCache
  else 
    CacheEnabled=0
  fi

}

bashmatic.cache.has-file() {
  ((CacheEnabled)) || return 1
  local file="$1"
  test -z "$file" && return 1
  if [[ -n "$1" && -n "${BashMatic__LoadCache["${file}"]}" ]]; then
    return 0
  else
    return 1
  fi
}

bashmatic.cache.add-file() {
  ((CacheEnabled)) || return
  [[ -n "${1}" ]] && BashMatic__LoadCache[${1}]=true
}

bashmatic.cache.list() {
  ((CacheEnabled)) || return
  for f in "${!BashMatic__LoadCache[@]}"; do echo $f; done
}

bashmatic.source() {
  local path="${BASHMATIC_LIBDIR}"
  for file in "${@}"; do
    [[ "${file}" =~ "/" ]] || file="${path}/${file}"
    [[ -s "${file}" ]] || {
      echo "Can't source file ${file} — fils is invalid."
      return 1
    }
    # avoid sourcing the same file twice
    if [[ ${CacheEnabled} -eq 0 ]]; then
      [[ -n ${DEBUG} ]] && printf "${txtred}[source] ${bldylw}${file}${clr}...\n" >&2
      source "${file}"
    elif bashmatic.cache.has-file "${file}"; then
      [[ -n ${DEBUG} ]] && printf "${txtgrn}[cached] ${bldblu}${file}${clr} \n" >&2
    else
      [[ -n ${DEBUG} ]] && printf "${txtcyn}[source] ${bldylw}${file}${clr}...\n" >&2
      set +e
      # shellcheck disable=SC1090
      source "${file}"
      bashmatic.cache.add-file "${file}"
    fi
  done
  return 0
}

#——————————————————————————————————————————————————————

.err() {
  printf "${bldred}  ERROR:\n${txtred}  $*%s\n" ""
}

bashmatic.source-dir() {
  local folder="${1}"
  local loaded=false
  local file

  # Let's list all lib files
  unset files
  declare -a files
  eval "$(files.map.shell-scripts "${folder}" files)"
  if [[ ${#files[@]} -eq 0 ]]; then
    .err "No files were returned from files.map in " "\n  ${bldylw}${folder}"
    return 1
  fi

  for file in "${files[@]}"; do
    bashmatic.source "${file}" && loaded=true
  done

  unset files

  ${loaded} || {
    .err "Unable to find BashMatic library folder with files:" "${BASHMATIC_LIBDIR}"
    return 1
  }

  if [[ ${LoadedShown} -eq 0 ]]; then
    hr
    success "BashMatic was loaded! Happy Bashing :) "
    hr
    export LoadedShown=1
  fi
}

function bashmatic.shell-check() {
  local shell="$(user.current-shell)"
  if [[ "${shell}" =~ bash$ || "${shell}" =~ zsh$ ]]; then
    return 0
  else
    cat "${BASHMATIC_HOME}/.init.sh" >&2
    return 120
  fi
}

bashmatic.setup() {
  bashmatic.cache.init
  bashmatic.shell-check || return 1

  [[ -z ${BashMatic__Downloader} && -n $(command -v curl) ]] &&
    export BashMatic__Downloader="curl -fsSL --connect-timeout 5 "

  [[ -z ${BashMatic__Downloader} && -n $(command -v wget) ]] &&
    export BashMatic__Downloader="wget -q -O --connect-timeout=5 - "

  if [[ ! -d "${BASHMATIC_LIBDIR}" ]]; then
    printf "\e[1;31mUnable to establish BashMatic's library source folder.\e[0m\n"
    return 1
  fi

  bashmatic.source is.sh output.sh util.sh git.sh file.sh color.sh brew.sh
  bashmatic.source-dir "${BASHMATIC_LIBDIR}"
  [[ -d ${BASHMATIC_HOME}/.git ]] && bashmatic.auto-update
}



