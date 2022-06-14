#!/usr/bin/env bash

# @descroption
#   Returns the first folder above the given that contains
#   a file.
# @arg1 file without the path to search for, eg ".evnrc"
# @arg2 Starting file path to seartch
# @output File path that's a sub-phat of the @arg2 contaning the file.
#   if no file is found, 1 or 2 is returned."
dir.with-file() {
  local file="$1"
  local dir="${2:-$(pwd -P)}"

  if [[ ${dir:0:1} != "/" ]]; then
    dir="$(pwd -P)/${dir}"
  fi

  local _d="${dir}"

  while true; do
    local try="${_d}/${file}"
    [[ -f "${try}" ]] && {
      echo "${_d}"
      return 0
    }
    _d="$(dirname "${_d}")"
    if [[ "${_d}" == "/" || "${_d}" == "" ]] ; then
      [[ -f "${_d}/${file}" ]] || {
        echo "No file ${file} was found in the path.">&2
        return 1
      } 
      echo "${_d}"
      exit 0
    fi
   done
  return 2
}

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

