#!/usr/bin/env bash
# vi: ft=sh
#
# Public Functions
#

bashmatic.reload() {
  source "${BASHMATIC_INIT}"
}

bashmatic.version() {
  cat $(dirname "${BASHMATIC_INIT}")/.version
}

bashmatic.load-at-login() {
  local init_file="${1}"
  local -a init_files=(~/.bashrc ~/.bash_profile ~/.profile)

  [[ -n "${init_file}" && -f "${init_file}" ]] && init_files=("${init_file}")

  for file in "${init_files[@]}"; do
    if [[ -f "${file}" ]]; then
      grep -q bashmatic "${file}" && {
        success "BashMatic is already loaded from ${bldblu}${file}"
        return 0
      }
      grep -q bashmatic "${file}" || {
        h2 "Adding BashMatic auto-loader to ${bldgrn}${file}..."
        echo "source ${BASHMATIC_HOME}/init.sh" >>"${file}"
      }
      source "${file}"
      break
    fi
  done
}

bashmatic.functions-from() {
  local pattern="${1}"

  [[ -n ${pattern} ]] && shift
  [[ -z ${pattern} ]] && pattern="[a-z]*.sh"

  cd "${BASHMATIC_HOME}" >/dev/null || return 1

  export SCREEN_WIDTH=$(screen-width)

  if [[ ! ${pattern} =~ "*" && ! ${pattern} =~ ".sh" ]]; then
    pattern="${pattern}.sh"
  fi

  ${GrepCommand} '^[_a-zA-Z0-9]+.*\(\)' lib/${pattern} |
    sedx 's/^lib\/.*\.sh://g' |
    sedx 's/^function //g' |
    sedx 's/\(\) *\{.*$//g' |
    tr -d '()' |
    sedx '/^ *$/d' |
    ${GrepCommand} '^_' -v |
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
  echo "${BASH_VERSION}" | cut -d '.' -f 1
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

#——————————————————————————————————————————————————————
# CACHING
#——————————————————————————————————————————————————————

bashmatic.cache.has-file() {
  local file="$1"
  bashmatic.bash.version-four-or-later || return 1
  test -z "$file" && return 1
  if [[ -n "$1" && -n "${BashMatic__LoadCache["${file}"]}" ]]; then
    return 0
  else
    return 1
  fi
}

bashmatic.cache.add-file() {
  bashmatic.bash.version-four-or-later || return 1
  [[ -n "${1}" ]] && BashMatic__LoadCache[${1}]=true
}

bashmatic.cache.list() {
  bashmatic.bash.version-four-or-later || return 1
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
    if ! bashmatic.cache.has-file "${file}"; then
      [[ -n ${DEBUG} ]] && printf "${txtcyn}[source] ${bldylw}${file}${clr}...\n" >&2
      set +e
      # shellcheck disable=SC1090
      source "${file}"
      bashmatic.cache.add-file "${file}"
    else
      [[ -n ${DEBUG} ]] && printf "${txtgrn}[cached] ${bldblu}${file}${clr} \n" >&2
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

bashmatic.setup() {

  [[ -z ${BashMatic__Downloader} && -n $(command -v curl) ]] &&
    export BashMatic__Downloader="curl -fsSL --connect-timeout 5 "

  [[ -z ${BashMatic__Downloader} && -n $(command -v wget) ]] &&
    export BashMatic__Downloader="wget -q -O --connect-timeout=5 - "

  if [[ ! -d "${BASHMATIC_LIBDIR}" ]]; then
    printf "\e[1;31mUnable to establish BashMatic's library source folder.\e[0m\n"
    return 1
  fi

  bashmatic.source util.sh git.sh file.sh color.sh
  bashmatic.source-dir "${BASHMATIC_LIBDIR}"
  [[ -d ${BASHMATIC_HOME}/.git ]] && bashmatic.auto-update
}
