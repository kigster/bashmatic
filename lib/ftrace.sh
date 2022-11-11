#!/usr/bin/env bash
#
# This module can aid in debugging bash functions and their return values.
#
# It provides just four functions:
# 
#  • ftrace-on and ftrace-off can be used to globally enable/disable tracing
#
#  • ftrace-in and ftrace-out should be used at the beginning and the end
#    respectively of a traced function.  The *ftrace-in* function receives
#    trace'd function name as the first argument, and "$@" as the rest.
#    The *ftrace-out* function receives function return value as the second
#    argument, and an optional message as the rest.
#
# Example:
#
# function fullname() {
#    ftrace-in fullname "$@"
#
#    local first=$1; local last=$2
#    local full="${first} ${last}"
#    local result=0
#    if [[ ${#full} -lt 2 ]] ; then
#       result=1
#    fi
#
#    ftrace-out fullname ${result}
#    return ${result}
# }

export __LibTrace__StackLevel=0
ftrace-on() {
  export TraceON=true
}

ftrace-off() {
  unset TraceON
}

ftrace-in() {
  local func=$1; shift
  local args="$*"

  [[ -z ${TraceON} ]] && return

  export __LibTrace__StackLevel=$(( ${__LibTrace__StackLevel} + 1 ))
  printf "    %*s ${bldylw}%s${bldblu}(%s)${clr}\n" ${__LibTrace__StackLevel} ' ' "${func}" "${args}" >&2
}

ftrace-out() {
  local func=$1; shift
  local code=$1; shift
  local msg="$*"

  [[ -z ${TraceON} ]] && return

  local color="${bldgrn}"
  [[ ${code} -ne 0 ]] && color="${bldred}"

  printf "    %*s ${bldylw}%s() ${color} ➜  %d %s\n\n" ${__LibTrace__StackLevel} ' ' "${func}" "${code}" "${msg}" >&2
  export __LibTrace__StackLevel=$(( ${__LibTrace__StackLevel} - 1 ))
}



