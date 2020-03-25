#!/usr/bin/env bash

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
7z.zip() {
  local archive="$1"
  7z.install
  [[ -f ${archive} || -d ${archive} ]] && archive="$(basename ${archive} | sedx 's/\./-/g').tar.7z"
  [[ -f ${archive} ]] && { 
    run.set-next on-decline-return
    run.ui.ask "File ${archive} already exists. Press Y to remove it and continue." || return 1
    run "rm -f ${archive}"
  }
  run "tar cf - $* | 7za a -si ${archive}"
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
  info "Unpacking archive ${txtylw}${archive}$(txt-info), total of $(file.size ${archive}) bytes."

  run.set-next show-output-on
  run "7za x -so ${archive} | tar xfv -"
}

7z.x() { 7z.unzip "$@"; }
