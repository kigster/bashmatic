#!/usr/bin/env bash
# vim: ft=bash
#
# @file util.sh
# @description Miscellaneous utilities.

# @description Convert STDIN using rot13
#
# @example
#    echo "test" | util.rot13-stdin
#
# @requires A working Ruby installation.


declare __bashmatic_uname_binary
export __bashmatic_uname_binary

#
# @description
#   Finds the exact absolute path of the `uname` utility on a unix file system.
#
# @returns
#   Aborts the process if none are found.
function system.uname() {
  command -v uname && return 0

  [[ -x ${__bashmatic_uname_binary} && -x ${__bashmatic_uname_binary} ]] && {
    echo ${__bashmatic_uname_binary}
    return 0
  }

  local -a uname_options=( "/bin/uname" "/usr/bin/uname" "/sbin/uname" "/usr/sbin/uname" )
  local binary

  for binary in ${uname_options[@]} ; do
    [[ -x ${binary} ]] && {
      export __bashmatic_uname_binary="$(printf -- "%s" "${binary}")"
      printf "%s" "${__bashmatic_uname_binary}"
      return 0
    }
  done

  return 1
}

#declare -r -g BASHMATIC_OS_NAME

function system.save-os-name() {
  local _os=""
  __os="$($(system.uname) -s | tr '[:upper:]' '[:lower:]' | tr -d '\n')"
  [[ -z "${BASHMATIC_OS_NAME}" ]] && export BASHMATIC_OS_NAME="${__os}" >/dev/null 2>&1
  export BASHMASTIC_OS="${BASHMATIC_OS_NAME}"
}

source "${BASHMATIC_HOME}/lib/sedx.sh"

function util.rot13-stdin() {
  ruby -e 'puts STDIN.read.
  tr(
    "0123456789",
    "5678901234").
  tr(
    "abcdefghijklmnopqrstuvwxyz",
    "nopqrstuvwxyzabcdefghijklm").
  tr(
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    "NOPQRSTUVWXYZABCDEFGHIJKLM")'
}

# usage: util.rot13 "string"
#    or: rot13 "string"
function util.rot13() {
  local value="$*"
  echo "$value" | util.rot13-stdin
}

alias rot13=util.rot13
__grep="${GrepCommand/ */}"
[[ -n ${__grep} && -x ${__grep} ]] || {
  export GrepCommand="$(command -v grep) -E"
}

function util.is-variable-defined() {
  local var_name="$1"
  [[ ${!var_name+x} ]]
}

# @description Generates a random number up to 1000000
function util.random-number() {
  local limit="${1:-"1000000"}" # maxinum number
  printf $(((RANDOM % limit)))
}

