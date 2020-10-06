#!/usr/bin/env bash
# vim: ft=bash

# @file is.sh
# @description Various validations and asserts that can be chained
# and be explicit in a DSL-like way.
# @example
#
#
#     source lib/is.sh
#     is.begin "Checking for file validity"
#     is.not-blank "$1" && is.non-empty

declare -a Bashmatic__IsErrors
declare -a Bashmatic__IsValues
export Bashmatic__IsSessionName

#------------------------------------------------------------------
# Private Helper Function
#------------------------------------------------------------------
# @description      Invoke a validation on the value, and process
#                   the invalid case using a customizable error handler.
#
# @arg1 func        Validation function name to invoke
# @arg2 var         Value under the test
# @arg4 error_func  Error function to call when validation fails
#
# @exitcode 0 if validation passes
#
function __is.validation.error() {
  local func="$1"
  local var="$2"
  local error_func="${3}"
  shift
  shift
  shift

  is.a-function "${func}" || {
    error "Invalid validation operation: ${bldylw}${func}"
    # shellcheck disable=SC2046
    h2 "Supported operations:" $(is-validations)
    return 127
  }

  # validate and exit if success
  ${func} "${var}"
  local exitcode=$?

  ((exitcode)) || return 0

  ${error_func} "${func}" "${var}" "$@"

  return "${exitcode}"
}

# @description Returns the list of validation functions available
function is-validations() {
  util.functions-matching.diff is\\. | sedx 's/^/is./g'
}

# @description Private function that ignores errors
function __is.validation.ignore-error() {
  local func="$1"
  local var="$2"
}

# @description Private function that ignores errors
function __is.validation.report-error() {
  local func="$1"
  local var="$2"
  shift
  shift
  local reason="${func/is\./}"
  reason="be ${reason/-/ }"
  if [[ -n "$*" ]]; then
    error "$@"
  else
    [[ -n ${var} ]] && var=" '${var}'"
    error "Expected${var} to ${reason}" >&2
  fi
}

#------------------------------------------------------------------
# Public API
# Part 1. supporting functions
#------------------------------------------------------------------
function validations.begin() {
  export Bashmatic__IsErrors=()
  export Bashmatic__IsValues=()
  export Bashmatic__IsSessionName="$1"
}

function validations.add-error() {
  local error="$1"
  local value="$2"
  is.not-blank "${error}" && is.not-blank "${value}" && {
    export Bashmatic__IsErrors+=("${error}")
    export Bashmatic__IsValues+=("${value}")
  }
}

function validations.print-errors() {
  local error_count="${#Bashmatic__IsErrors}"
  ((error_count)) || return 0

  is.not-blank "${Bashmatic__IsSessionName}" &&
    hl.salmon "Reporing errors for ${Bashmatic__IsSessionName}"

  for i in $(seq 1 "${error_count}"); do
    local error=${Bashmatic__IsErrors[$((i - 1))]}
    local value=${Bashmatic__IsValues[$((i - 1))]}

    error "${error}" "Invalid value: ${value}"
  done

  return "${error_count}"
}

function validations.end() {
  validations.print-errors "$@"
  validations.begin ""
}

#------------------------------------------------------------------
# Public API
# Part 2. "is" validations — no output, just return code
#------------------------------------------------------------------

function is.not-blank() {
  [[ -n "${1}" ]]
}

function is.blank() {
  [[ -z "${1}" ]]
}

function is.not-a-blank-var() {
  local var="$1"
  [[ -n "${!var}" ]]
}

function is.a-non-empty-file() {
  [[ -s "${1}" ]]
}

function is.an-empty-file() {
  [[ ! -s "${1}" ]]
}

function is.a-directory() {
  [[ -d "${1}" ]]
}

function is.an-existing-file() {
  [[ -f "${1}" ]]
}

function is.a-function() {
  type "$1" 2>/dev/null | head -1 | grep -q 'is a function'
}

function is.a-variable() {
  local var_name="$1"
  [[ ${!var_name+x} ]]
}

function is.sourced-in() {
  bashmatic.detect-subshell
  [[ ${BASH_IN_SUBSHELL} -eq 0 ]]
}

function is.a-script() {
  bashmatic.detect-subshell
  [[ ${BASH_IN_SUBSHELL} -eq 1 ]]
}

#------------------------------------------------------------------
# Public API
# Part 3. error versions of each validation, which print an error messages
#------------------------------------------------------------------

# @description a convenient DSL for validating things
# @example
#      whenever /var/log/postgresql.log is.an-empty-file && {
#         touch /var/log/postgresql.log
#      }
function whenever() {
  __is.validation.error "${2}" "${1}" __is.validation.report-error "${@:3}"
}
# @description a convenient DSL for validating things
# @example
#      unless /var/log/postgresql.log is.an-non-empty-file && {
#         touch /var/log/postgresql.log
#      }

function unless() {
  ! __is.validation.error "${2}" "${1}" __is.validation.ignore-error "${@:3}"
}
