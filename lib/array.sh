#!/usr/bin/env bash
#———————————————————————————————————————————————————————————————————————————————
# © 2016-2017 Author: Konstantin Gredeskoul
# Ported from the licensed under the MIT license Project Pullulant, at
# https://github.com/kigster/pullulant
#
# Any modifications, © 2017 Konstantin Gredeskoul, Inc. All rights reserved.
#———————————————————————————————————————————————————————————————————————————————

# Returns "true" if the first argument is a member of the array
# passed as the second argument:
#
#
#
# Simplest case:
#
#     $ declare -a array=("a string" test2000 moo)
#     $ lib::array::contains-element moo "${array[@]}" || echo "no luck!"
#     $ lib::array::complain-unless-includes haha "${array[@]}" || echo "no luck!"

#     if [[ $(array-contains-element "a string" "${array[@]}") == "true" ]]; then
#       ...
#     fi
#
#
# @param: search string
# @param: array to search as a string
# @output: prints "true" or "false"
#

array-contains-element() {
  local e
  local r="false"
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && r="true"; done
  echo -n $r
  [[ $r == "false" ]] && return 1
  return 0
}

lib::array::contains-element() {
  for e in "${@:2}"; do
    [[ "$e" == "$1" ]] && {
      return 0
    }
  done
  return 1
}

lib::array::complain-unless-includes() {
  lib::array::contains-element "$@" || {
    element=$1; shift
    local output=""
    local comma=false
    while true; do
      [[ -z $1 ]] && break
      ${comma} && output="${output}, "
      ${comma} || comma=true
      if [[ "$1" =~ " " ]]; then
        output="${output} '$1'"
      else
        output="${output} $1"
      fi
      shift
    done
    output=$(echo $output | hbsed 's/  / /g')
    error "Value ${bldwht}${element}${error_color}${bldylw} must be one of the following values: ${bldgrn}${output}"
    echo
    return 0
  }
  return 1
}

lib::array::exit-unless-includes() {
  lib::array::complain-unless-includes "$@" || exit 1
}
