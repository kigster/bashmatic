#!/usr/local/bin/env bash
# vim: ft=bash

# PRIVATE FUNCTIONAL HELPERS FOR file.sh

export bashmatic__hostname="${HOSTNAME:-${HOST:-$(/usr/bin/env hostname)}}"
export bashmatic__temp_file_pattern=".bashmatic.${bashmatic__hostname}.${USER}."

# @description Makes a file executable but only if it already contains
#              a "bang" line at the top.
#
# @example x.file.make_executable ${pathname}
.file.make_executable() {
  local file=$1

  if [[ -f "${file}" && -n $(head -1 "$1" | ${GrepCommand} '#!.*(bash|ruby|env)') ]]; then
    printf "making file ${bldgrn}${file}${clr} executable since it's a script...\n"
    chmod 755 "${file}"
    return 0
  else
    return 1
  fi
}

.file.remote_size() {
  local url="$1"
  printf $(($(curl -sI "${url}" | grep -i 'Content-Length' | awk '{print $2}') + 0))
}

.file.size_bytes() {
  local file="$1"
  printf $(($(wc -c <"$file") + 0))
}


.file.backup.strategy.folder() {
  local file="$1"; shift
  local dir="${1:-"$(dirname "${file}")/.backup"}"; shift
  info "backup folder is -> ${dir}"
  run "mkdir -p \"${dir}\""
  run "mv \"${file}\" \"${dir}\""  
}

.file.backup.strategy.bak() {
  local file="$1"
  [[ -f ${file} ]] || return 0
  
  local i=0
  while true; do
    i=$(( i + 1 ))
    [[ $i -gt 100 ]] && { 
      error "You've got 100 backups already? :)"
      return 1
    }

    local n="${file}.bak.$i"
    [[ -f ${n} ]] && continue

    run "mv ${file} ${n}"
    break
  done
  return 0
}