# @description Generates a password of a given length
function util.generate-password() {
  local len=${1:-32}
  local val=$(($(date '+%s') - 100000 * RANDOM))
  [[ ${val:0:1} == "-" ]] && val=${val/-//}
  printf "$(echo ${val} | shasum -a 512 | awk '{print $1}' | base64 | head -c "${len}")"
}

# @description Generates a random string of a given length
function util.random-string.of-length() {
  util.generate-password "$@"
}

function util.ver-to-i() {
  version=${1}
  echo "${version}" | awk 'BEGIN{FS="."}{ printf "1%02d%03.3d%03.3d", $1, $2, $3}'
}

# Convert a result of .ver-to-i() back to a regular version.
function util.i-to-ver() {
  version=${1}
  /usr/bin/env ruby -e "ver='${version}'; printf %Q{%d.%d.%d}, ver[1..2].to_i, ver[3..5].to_i, ver[6..8].to_i"
}

function util.os() {
  export BASHMATIC_OS="${BASHMATIC_OS_NAME:=$(uname -s | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')}"
  export BASHMATIC_OS_NAME
}

function util.arch() {
  echo -n "${BASHMATIC_OS}-$($(system.uname) -m)-$($(system.uname) -p)" | /usr/bin/tr '[:upper:]' '[:lower:]'
}

# shellcheck disable=SC2120
function util.shell-init-files() {
  local shell_function="${1:-"user.login-shell"}"
  local shell_name=$(${shell_function})

  if [[ ${shell_name} == "bash" ]]; then
    echo "${HOME}/.bash_profile ${HOME}/.bash_login ${HOME}/.bashrc ${HOME}/.profile"
  elif [[ ${shell_name} == "zsh" ]]; then
    echo "${HOME}/.zshrc"
  else
    error "Shell ${shell_name} is not supported."
    return 1
  fi
}

function util.append-to-init-files() {
  local string="$1"       # what to append
  local search="${2:-$1}" # what to grep for

  is_installed=

  declare -a shell_files=($(util.shell-init-files))
  for init_file in "${shell_files[@]}"; do
    file="${init_file}"
    [[ -f ${file} ]] && grep -q "${search}" "${file}" && {
      is_installed=${file}
      break
    }
  done

  if [[ -z "${is_installed}" ]]; then
    for init_file in "${shell_files[@]}"; do
      file="${init_file}"
      [[ -f ${file} ]] && {
        echo "${string}" >>"${file}"
        is_installed="${file}"
        break
      }
    done
  fi

  printf "${is_installed}"
}

# Description:
#   This function checks BASH init files one by one for a given string.
#   It then removes all lines matching that string from those files.
#
# Usage:
#   util.remove-froj-init-files direnv
#
# Will remove all lines matching direnv from all Bash init files.
#
function util.remove-from-init-files() {
  local search="${1}" # lines matching this will be deleted
  local backup_extension="${2}"

  [[ -z ${backup_extension} ]] && backup_extension="$(epoch).backup"

  [[ -z ${search} ]] && return

  declare -a shell_files=($(util.shell-init-files))
  local temp_holder=$(mktemp)
  for init_file in "${shell_files[@]}"; do
    run.config.detail-is-enabled && inf "verifying file ${init_file}..."
    file="${init_file}"
    if [[ -f ${file} ]] && grep -q  "${search}" "${file}" ; then
      run.config.detail-is-enabled && ui.closer.ok:
      local matches=$(grep -c "${search}" "${file}")
      run.config.detail-is-enabled && info "file ${init_file} matches with ${bldylw}${matches} matches"

      run "grep -v \"${search}\" ${file} > ${temp_holder}"
      if [[ -n "${backup_extension}" ]]; then
        local backup="${file}.${backup_extension}"

        run.config.detail-is-enabled && info "backup file will created in ${bldylw}${backup}"
        [[ -n "${do_backup_changes}" ]] && "mv ${file} ${backup}"
      fi
      run "cp -v ${temp_holder} ${file}"
    else
      run.config.detail-is-enabled && ui.closer.not-ok:
    fi
  done
  return "${LibRun__LastExitCode}"
}

function util.is-a-function() {
  is.a-function "$@"
}

function is-func() {
  is.a-function "$@"
}

function util.invoke-if-function() {
  local namespace="$1"
  shift
  local action="$1"
  shift

  local func="${namespace}.${action}"

  util.is-a-function "${func}" || return 255

  ${func} "$@"
}

function util.call-if-function() {
  local func="$1"
  shift
  util.is-a-function "${func}" && {
    ${func} "$@"
  }
}

function util.lines-in-folder() {
  local folder=${1:-'.'}
  find "${folder}" -type f -exec wc -l {} \; | awk 'BEGIN{a=0}{a+=$1}END{print a}'
}

function util.functions-starting-with() {
  local prefix="${1}"
  local extra_command=${2:-"cat"}
  set | ${GrepCommand} '^[^ ].* \(\) $' | ${GrepCommand} "^${prefix}" | sedx 's/[\(\)]//g;' | ${extra_command} | /usr/bin/tr '\n ' ' '
}

function util.functions-starting-with-lines() {
  local prefix="${1}"
  local extra_command=${2:-"cat"}
  set | ${GrepCommand} '^[^ ].* \(\) $' | ${GrepCommand} "^${prefix}" | sedx 's/[\(\)]//g;' | ${extra_command}
}

function util.functions-starting-with-csv() {
  local prefix="$1"
  util.functions-starting-with "${prefix}" | sedx "s/${prefix/./\\.}//g; s/\s+(\w)/, \1/g;"
}

function util.functions-matching() {
  local prefix="${1}"
  local extra_command=${2:-"cat"}
  declare -f | ${GrepCommand} "^${prefix}" | sedx 's/[\(\)]//g;' | /usr/bin/tr -d ' ' | /usr/bin/tr '\n' ' '
}

function util.functions-matching.diff() {
  while true; do
    [[ -z "$1" ]] && break
    for e in $(util.functions-matching "${1}"); do
      printf "${e/$1/}\n"
    done
    shift
  done
  return 0
}

function util.install-direnv() {
  "${BASHMATIC_HOME}/bin/install-direnv"
}

function util.eval-function-body() {
  local name="$1"; shift

  type "${name}" | grep -qi function || {
    error "${name} is not a function."
    return 1
  }

  eval "$(type "${name}" | sedx '1,3d;$d')" "$@"
}

export LibUtil__WatchRefreshSeconds="0.5"

function watch.set-refresh() {
  export LibUtil__WatchRefreshSeconds="${1:-"0.5"}"
}

function watch.ls-al() {
  while true; do
    ls -al
    sleep "${LibUtil__WatchRefreshSeconds}"
    clear
  done
}

function watch.command() {
  [[ -z "$1" ]] && return 1
  trap "return 1" SIGINT
  while true; do
    clear
    hr.colored "${txtblu}"
    printf " ❯ Command: ${bldgrn}$*${clr}  •  ${txtblu}$(date)${clr}  •  Refresh: ${bldcyn}${LibUtil__WatchRefreshSeconds}${clr}\n"
    hr.colored "${txtblu}"
    eval "$*"
    hr.colored "${txtblu}"
    printf "To change refresh rate run ${bldylw}watch.set-refresh <seconds>${clr}\n\n\n"
    sleep "${LibUtil__WatchRefreshSeconds}"
  done
}

function util.dev-setup.update() {
  run "rm -f ${BASHMATIC_HOME}/bin/.dev-setup"
  run "dev-setup -N -h > /tmp/a"
  run "mv /tmp/a ${BASHMATIC_HOME}/bin/.dev-setup"
  run "cd ${BASHMATIC_HOME} && git add bin/.dev-setup"
  run "cd -"
}

function pause() { sleep "${1:-1}"; }
function pause.medium() { sleep "${1:-0.3}"; }
function pause.short() { sleep "${1:-0.1}"; }
function pause.long() { sleep "${1:-10}"; }

function util.is-numeric() {
  is.numeric "$1"
}

function var.expand() {
 .subst "$@"
}

function .subst() {
  local var="$1"
  local shell="$(user.current-shell)"

  case $shell in
    bash)
      printf "${!var}"
      ;;
    zsh)
      printf "${(P)var}"
      ;;
    *)
      return 1
  esac
}




