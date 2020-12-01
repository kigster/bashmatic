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
