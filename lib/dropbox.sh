#!/usr/bin/env bash
# vim: ft=bash
# @description Utilities relating to Dropbox
#

# @description Set file to be ignored by Dropbox
# @see https://help.dropbox.com/files-folders/restore-delete/ignored-files
function dropbox.ignore {
  local file="$(path.absolute "$1")"
  util.os

  case "${BASHMATIC_OS}" in
    darwin)
      run "xattr -w com.dropbox.ignored 1 \"${file}\""
      ;;
    linux)
      run "attr -s com.dropbox.ignored -V 1  \"${file}\""
      ;;
  esac
} 

# @description Set a file or directorhy to be ignored by Dropbox
# @see https://help.dropbox.com/files-folders/restore-delete/ignored-files
function dropbox.unignore() {
  local file="$(path.absolute "$1")"
  util.os
  case "${BASHMATIC_OS}" in
    darwin)
      run "xattr -d com.dropbox.ignored \"${file}\""
      ;;
    linux)
      run "attr -r com.dropbox.ignored \"${file}\""
      ;;
  esac
}


