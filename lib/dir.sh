#!/usr/bin/env bash

dir.count-slashes() {
  local dir="${1}"
  echo "${dir}" |
    sed 's/[^/]//g' |
    tr -d '\n' |
    wc -c |
    tr -d ' '
}

dir.is-a-dir() {
  local dir="${1}"
  [[ -d "${dir}" ]]
}

dir.expand-dir() {
  local dir="${1}"
  # Replace the ~

  if [[ "${dir:0:1}" != "/" && "${dir:0:1}" != "~" ]]; then
    # it's a local directory
    dir="$(pwd)/${dir}"
  elif [[ "${dir:0:1}" == "~" ]]; then
    # it's a folder relative to our home
    dir="${HOME}/${dir:1:1000}"
  fi

  printf -- "%s" "${dir}"
}

# @description Replaces the first part of the directory that matches ${HOME} with '~/'
dir.short-home() {
  local dir="$1"
  # This does not work for some reason
  # printf -- "%s" "${dir/${HOME}/~}"
  printf -- "%s" "${dir}" | sed -E "s#${HOME}#~#g"
}

dir.rsync-to() {
  local from="$1"; shift
  local to="$1"; shift

  [[ -d ${from} ]] || {
    error "usage: dir.rsync-to [ from-dir ] [ enclosing-to-dir ]" "Directory ${from} does not exist."
    return 1
  }
  [[ -d ${to} ]] || {
    error "usage: dir.rsync-to [ from-dir ] [ enclosing-to-dir ]" "Directory ${to} does not exist."
    return 1
  }

  command -v rsync >/dev/null || package.install rsync

  h3 "Starting RSync: [${from} —> ${to}]"
  local flags="avht"

  run.ui.ask "Do you want do delete files in ${to} that don't match files in ${from}?"

  rsync -avht "${from}" "${to}"  
}
