#!/usr/bin/env bash

function puts() {
  printf "  ⇨ ${txtwht}$*${clr}"
}

function okay() {
  printf -- " ${txtblk}${bakgrn} ✓ ${clr}   ❯ ${clr}${italic}${bldcyn}$*${clr} ❯ ${bldgrn} ALL GOOD, YO 👍  ${clr}" >&2
  echo
}

function note() {
  printf -- "\n${bldwht}${bakblu}  « NOTE »  ${clr} ${bldwht} ✔  ${bldgrn}$*${clr}" >&2
  printf -- "\n\n" >&2
}

function success() {
  printf -- "\n${txtblk}${bakgrn}  « SUCCESS »  ${clr} ${bldwht} ✔  ${bldgrn}$*${clr}" >&2
  printf -- "\n\n" >&2
}

function skipping() {
  printf -- "\n${bldwht}${bakcyn}  « SKIPPING »  ${clr} ${bldwht} ✔  ${bldgrn}$*${clr}" >&2
  printf -- "\n\n" >&2
}

function abort() {
  echo
  printf -- "${LibOutput__LeftPrefix}${txtblk}${bakred}  « ABORT »  ${clr} ${bldwht} ✔  ${bldgrn}$*${clr}" >&2
  echo
}

function err() {
  echo
  printf -- "${LibOutput__LeftPrefix}${bldylw}${bakred}  « ERROR! »  ${clr} ${bldwht}$*${clr}" >&2
  echo
}

function ask() {
  printf -- "%s${txtylw}$*${clr}\n" "${LibOutput__LeftPrefix}"
  printf -- "%s${bldgrn}❯ ${bldylw}" "${LibOutput__LeftPrefix}"
}

function inf() {
  printf -- "${LibOutput__LeftPrefix}${clr}${txtcyn}$*${clr}"
}

function info-debug() {
  [[ -z ${BASHMATIC_DEBUG} ]] && return
  printf -- "${LibOutput__LeftPrefix}${bakpur}[ debug ] $*  ${clr}\n"
}

function warn() {
  printf -- "${LibOutput__LeftPrefix}${bldwht}${bakylw} « WARNING! » ${clr} ${bldylw}$*${clr}" >&2
}

function warning() {
  local first="$1"
  shift
  box.black-on-yellow "${header} ${clr}${txtblk}${bakylw} — $first" "$@" >&2
}

function br() {
  echo
}

function info() {
  inf "$@"
  echo
}

function error-title() {
  title-red "$(printf "%60.60s" "──── ERROR ───")" "$@"
}

function error() {
  panel-error "ERROR" "$@"
}

function fatal() {
  header=$(printf -- "${clr}${bldwht}  « ABORT » ")
  box.black-on-red "${header} ${clr}${txtblk}${bakred} — $1" "${@:2}" >&2
  exit 1
}

function info:() {
  inf "$*"
  ui.closer.ok:
}

function error:() {
  err "$*"
  ui.closer.not-ok:
}

function warning:() {
  warn "$*"
  ui.closer.kind-of-ok:
}

function shutdown() {
  local message=${1:-"Shutting down..."}
  echo
  box.red-in-red "${message}"
  echo
  exit 1
}

function reset-color() {
  printf "${clr}\n"
}

function reset-color:() {
  printf "${clr}"
}

function columnize() {
  local columns="${1:-2}"
  [[ -n $1 ]] && shift
  local sw="${2:-$(screen.width.actual)}"
  [[ ${sw} -lt 90 ]] && sw=100
  pr -l 10000 -"${columns}" -e4 -w ${sw} |
    expand -8 |
    sed -E '/^ *$/d' |
    grep -v 'Page '
}

function dbg-on() {
  export BASHMATIC_DEBUG=1
  [[ -f ${BASHMATIC_HOME}/.envrc.debug ]] && source "${BASHMATIC_HOME}"/.envrc.debug
}

function dbg-off() {
  unset BASHMATIC_DEBUG
  unset BASHMATIC_PATH_DEBUG
  [[ -f ${BASHMATIC_HOME}/.envrc.no-debug ]] && source "${BASHMATIC_HOME}"/.envrc.no-debug
}

# @description Checks if we have debug mode enabled
function is-dbg() {
  [[ -n ${BASHMATIC_DEBUG} ]]
}

# @description Local debugging helper, activate it with `export BASHMATIC_DEBUG=1`
function dbg() {
  is-dbg && printf "     ${txtgrn}[DEBUG | ${txtylw}$(time.now.with-ms)${txtgrn}]  ${txtblu}$(txt-info)$*\n" >&2
  return 0
}

function dbgf() {
  local func="$1"
  shift
  is.a-function "${func}" || {
    error "${func} is not a function"
    return 1
  }

  dbg "${func}(" "$@" ")"
  ${func} "$@"
  local code=$?

  is-dbg || return "${code}"

  cursor.up 1
  cursor.at.x 0
  if [[ ${code} -eq 0 ]]; then
    ok:
  else
    not-ok:
  fi
  return ${code}
}



