#!/usr/bin/env bash
# vi: ft=sh
#
# Public Functions

# True if .envrc.local file is present. We take it as a sign
# you may be developing bashmatic.

export __bashmatic_warning_notification=${BASHMATIC_HOME}/.developer-warned
export __bashmatic_library_last_sourced=${BASHMATIC_HOME}/.last-loaded

export BASHMATIC_OS="${BASHMATIC_OS_NAME}"

# shellcheck source=./time.sh
[[ -n $(type millis 2>/dev/null) ]] || source "${BASHMATIC_LIB}/time.sh"

# shellcheck source=./output.sh
[[ -n $(type output.is-tty 2>/dev/null) ]] || source "${BASHMATIC_LIB}/output.sh"
#
# shellcheck source=./file.sh
[[ -n $(type file.last-modified-millis 2>/dev/null) ]] || source "${BASHMATIC_LIB}/file.sh"

function bashmatic.cd-into() {
 [[ -d ${BASHMATIC_HOME} ]] || return 1
 cd "${BASHMATIC_HOME}" || exit 1
}

function bashmatic.current-os() {
  printf "%s" "${BASHMATIC_OS}"
}

# @description True if .envrc.local file is present. We take it as a sign
#              you may be developing bashmatic.
function bashmatic.is-developer() {
  [[ ${BASHMATIC_DEVELOPER} -eq 1 || -f ${BASHMATIC_HOME}/.envrc.local ]]
}

function bashmatic.debug-on() {
  export DEBUG=1
  export BASHMATIC_DEBUG=1
  export BASHMATIC_PATH_DEBUG=1
}

function bashmatic.debug-off() {
  unset DEBUG
  unset BASHMATIC_DEBUG
  unset BASHMATIC_PATH_DEBUG
}

function __bashmatic.set-is-not-loaded() {
  unset BASHMATIC_LOADED
}

function bashmatic.reload() {
  __bashmatic.set-is-not-loaded
  # shellcheck source=./../.envrc.no-debug
  [[ -f "${BASHMATIC_HOME}/.envrc.no-debug" ]] && source "${BASHMATIC_HOME}/.envrc.no-debug"
  # shellcheck source=./../init.sh
  source "${BASHMATIC_INIT}" --reload
}

function bashmatic.reload-debug() {
  __bashmatic.set-is-not-loaded
  # shellcheck source=./../.envrc.debug
  source "${BASHMATIC_HOME}/.envrc.debug"
  # shellcheck source=./../init.sh
  source "${BASHMATIC_INIT}" --reload
}

function bashmatic.version() {
  cat "$(dirname "${BASHMATIC_INIT}")/.version"
}

