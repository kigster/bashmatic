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
#  On Linux/Unix, in order to backup directories you must use tar :
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
      flags=(${flags[@]} "${arg}")
    else
      args=(${args[@]} "${arg}")
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

# @description This function receives as the first argument the name of the
#              archive, and then a list of folders to compress into that archive
#              AND remove them once they have been successfully archived.
# @example
#    > ls -1F
#    data/
#    src/
#    models/
#    examples/
#
#    > 7z.archive ML-project data models
#    ...
#    > ls -1F
#    ML-project.7z
#    src/
#    examples/
#
function 7z.archive() {
  local first="$1"
  local archive

  archive="$(echo "${first}" | sed 's/\/$//g; s/\//-/g; s/ /./g' | tr '[:upper:]' '[:lower:]')".7z
  [[ ${archive} =~ .7z$ ]] || archive="${archive}.7z"

  local -a directories
  local skipped=0
  local good=0
  local size=0
  local largest_size=0
  local largest_folder
  local dir_size

  for dir in "$@"; do
    dir_size="$(du -s "${dir}" | cut -f1)"

    if [[ ${dir_size} -gt ${largest_size} ]]; then
      largest_size=${dir_size}
      largest_dir="${dir}"
    fi

    size=$((size + dir_size))
    [[ -d "${dir}" ]] || {
      warning "DIRECTORY: [${dir}] does not exist. Skipping."
      skipped=$((skipped + 1))
      continue
    }
    good=$((good + 1))
    directories+=("${dir}")
  done

  if [[ ${good} -gt 0 ]]; then
    h2bg "Found ${good} existing directories, and ${skipped} bad ones." \
      "The largest folder is [${largest_folder}], size is $((largest_size / 1024 / 1024))Mb"

    h1 "Archive:" "${bldylw}${archive}" \
      "Total size of all the folders is $((size / 1024 / 1024 / 1024)) Gb."

    h2 "Directories:" "${directories[@]}"

    if [[ ${skipped} -gt 0 ]]; then
      run.ui.press-any-key "Since some of your arguments are invalid, now is your change to Ctrl-C..." \
        "\n    ${bldred}Or press any key to continue..."
    fi
  fi

  command -v 7z >/dev/null || brew install -q p7zip
  clear

  info "Starting compression..."
  hr
  echo
  printf "${txtblu}"
  set -x
  7z a -sdel -mmt18 -mx7 -ssc -bb1 "${archive}" "$@"
  local code=$?
  set +x
  printf "${clr}\n"
  hr
  echo

  ((code)) && {
    error "Archiving failed with code=${code}"
  } || {
    success "Archiving succeeded with exit code ${code}, and file size $(file.size.gb "${archive}")"
  }
  return ${code}
}
