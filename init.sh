# vim: ft=bash

set +ex
export BASHMATIC_HOME="${BASHMATIC_HOME}"

if [[ ! -d ${BASHMATIC_HOME} || ! -f "${BASHMATIC_HOME}/init.sh" ]]; then
  export BASHMATIC_HOME="$(/usr/bin/dirname "$(cd "$(/usr/bin/dirname "${BASH_SOURCE[0]:-"${(%):-%x}"}")" || exit 1; pwd -P)")"
fi

if [[ ! -d ${BASHMATIC_HOME} || ! -f "${BASHMATIC_HOME}/init.sh" ]]; then
  export BASHMATIC_HOME="${HOME}/.bashmatic"
fi

if [[ -f "${BASHMATIC_HOME}/.bash_safe_source" ]] ; then 
  source "${BASHMATIC_HOME}/.bash_safe_source"
  cp -p  "${BASHMATIC_HOME}/.bash_safe_source" "${HOME}/.bash_safe_source" 2>/dev/null
fi

export BASHMATIC_VERSION="$(cat ${BASHMATIC_HOME}/.version | tr -d '\n')"
export BASHMATIC_PREFIX="${bakblu}${bldwht}[bashmatic® ${bldylw}${BASHMATIC_VERSION}]${clr} "

function .bashmatic.pre-init() {
  export GREP_CMD
  GREP_CMD="$(command -v /usr/bin/grep || command -v /bin/grep || command -v /usr/local/bin/grep || echo grep)"

  # Save the value of $DEBUG, but convert it to 1 in case its not.
  export __debug="${BASHMATIC_DEBUG}"
  [[ -n ${__debug} ]] && export __debug=1

  export __path_debug="${BASHMATIC_PATH_DEBUG}"
  [[ -n ${__path_debug} ]] && {
    export __path_debug=1
    printf "${itacyn}PATH before update: ${bldylw}$PATH${clr}\n"
  }
  src "${BASHMATIC_HOME}/lib/is.sh"
  src "${BASHMATIC_HOME}/lib/color.sh"
  src "${BASHMATIC_HOME}/lib/output-repeat-char.sh"
  src "${BASHMATIC_HOME}/lib/output.sh"
  src "${BASHMATIC_HOME}/lib/output-utils.sh"
  src "${BASHMATIC_HOME}/lib/output-boxes.sh"
  src "${BASHMATIC_HOME}/lib/util.sh"

  export PATH=/usr/local/bin:/usr/bin:/bin:/sbin
  for _path in /usr/local/bin /usr/bin /bin /sbin /usr/sbin /opt/local/bin ${HOME}/.rbenv/shims ${HOME}/.pyenv/shims ; do
    [[ -n ${__path_debug} ]] && printf "${BASHMATIC_PREFIX}Checking [${txtylw}%30.30s${clr}]..." "${_path}" >&2
    if [[ -d "${_path}" ]]; then
      (echo ":${PATH}:" | ${GREP_CMD} -q ":${_path}:") || {
        [[ -n ${__path_debug} ]] && printf "${bldgrn}[ ✔ ] -> ${bldcyn}prepending a new folder to ${bldylw}\$PATH${clr}.\n" >&2
        export PATH="${_path/ /\\ /}:${PATH}"
        continue
      }
      [[ -n ${__path_debug} ]] && printf "${bldgrn}[ ✔ ]${clr} ${italic}${txtgrn}already in the ${bldylw}\$PATH${clr}\n"
    else
      [[ -n ${__path_debug} ]] && printf "${bldred}[ x ]${clr} ${italic}${txtred}invalid path, does not exist.${clr}\n"
    fi
  done

  [[ ${__path_debug} -gt 0 || ${__debug} -gt 0 ]] && {
    hr; echo
    printf "${BASHMATIC_PREFIX}${bldpur}The ${bldylw}\${PATH}${bldpur} resolves to:\n"
    echo "${PATH}" | /usr/bin/tr ':' '\n  • '
    printf "${BASHMATIC_PREFIX}${bldpur}Total of${bldylw}$(echo "${PATH}" |  /usr/bin/tr ':' '\n' | wc -l | sed 's/  //g')${bldpur} folders.\n"
    hr; echo
  }

  export SHELL_COMMAND
  # deterministicaly figure out our currently loaded shell.
  SHELL_COMMAND="$(/bin/ps -p $$ -o args | ${GREP_CMD} -v -E 'ARGS|COMMAND' | /usr/bin/cut -d ' ' -f 1 | sed -E 's/-//g')"

  [[ -n "${BASHMATIC_HOME}" && -d "${BASHMATIC_HOME}" && -f "${BASHMATIC_HOME}/init.sh" ]] || {
    if [[ "${SHELL_COMMAND}" =~ zsh ]]; then
      ((__debug)) && printf "${BASHMATIC_PREFIX} Detected zsh version ${ZSH_VERSION}, source=$0:A\n"
      BASHMATIC_HOME="$(/usr/bin/dirname "$0:A")"
    elif [[ "${SHELL_COMMAND}" =~ bash ]]; then
      ((__debug)) && printf "${BASHMATIC_PREFIX} Detected bash version ${BASH_VERSION}, source=${BASH_SOURCE[0]}\n"
      BASHMATIC_HOME="$(cd -P -- "$(/usr/bin/dirname -- "${BASH_SOURCE[0]}")" && printf '%s\n' "$(pwd -P)")"
    else
      printf "${BASHMATIC_PREFIX} WARNING: Detected an unsupported shell type: ${SHELL_COMMAND}, continue.\n" >&2
      BASHMATIC_HOME="$(cd -P -- "$(/usr/bin//usr/bin/dirname -- "$0")" && printf '%s\n' "$(pwd -P)")"
    fi
  }

  export BASHMATIC_HOME

  BASHMATIC_LIBDIR="${BASHMATIC_HOME}/lib"
  export BASHMATIC_LIBDIR

  BASHMATIC_OS="$(/usr/bin/uname -s | /usr/bin/tr '[:upper:]' '[:lower:]')"
  export BASHMATIC_OS
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
  .bashmatic.pre-init

  # DEFINE CORE VARIABLES
  export BASHMATIC_URL="https://github.com/kigster/bashmatic"
  export BASHMATIC_OS="${BASHMATIC_OS}"

  # shellcheck disable=2046
  export BASHMATIC_TEMP="/tmp/${USER}/.bashmatic"
  [[ -d ${BASHMATIC_TEMP} ]] || mkdir -p "${BASHMATIC_TEMP}"

  if [[ -f ${BASHMATIC_HOME}/init.sh ]]; then
    export BASHMATIC_INIT="${BASHMATIC_HOME}/init.sh"
  else
    printf "${BASHMATIC_PREFIX}${bldred}ERROR: —> Can't determine BASHMATIC_HOME, giving up sorry!${clr}\n"
    return 1
  fi

  [[ -n ${__debug} ]] && {
    [[ -f "${BASHMATIC_HOME}/lib/time.sh" ]] && source "${BASHMATIC_HOME}/lib/time.sh"
    export __bashmatic_start_time=$(millis)
  }

  # If defined BASHMATIC_AUTOLOAD_FILES, we source these files together with BASHMATIC
  for _init in ${BASHMATIC_AUTOLOAD_FILES}; do
    [[ -s "${PWD}/${_init}" ]] && {
      [[ -n ${__debug} ]] && printf "${BASHMATIC_PREFIX} sourcing in [${bldblu}${PWD}/${_init}${clr}]"
      source "${PWD}/${_init}"
    }
  done

  for _file in $(find "${BASHMATIC_HOME}/lib" -name '[a-z]*.sh' -type f); do
    [[ -f "${_file}" ]] && {
      [[ -n ${__debug} ]] && printf "${BASHMATIC_PREFIX} sourcing in [${bldgrn}${_file}${clr}]\n"
      source "${_file}"
    }
  done

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

  ((__path_debug)) && {
    h3bg "The current \$PATH components are:"
    for p in "${paths[@]}"; do
      printf " • [$(printf "%40.40s\n" "${p}")]\n"
    done
  }
  return 0
}

function bashmatic.init() {
  for file in "$1" "$2" "$3" "$4"; do
    [[ $0 == "$1" ]] && continue 

    local env_file="${BASHMATIC_HOME}/.envrc.${file}"
    if [[ -f $env_file ]]; then
      output.is-tty && printf "${BASHMATIC_PREFIX}${bldgrn}Loading env file ${bldylw}${env_file}${clr}...\n" >&2
      source "$env_file"
    fi

    if [[ "$file" =~ (reload|force|refresh) ]]; then
      output.is-tty && printf "${BASHMATIC_PREFIX} ${bldgrn}Resetting caching...${clr}\n" >&2
      bashmatic.set-is-not-loaded
    fi
  done
  
  bashmatic.init-core  
  bashmatic.is-loaded || bashmatic.init "$@"

  local init_func=".bashmatic.init.${BASHMATIC_OS}"

  [[ -n $(type "${init_func}" 2>/dev/null) ]] && ${init_func}

  local setup_script="${BASHMATIC_LIBDIR}/bashmatic.sh"

  if [[ -s "${setup_script}" ]]; then
    source "${setup_script}"
    bashmatic.setup
    local code=$?
    ((code)) && printf "${BASHMATIC_PREFIX} Function ${bldred}bashmatic.setup${clr} returned exit code [${code}]"
  else
    echo "  ⛔️ ERROR:"
    echo "  🙁 Bashmatic appears to be broken, file not found: ${setup_script}"
    return 1
  fi

  if [[ -n ${__debug} ]]; then
    local __bashmatic_end_time=$(millis)
    notice "Bashmatic library took $((__bashmatic_end_time - __bashmatic_start_time)) milliseconds to load."
  fi

  unset __bashmatic_end_time
  unset __bashmatic_start_time

  bashmatic.set-is-loaded

  export BASHMATIC_CACHE_INIT=1
  return 0
}

bashmatic.init "$@"

