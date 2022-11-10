#!/usr/bin/env bash
# vim: ft=bash

export LibOutput__RepeatCharImplementation="product"

# Repeat character implementations
# See: https://stackoverflow.com/questions/5349718/how-can-i-repeat-a-character-in-bash
# 
# source lib/output.sh; .output.repeat-char.set-implementation looping; time box.white-on-blue "HELLO! " "${bldylw}and good bye" "And fuck you" "TOO!"
# real	0m0.598s
.output.repeat-char.impl.looping() {
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
.output.repeat-char.impl.array() {
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
.output.repeat-char.impl.product() {
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
.output.repeat-char.impl.printf() {
  local char="${1}"
  local width="${2}"

  printf "%${width}.${width}s" "${char:0:1}" | sedx "s/ /${char}/g"
}

# real	0m1.350s
.output.repeat-char.impl.ruby() {
  local char="${1}"
  local width="${2}"
  ruby -e "print '${char}' * $((width))"
}

# real	0m0.759s
.output.repeat-char.impl.cache() {
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

.output.repeat-char() {
  local impl="${LibOutput__RepeatCharImplementation}"
  local func=".output.repeat-char.impl.${impl}"
  is.a-function "${func}" || {
    error "repeat char implementation not found: ${impl}" >&2
    return 1
  }

  ${func} "$@"
}

.output.repeat-char.set-implementation() {
  is.a-function ".output.repeat-char.impl.${1}" || {
    error "Invalid implementation: ${1}"
    return 1
  }

  export LibOutput__RepeatCharImplementation="${1}"
}

.output.repeat-char.cache-key() {
  local char="${1}"
  local width="${2}"
  printf "%s%d" "${width}" "$(text.ord "${char}")"
}


