#!/usr/bin/env bash
#———————————————————————————————————————————————————————————————————————————————
# © 2016-2020 Konstantin Gredeskoul, All rights reserved. MIT License.
# Ported from the licensed under the MIT license Project Pullulant, at
# https://github.com/kigster/pullulant
#
# Any modifications, © 2016-2020 Konstantin Gredeskoul, All rights reserved. MIT License.
#———————————————————————————————————————————————————————————————————————————————

# Returns "true" if the first argument is a member of the array
# passed as the second argument:
#
# Example:
#
#     $ declare -a array=("a string" test2000 moo)
#     if [[ $(array.has-element "a string" "${array[@]}") == "true" ]]; then
#       ...
#     fi
#
array.has-element() {
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

# similar to array.has-elements, but does not print anything, just
# returns 0 if includes, 1 if not.
array.includes() {
  local search="$1"; shift
  [[ "$*" =~ ${search} ]] || return 1
  for e in "${@}"; do
    [[ "$e" == "${search}" ]] && {
      return 0
    }
  done
  return 1
}

array.includes-or-complain() {
  array.includes "$@" || {
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

array.includes-or-exit() {
  array.includes-or-complain "$@" || exit 1
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

array.to.csv() {
  array.join ', ' false "$@"
}

array.to.bullet-list() {
  array.join ' • ' true "$@"
}

array.to.piped-list() {
  array.join ' | ' false "$@"
}

# usage: array.eval.in-groups-of <number> <bash function> <array of arguments to bash function>
#    eg: array.eval.in-groups-of 5 bash.package.install asciidoc asciidoctor autoconf automake awscli bash ....
array.eval.in-groups-of() {
  local chunk="$1"; shift
  local function="$1"; shift
  local -a group
  for item in "$@"; do
    index="$(( index + 1 ))"
    if [[ ${#group[@]} -eq ${chunk} ]]; then
      ${function} "${group[@]}"
      group=( "${item}" )
    else
      group=("${group[@]}" "${item}")
    fi
  done

  if [[ ${#group[@]} -gt 0 ]]; then
    ${function} "${group[@]}"
  fi

  return 0
}