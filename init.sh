#!/usr/bin/env bash

# vim: ft=sh

#——————————————————————————————————————————————————————————————————————————————————
# BASH and ZSH compatible init
#————————————————————————————————————————————————————————— —————————————————————————
set +e

export _bashmatic_is_zsh=0
export _bashmatic_user_shell="$(ps -c -o command -p $$ | tail -1)"
[[ ${_bashmatic_user_shell} == "zsh" ]] && _bashmatic_is_zsh=1

export BASHMATIC_INIT="${BASH_SOURCE[0]:-${(%):-%x}}"
export BASHMATIC_HOME="$(cd "$(dirname "${BASHMATIC_INIT}")" || exit 1; pwd -P)"

[[ -s ${BASHMATIC_HOME}/init.sh ]] && export BASHMATIC_INIT="${BASHMATIC_HOME}/init.sh"

export BASHMATIC_VERSION="$(cat "${BASHMATIC_HOME}/.version" 2>/dev/null || '0.0.0')"
export PATH="${PATH}:${BASHMATIC_HOME}/bin"

export _bashmatic_downloader
[[ -z ${_bashmatic__downloader} && -n $(command -v curl) ]] &&
  export _bashmatic__downloader="curl -fsSL --connect-timeout 5 "

[[ -z ${_bashmatic__downloader} && -n $(command -v wget) ]] &&
  export _bashmatic__downloader="wget -q -O --connect-timeout=5 - "


#——————————————————————————————————————————————————————————————————————————————————
# initialize everthing
#——————————————————————————————————————————————————————————————————————————————————
function bashmatic.init.configure() {
  export _bashmatic_os="$(uname -s)"
  # External Dependency
  export _bashmatic_url="https://github.com/kigster/bashmatic"
  # Detect the locaton
  export _bashmatic_grep="$(command -v) -E -e "
  export _bashmatic_quiet=1

  if [[ -d "${BASHMATIC_HOME}" && -s "${BASHMATIC_INIT}" ]]; then
    export _bashmatic_lib="${BASHMATIC_HOME}/lib"
    [[ -n ${BASHMATIC_DEBUG} ]] && {
      source "${_bashmatic_lib}/unix/time.sh"
      export _bashmatic_loader_start=$(millis) 
    }
  fi
}

function .bashmatic.init.error() {
    echo  
    printf  "\e[1;41m  ⛔️ ERROR:                                                            \e[0m\n"
    printf  "\e[1;41m  🙁 Bashmatic appears to be broken, init.sh file was not found:       \e[0m\n"
    printf  "\e[1;44m     BASHMATIC_HOME=$(printf "%30.30s" ${BASHMATIC_HOME})\e[0m\n\n"
    return 1
}

function bashmatic.init.setup() {
  [[  -d "${BASHMATIC_HOME}/lib" ]] || {
    printf "\e[1;31mUnable to establish Bashmatic's library source folder.\e[0m\n"
    return 1
  }

  [[ -z "${_bashmatic_library_cache[*]}" ]] && bashmatic.cache.reset

  # for file in "${BASHMATIC_HOME}/lib/ux/output.sh" "${BASHMATIC_HOME}/lib/types/array.sh"; do
  #   source "${file}"
  #   bashmatic.cache.add-file "${file}"
  # done

  bashmatic.source-dir "${_bashmatic_lib}"
  [[ -d "${BASHMATIC_HOME}/.git" ]] && bashmatic.auto-update
}

function .bashmatic.init.extra.reload() {
  bashmatic.cache.reset
}

function .bashmatic.init.extra.debug() {
  export BASHMATIC_DEBUG=1
}

function bashmatic.init.main() {
  bashmatic.init.configure

  source "${BASHMATIC_HOME}/lib/internal/bashmatic.sh" 
  echo a
  # bashmatic.source \
  source "${BASHMATIC_HOME}/lib/ux/output.sh"
  source "${BASHMATIC_HOME}/lib/types/array.sh"
  source "${BASHMATIC_HOME}/lib/utilities/util.sh"
  source "${BASHMATIC_HOME}/lib/git/git.sh"
  source "${BASHMATIC_HOME}/lib/dsl/is.sh"
  echo b

  # This allows passing various module initializers from the outside, for instance
  #   $ source ~/.bashmatic/init.sh force-reload
  # as long as the function `bashmatic.init.force-reload` has been defined.

  for extra in "$@"; do
    local func=".bashmatic.init.extra.${extra}"
    is.a-function "${func}" && {
      ${func}
      continue
    }
    warning "Argument ${extra} was not recognized, and is ignored."
  done
    
  bashmatic.init.setup

  if [[ -n ${BASHMATIC_DEBUG} ]]; then
    end=$(millis)
    attention "Bashmatic Library took $((end - start)) milliseconds to load."
  fi
}

bashmatic.init.main "$@"

