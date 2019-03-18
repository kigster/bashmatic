#!/usr/bin/env bash

lib::dir::count-slashes() {
  local dir="${1}"
  echo "${dir}" | \
    sed 's/[^/]//g' | \
    tr -d '\n' | \
    wc -c | \
    tr -d ' '
}

lib::dir::is-a-dir() {
  local dir="${1}"
  [[ -d "${dir}" ]]
}

lib::dir::expand-dir() {
  local dir="${1}"
  # Replace the ~

  if [[ "${dir:0:1}" != "/" && "${dir:0:1}" != "~" ]]; then
    # it's a local directory
    dir="$(pwd)/${dir}"
  elif [[ "${dir:0:1}" == "~" ]]; then
    # it's a folder relative to our home
    dir="${HOME}/${dir:1:1000}"
  fi

  printf "${dir}"
}
