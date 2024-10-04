#!/usr/bin/env bash
# vim: ft=bash
# @copyright © 2016-2024 Konstantin Gredeskoul, All rights reserved
# @license MIT License.
#
# @file lib/7z.sh
# @description p7zip conversions routines.

7z.install() {
  [[ -n $(which 7z) ]] || run "brew install p7zip"
  [[ -n $(which 7z) ]] || {
    error "7z is not found after installation"
    return 1
  }

  return 0
}

# From 7z Man Page:
#
#  On linux/Unix, in order to backup directories you must use tar :
#  - to backup a directory  : tar cf - directory | 7za a -si directory.tar.7z
#  - to restore your backup : 7za x -so directory.tar.7z | tar xf -



# usage  : 7z.zip folder1 folder2 file1 file2 ...
# creates: folder1.tar.7z with all of the folders and files included.
# 

7z.zip() {
  local folder="$1"
  shift
  7z.install

  local archive="${folder}"
  [[ -f "${folder}" || -d "${folder}" ]] && archive="$(basename "${folder}" | sed -E 's/\./-/g').tar.7z"

  [[ -f ${archive} ]] && { 
    run.set-next on-decline-return
    run.ui.ask "File ${archive} already exists. Press Y to remove it and continue." || return 1
    run "rm -f ${archive}"
  }

  local -a flags=
  local -a args=
  for arg in $@; do
    if [[ ${arg:0:1} == "-" ]]; then
      flags=( ${flags[@]} "${arg}" )
    else
      args=( ${args[@]} "${arg}" )
    fi
  done
  printf "${bldgrn}"
  printf "${args[*]}\n"
  printf "${bldylw}"

  set +e

  local command="tar cf - ${folder} ${args[*]} | 7za a ${flags[*]} -si -bd ${archive}"
  run.print-command "${command}"
  eval "${command}"

  local code=$?

  printf "${clr}"

  if [[ ${code} -eq 0 ]]; then
    success "${archive} created."
  else
    error "Tar/7z Exited with code ${code}"
    return 1
  fi
}

7z.a() { 7z.zip "$@"; }

7z.unzip() {
  7z.install
  local archive="$1"
  [[ -f ${archive} ]] || archive="${archive}.tar.7z"
  [[ -f ${archive} ]] || {
    error "Neither $1 nor ${archive} were found."
    return 1
  }
  info "Unpacking archive ${txtylw}${archive}$(txt-info), total of $(file.size "${archive}") bytes."

  run.set-next show-output-on
  run "7za x -so ${archive} | tar xfv -"
}

7z.x() { 7z.unzip "$@"; }


