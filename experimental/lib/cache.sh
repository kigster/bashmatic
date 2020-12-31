#!/usr/bin/env bash
# vi: ft=sh
# @brief Cache sourced in entrys iusing BASH 4+ associative 
#        arrays.
#

declare cache_is_supported
export cache_is_supported=1

function cache.init() {
  if bashmatic.bash.version-four-or-later ; then
    declare -A item_cache_map 2>/dev/null
    declare -A caches_cache_map 2>/dev/null
    export item_cache_map
    export caches_cache_map
  else 
    export cache_is_supported=0
  fi
}

cache.new() {
  local name="$1"
  test -z "${name}" && return 1
  test -z "${caches_cache_map["${name}"]}" || {
    error "${name} is already used as the key."
  }
  declare -A new_items_map
  caches_cache_map[${name}]="${new_items_map[@]}"
}

cache.has() {
  ((cache_is_supported)) || return 1
  
  local entry="$1"
  test -z "$entry" && return 1
  if [[ -n "$1" && -n "${item_cache_map["${entry}"]}" ]]; then
    return 0
  else
    return 1
  fi
}

cache.add() {
  ((cache_is_supported)) || return
  [[ -n "${1}" ]] && item_cache_map[${1}]=true
}

cache.add-new() {
  ((cache_is_supported)) || return
  s
  [[ -n "${1}" ]] && item_cache_map[${1}]=true
}

cache.list() {
  ((cache_is_supported)) || return
  for f in "${!item_cache_map[@]}"; do echo $f; done
}

cache.init