function bashmatic.load-at-login() {
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

function bashmatic.functions-from() {
  local pattern="${1}"

  [[ -n ${pattern} ]] && shift
  [[ -z ${pattern} ]] && pattern="[a-z]*.sh"

  cd "${BASHMATIC_HOME}/lib" >/dev/null || return 1

  local screen_width=$(screen.width.actual)

  if [[ -n $(echo "${pattern}" | eval "${GrepCommand} '\*$' ") || ! ${pattern} =~ \.sh$ ]]; then
    pattern="${pattern}.sh"
  fi

  eval "${GrepCommand} '^[_a-zA-Z0-9]+.*\(\)' ${pattern}" |
    sedx 's/^(lib\/)?.*\.sh://g' |
    sedx 's/^function //g' |
    sedx 's/\(\) *\{.*$//g' |
    /usr/bin/tr -d '()' |
    sedx '/^ *$/d' |
    eval  "${GrepCommand} '^(_|\.)' -v" |
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
  echo "${BASH_VERSION:0:1}"
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

function __rnd() {
  echo -n $(( (1009 * RANDOM) % 44311 + (917 * RANDOM) % 34411 ))
}

bashmatic.bash.version-four-or-later && {
  [[ ${#load_cache[@]} -gt 0 ]] || {
    ${GLOBAL} -A load_cache
    load_cache=()
  }
}

function bashmatic.reset.cache() {
  unset load_cache
  bashmatic.bash.version-four-or-later && {
    ${GLOBAL} -A load_cache
    load_cache=()
  }
  rm -f "${__bashmatic_library_last_sourced}"
}

function bashmatic.source() {
  local __path="${BASHMATIC_LIB}"
  local file
  local total=0
  local files=0

  local last_loaded_at=0
  [[ -f ${__bashmatic_library_last_sourced} ]] && last_loaded_at=$(cat "${__bashmatic_library_last_sourced}")

  for file in "${@}"; do
    local t1=$(millis)

    [[ "${file}" =~ "/" ]] || file="${__path}/${file}"

    bashmatic.bash.version-four-or-later && {
      local cached_at=${load_cache[${file}]}
      cached_at=${cached_at:-0}
      local modified_at="$(file.last-modified-millis "${file}")"
      [[ ${modified_at} -le ${cached_at} && ${modified_at} -le ${last_loaded_at} ]] && {
        is-debug && printf -- "${bldred} (cached)    ${txtgrn} ▶︎ %s${clr}\n" "${file/\/*\//}"
        continue
      }
    }

    [[ -s "${file}" ]] || {
      .err "Can't source file ${file} — fils is invalid."
      return 1
    }

    if [[ -n ${SOURCE_DEBUG} || ${DEBUG} -eq 1 ]]; then
      is-debug && printf -- "             ${txtylw} ▶︎ %s${clr}" "${file/\/*\//}"
      source "${file}" >/dev/null
      is-debug && {
        cursor.rewind -120
        local code=$?
        local t2=$(millis)
        local duration=$(( t2 - t1 ))
        total=$(( total + duration ))
        files=$(( files + 1 ))
      }

      bashmatic.bash.version-four-or-later && {
        ((code)) || load_cache[${file}]=${t1}
      }

      is-debug && {
        local color=${txtblu}
        [[ ${duration} -gt 20 ]] && color="${bldred}"
        printf "${color}${duration}ms [%3d]" "${code}"
        printf "\n"
        unset t1
        unset t2
      }
    else
      source "${file}"
    fi
  done

  bashmatic.bash.version-four-or-later && {
    # save the current timestamp into the cache marker
    [[ ${#load_cache[@]} -gt 0 ]] && millis > "${__bashmatic_library_last_sourced}"
  }

  is-debug && printf "${files} sourced in, taking ${total}ms total.\n"
  return 0
}

#——————————————————————————————————————————————————————

.err() {
  printf "${bldred}  ERROR:\n${txtred}  $*%s\n" "" >&2
}

function bashmatic.source-dir() {
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

  local -a sources=()
  for file in "${files[@]}"; do
    local n="$(basename "${file}")"
    [[ ${n:0:1} == . ]] && continue

    sources+=("${file}")
  done

  bashmatic.source "${sources[@]}"
  loaded=true

  unset files

  ${loaded} || {
    .err "Unable to find BashMatic library folder with files:" "${BASHMATIC_LIB}"
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

function bashmatic.setup() {
  [[ -z ${BashMatic__Downloader} && -n $(command -v curl) ]] &&
    export BashMatic__Downloader="curl -fsSL --connect-timeout 5 "

  [[ -z ${BashMatic__Downloader} && -n $(command -v wget) ]] &&
    export BashMatic__Downloader="wget -q -O --connect-timeout=5 - "

  if [[ ! -d "${BASHMATIC_LIB}" ]]; then
    .err "Unable to file BashMatic's library source folder — ${BASHMATIC_LIB}"
    return 1
  fi

  declare -a preload_modules=(
    time.sh
    output.sh
    output-utils.sh
    output-repeat-char.sh
    output-boxes.sh
    is.sh
    user.sh
    util.sh
    git.sh
    file.sh
    color.sh
    brew.sh
  )

  bashmatic.source "${preload_modules[@]}"
  bashmatic.shell-check || return 1
  bashmatic.source-dir "${BASHMATIC_LIB}"

  output.unconstrain-screen-width

  [[ -d ${BASHMATIC_HOME}/.git ]] && bashmatic.auto-update 1>&2 2>/dev/null

  return 0
}

export __bashmatic_auto_update_help_file="${BASHMATIC_HOME}/.auto-update-disabled"

function bashmatic.auto-update() {
  # Run in a subshell
  (
    unset -f _direnv_hook >/dev/null 2>&1
    [[ ${Bashmatic__Test} -eq 1 ]] && return 0
    local pwd="$(pwd -P)"
    cd "${BASHMATIC_HOME:="${HOME}/.bashmatic"}" || exit
    git.configure-auto-updates
    git.repo-is-clean || {
      output.is-ssh || {
        output.is-terminal && bashmatic.auto-update-error
        cd "${pwd}" >/dev/null || exit
        return 1
      }
    }

    git.update-repo-if-needed
    cd "${pwd}" >/dev/null || exit
  )
}

function bashmatic.auto-update-error() {
  bashmatic.is-developer || return
  file.exists-and-newer-than "${__bashmatic_warning_notification}" 10 || return
  touch "${__bashmatic_warning_notification}"

  if [[ -f ${__bashmatic_auto_update_help_file} ]]; then
    cat "${__bashmatic_auto_update_help_file}" >&2
  else
    output.constrain-screen-width 60
    box.black-on-yellow \
        "${bldwht}Warning! BASHMATIC_HOME contains local modifications." \
        "Automatic update is disabled until git state is clean again." |
        tee -a "${__bashmatic_auto_update_help_file}" >&2
  fi
}

# @description This function returns 1 if bashmatic is installed in the 
#              location pointed to by ${BASHMATIC_HOME} or the first argument.
# @arg $1      The location to check for bashmatic instead of ${BASHMATIC_HOME}
function bashmatic.is-installed() {
  # shellcheck disable=SC2031
  export bashmatic_home="${1:-"${BASHMATIC_HOME}"}"
  export bashmatic_min_functions=917

  set +e
  /usr/bin/env bash -c "\
    [[ -x \${bashmatic_home}/init.sh ]] || exit 1
    source \${bashmatic_home}/init.sh >/dev/null 2>/dev/null; \
    declare -i total; \
    type bashmatic.functions 2>/dev/null | grep -q function || exit 2; \
    total=\$(bashmatic.functions 1 | wc -l | sed -E 's/[ \\t]*//g'); \
    if [[ \${total} -ge \${bashmatic_min_functions} ]]; then \
      exit 0; \
    else \
      exit 3; \
    fi \
  "

  local code=$?
  return ${code}
}




