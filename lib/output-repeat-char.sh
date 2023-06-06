#!/usr/bin/env bash
# vim: ft=bash
# shellcheck disable=SC2034

export BASHMATIC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

function performance.test.char-repeat-methods() {
  local times="${1:-10}"
  local timeout="${2:-10}"

  h1 "Starting Performance Comparison of character drawing methods." \
     "Note that you can pass two arguments:" \
     "  1. The total number of iterations per run to execute" \
     "  2. The timeout in seconds per iteration you are willing to tolerate."

  h2bg "Current settings: " "${bldylw}times=${times}, timeout=${timeout}"

  if [[ -f "${BASHMATIC_DIR}/lib/${performance-testing.sh}" ]]; then
    source "${BASHMATIC_DIR}/lib/${performance-testing.sh}"
  fi

  local -a methods
  local -a durations

  for func in $(performance.test.list-functions "${BASHMATIC_DIR}/lib"); do
    local duration=$(time-test "$func _ 80" "${times}" "${timeout}")
    methods+=("${func}")
    durations+=("${duration}")
  done

  echo

  local -a results

  local methods_size=${#methods[@]}
  methods_size=$((methods_size-1))

  local tmp=$(mktemp)
  for i in $(seq 0 ${methods_size}); do
    local method="${methods[$i]}"
    local duration="${durations[$i]}"
    printf "    %12f sec ❮ %s\n"  "${duration}" "${method}"
  done | sort -n > "${tmp}"

  mapfile -t results < <(cat "${tmp}")
  h3bg "Results of the Performance Testing" "${results[@]}"

  hr ; echo
}

function performance.test.list-functions() {
  local folder="${1}"
  local file="output-repeat-char.sh"
  local path
  path="${folder}/${file}"
  if [[ -f "${path}" ]] ; then
    grep -E '^(function )?\.output' "${path}" | grep '\.impl\.' | sed 's/(.*$//g; s/function *//g'
  else
    error "File not found: ${path}" >&2
    return 1
  fi
}

# @description As this file provides multiple implementations for repeating a character,
# this is a crucial method that sets one of such implementaqtions to be the one used.
# For this reason we provide the above method which relies on the home grown performance
# testing framework to compare the implementations side by side.
function .output.repeat-char.set-implementation() {
  is.a-function ".output.repeat-char.impl.${1}" || {
    error "Invalid implementation: ${1}"
    return 1
  }

  export LibOutput__RepeatCharImplementation="${1}"
}

# @description A simply convenient function alias for repeat-char
function char.repeat() {
  .output.repeat-char "$@"
}

export LibOutput__RepeatCharImplementation="product"

# Repeat character implementations
# See: https://stackoverflow.com/questions/5349718/how-can-i-repeat-a-character-in-bash
#
# source lib/output.sh; .output.repeat-char.set-implementation looping; time box.white-on-blue "HELLO! " "${bldylw}and good bye" "And fuck you" "TOO!"
# real	0m0.598s
function .output.repeat-char.impl.looping() {
  local char="${1}"
  local width="${2}"
  [[ -z "${width}" ]] && width=$(.output.screen-width)
  local i=1
  while true; do
    [[ $i -ge ${width} ]] && break
    printf -- "${char}"
    i=$((i+1))
  done
}

# real	0m0.591s
function .output.repeat-char.impl.array() {
  local char="${1}"
  local width="${2}"
  [[ -z "${width}" ]] && width=$(.output.screen-width)
  local -a line
  local i=1
  while true; do
    [[ $i -gt ${width} ]] && break
    line+=("${char}")
    i=$((i+1))
  done
  printf "%s" "${line[@]}"
}

# real	0m0.570s
function .output.repeat-char.impl.product() {
  local char="${1}"
  local width="${2}"
  [[ -z "${width}" ]] && width=$(.output.screen-width)
  local i=1
  local line
  while true; do
    [[ $i -gt ${width} ]] && break
    line="${line}${char}"
    i=$((i+1))
  done
  printf -- "${line}"
}

# real	0m0.723s
function .output.repeat-char.impl.printf() {
  local char="${1}"
  local width="${2}"

  printf "%${width}.${width}s" "${char:0:1}" | sedx "s/ /${char}/g"
}

# real	0m1.350s
function .output.repeat-char.impl.ruby() {
  local char="${1}"
  local width="${2}"
  ruby -e "print '${char}' * $((width))"
}

# real	0m0.759s
function .output.repeat-char.impl.cache() {
  local char="${1}"
  local width="${2}"
  is.a-variable LibOutput__CachedRepeats || {
    declare -A LibOutput__CachedRepeats
    export LibOutput__CachedRepeats=()
  }

  local key="$(.output.repeat-char.cache-key "${char}" "${width}")"
  if [[ -z ${LibOutput__CachedRepeats["${key}"]} ]]; then
    local out="$(printf "%${width}.${width}s" "${char}" | sedx "s/ /${char}/g")"
    LibOutput__CachedRepeats["${key}"]="${out}"
  fi

  printf -- "%s" "${LibOutput__CachedRepeats["${key}"]}"
}

function .output.repeat-char() {
  local impl="${LibOutput__RepeatCharImplementation}"
  local func=".output.repeat-char.impl.${impl}"
  is.a-function "${func}" || {
    error "repeat char implementation not found: ${impl}" >&2
    return 1
  }

  ${func} "$@"
}

function .output.repeat-char.cache-key() {
  local char="${1}"
  local width="${2}"
  printf "%s%d" "${width}" "$(text.ord "${char}")"
}


