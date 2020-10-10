#!/usr/bin/env bash
# vi: ft=sh
#
# Public Functions
#
#——————————————————————————————————————————————————————————————————————————————————
# If the user wants us to load more, this is here:
#——————————————————————————————————————————————————————————————————————————————————

function bashmatic.preload-user-dependencies() {
  if [[ -n "$*" ]]; then
    # If defined _bashmatic_autoload_files, we source these files together with BASHMATIC
    for loader in "$@"; do
      [[ -s "${PWD}/${loader}" ]] && {
        [[ -n ${BASHMATIC_DEBUG} ]] && echo "sourcing in ${PWD}/${loader}"
        source "${PWD}/${loader}"
      }
    done
  fi
}

function bashmatic.reload() {
  source "${BASHMATIC_INIT}" "$@"
}

function bashmatic.version() {
  printf "${BASHMATIC_VERSION}"
}

function bashmatic.load-at-login() {
  local init_file="${1}"
  local -a init_files=(~/.bashrc ~/.bash_profile ~/.profile ~/.zshrc)

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

function bashmatic.functions-from() {
  local pattern="${1}"

  [[ -n ${pattern} ]] && shift
  [[ -z ${pattern} ]] && pattern="[a-z]*.sh"

  cd "${_bashmatic_lib}" >/dev/null || return 1

  export SCREEN_WIDTH=$(screen-width)

  if [[ ! ${pattern} =~ * && ! ${pattern} =~ .sh$ ]]; then
    pattern="${pattern}.sh"
  fi

  ${_bashmatic_grep} '^[_a-zA-Z0-9]+.*\(\)' "${pattern}" |
    sedx 's/^lib\/*/.*\.sh://g' |
    sedx 's/^function //g' |
    sedx 's/\(\) *\{.*$//g' |
    tr -d '()' |
    sedx '/^ *$/d' |
    ${_bashmatic_grep} '^_' -v |
    sort |
    uniq |
    columnize "$@"

  cd - >/dev/null || return 1
}

# pass number of columns to print, default is 2
function bashmatic.functions() {
  bashmatic.functions-from '*.sh' "$@"
}

function bashmatic.functions.output() {
  bashmatic.functions-from 'output.sh' "$@"
}

function bashmatic.functions.runtime() {
  bashmatic.functions-from 'run*.sh' "$@"
}

# Setup
function bashmatic.bash.version() {
  echo "${BASH_VERSION}" | /usr/bin/awk '{print $1}'
}

function bashmatic.bash.version-four-or-later() {
  [[ $(bashmatic.bash.version) -gt 3 ]]
}

function bashmatic.bash.exit-unless-version-four-or-later() {
  bashmatic.bash.version-four-or-later || {
    error "Sorry, this functionality requires BASH version 4 or later."
    exit 1 >/dev/null
  }
}


#——————————————————————————————————————————————————————

.err() {
  printf "${bldred}  ERROR:\n${txtred}  $*%s\n" ""
}

bashmatic.auto-update() {
  [[ ${_bashmatic__test} -eq 1 ]] && return 0

  git.configure-auto-updates

  git.repo-is-clean || {
    output.is-ssh || {
      output.is-terminal && attention "Bashmatic folder has local changes, can't auto-update." >&2
    }
    return 1
  }

  git.sync
}

#——————————————————————————————————————————————————————
# CACHING
#——————————————————————————————————————————————————————
function bashmatic.cache.reset() {
  # this breaks on BASH v3
  unset _bashmatic_library_cache
  declare -a _bashmatic_library_cache 2>/dev/null
  export _bashmatic_library_cache=()
}

function bashmatic.cache.add-file() {
  export _bashmatic_library_cache+=("${1}")
}

function bashmatic.source-unless-cached() {
  local file="$1"
  local source="$2"
  local action

  if [[ ${source} -eq 1 ]]; then
    action="${bldpur} sourced "
    source "${file}"
  else
    action="${bldgrn}  cached "
  fi

  is-dbg && printf "${txtgrn}[ ${txtylw}$(time.now.with-ms)${txtgrn} | ${action}] file: [${txtblu}${file}${clr}]\n" >&2
  return 0
}


function bashmatic.source-and-cache() {
  local file="$1"

  local cached=0
  local source=0

  ( array.includes "${file}" "${_bashmatic_library_cache[@]}" ) && cached=1

  ((cached)) && source=0 || source=1

  bashmatic.source-unless-cached "${file}" "${source}"

  ((cached)) || bashmatic.cache.add-file "${file}"

  return 0
}

function bashmatic.source() {
  for file in "$@"; do
    [[ -s "${file}" ]] || {
      echo "file ${file} does not exist, abort."
      exit 1
    }
    bashmatic.source-and-cache "${file}"
  done
}

function bashmatic.source-dir() {
  local folder="${1}"
  shift

  local force="${1}"
  [[ ${force} -lt 100 ]] && shift

  folder="$(
    cd "${folder}" || exit 1
    pwd -P
  )"

  local loaded=0
  local file

  declare -a files
  files=($(find "${folder}" -maxdepth 2 -type f -name '*.sh'))
  if [[ "${#files[@]}" -eq 0 ]]; then
    error "Folder ${folder} produced no shell files to source?"
    return 1
  fi

  bashmatic.source "${force}" "${files[@]}" && loaded=1

  ((loaded)) || {
    .err "Unable to find BashMatic library folder with files:" "${_bashmatic_lib}"
    return 1
  }

  return 0
}
