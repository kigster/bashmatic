#!/usr/bin/env bash

function puts() {
  printf "  ⇨ ${txtwht}$*${clr}"
}

function okay() {
  printf -- " ${bldgrn} ✓ ALL OK 👍  $*${clr}" >&2
  echo
}

function success() {
  printf -- "\n${LibOutput__LeftPrefix}${txtblk}${bakgrn}  « SUCCESS »  ${clr} ${bldwht} ✔  ${bldgrn}$*${clr}" >&2
  printf -- "\n\n" >&2
}

function abort() {
  printf -- "${LibOutput__LeftPrefix}${txtblk}${bakred}  « ABORT »  ${clr} ${bldwht} ✔  ${bldgrn}$*${clr}" >&2
  echo
}

function err() {
  printf -- "${LibOutput__LeftPrefix}${bldylw}${bakred}  « ERROR! »  ${clr} ${bldred}$*${clr}" >&2
}

function ask() {
  printf -- "%s${txtylw}$*${clr}\n" "${LibOutput__LeftPrefix}"
  printf -- "%s${txtylw}❯ ${bldwht}" "${LibOutput__LeftPrefix}"
}

function inf() {
  printf -- "${LibOutput__LeftPrefix}${clr}${txtcyn}$*${clr}"
}

function info-debug() {
  [[ -z ${DEBUG} ]] && return
  printf -- "${LibOutput__LeftPrefix}${bakpur}[ debug ] $*  ${clr}\n"
}

function warn() {
  printf -- "${LibOutput__LeftPrefix}${bldwht}${bakylw} « WARNING! » ${clr} ${bldylw}$*${clr}" >&2
}

function warning() {
  header=$(printf -- "${clr}${txtylw}  « WARNING » ")
  local first="$1"
  shift
  box.black-on-yellow "${header} ${clr}${txtblk}${bakylw} — $first" "$@" >&2
}

function br() {
  echo
}

function info() {
  inf $@
  echo
}

function error() {
  header=$(printf -- "${clr}${txtred}  « ERROR » ")
  box.white-on-red "${header} ${clr}${txtblk}${bakred} — $1" "${@:2}" >&2
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

  local sw=${SCREEN_WIDTH:-120}
  [[ -z ${sw} ]] && sw=$(screen-width)

  pr -l 10000 -${columns} -e4 -w ${sw} |
    expand -8 |
    sed -E '/^ *$/d' |
    grep -v 'Page '
}

function dbg-on() {
  export DEBUG=$(time.now.db)
}

function dbg-off() {
  unset DEBUG
}

# @description Checks if we have debug mode enabled
function is-dbg() {
  [[ -n $DEBUG ]]
}

# @description Local debugging helper, activate it with DEBUG=1
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

