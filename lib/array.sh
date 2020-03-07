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
#     $ array.contains-element moo "${array[@]}" || echo "no luck!"
#     $ array.complain-unless-includes haha "${array[@]}" || echo "no luck!"

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
  local search="$1"; shift
  local r="false"
  local e

  [[ "$*" =~ ${search} ]] || {
    echo -n $r
    return 1
  }
  for e in "${@}"; do
    [[ "$e" == "${search}" ]] && r="true"
  done
  echo -n $r
  [[ $r == "false" ]] && return 1
  return 0
}

array.contains-element() {
  local search="$1"; shift
  [[ "$*" =~ ${search} ]] || return 1
  for e in "${@}"; do
    [[ "$e" == "${search}" ]] && {
      return 0
    }
  done
  return 1
}

array.complain-unless-includes() {
  array.contains-element "$@" || {
    element="$1"; shift
    local -a output=()
    while true; do
      [[ -z "$1" ]] && break
      if [[ "$1" =~ " " ]]; then
        output=("${output[@]}" "$1")
      else
        output=("$1")
      fi
      shift
    done

    if [[ ${#output[@]} -gt 10 ]]; then
      error "Value ${element} must be one of the supplied values."
    else
      error "Value ${element} must be one of the supplied values:" "${output[@:0:10]}"
    fi
    echo
    return 0
  }

  return 1
}

array.exit-unless-includes() {
  array.complain-unless-includes "$@" || exit 1
}

array.join() {
  local sep="$1"; shift
  local lines="$1"

  if [[ ${lines} == true || ${lines} == false ]];  then
    shift
  else
    lines=false
  fi

  local elem
  local len="$#"
  local last_index=$(( len - 1 ))
  local index=0

  for elem in "$@"; do
    if ${lines}; then
      printf "${sep}%s\n" "${elem}"
    else
      printf "%s" "${elem}"
      [[ ${index} -lt ${last_index} ]] && printf '%s' "${sep}"
    fi
    index=$(( index + 1 ))
  done
}

array-join() { array.join "$@"; }

array-csv() {
  array.join ', ' false "$@"
}

array-bullet-list() {
  array.join ' • ' true "$@"
}

array.piped() {
  array.join ' | ' false "$@"
}

array.from-command-output() {
  local array_name=$1; shift
  local script="while IFS='' read -r line; do ${array_name}+=(\"\$line\"); done < <($*)"
  eval "${script}"
}

array-piped() {
  array.piped "$@";
}
