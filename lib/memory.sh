#!/usr/bin/env bash
# vim: ft=bash
#
# @description
# Pass in a value eg. 32GB or 16M and it returns back the number of bytes
function memory.size-to-bytes() {
  local value="$1"
  local upper="${value^^}"
  local numeric
  local bytes
  numeric="$(echo "${value}" | tr -d 'a-zA-Z ')"
  if [[ ${upper} =~ M$ || ${upper} =~ MB$ ]]; then
    bytes=$((numeric * 1024 * 1024))
  elif [[ ${upper} =~ TB$ || ${upper} =~ T$ ]]; then
    bytes=$((numeric * 1024 * 1024 * 1024 * 1024))
  elif [[ ${upper} =~ GB$ || ${upper} =~ G$ ]]; then
    bytes=$((numeric * 1024 * 1024 * 1024))
  elif [[ ${upper} =~ K$ || ${upper} =~ KB$ ]]; then
    bytes=$((numeric * 1024))
  else
    bytes=${numeric}
  fi

  printf "%d" "${bytes}"
}

# @description This function receives up to three arguments:
# @arg1 A number of bytes to convert into a more human-friendly format
# @arg2 An optional printf format string, defaults to '%.1f'
# @arg3 An optional suffix ('b' or "B" or none at all)
function memory.bytes-to-units() {
  local bytes="$1"
  local format="${2:-"%.1f"}"
  local suffix="${3:-"b"}"

  command -v numfmt >/dev/null || {
    command -v brew && brew install coreutils -q
    [[ -x $(brew --prefix)/bin/numfmt ]] || {
      error "Can't find numfmt installed, even after installing coreutils"
      return 1
    }
  }

  is.numeric "${bytes}" && numfmt --to=iec "${bytes}" --format="${format}" --suffix="${suffix/ */}"
}
