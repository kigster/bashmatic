#!/usr/bin/env bash
# vim: ft=bash

#————————————————————————————————————————————————————————————————————————————————————————————————————
# Initialization and Setup
#————————————————————————————————————————————————————————————————————————————————————————————————————

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

