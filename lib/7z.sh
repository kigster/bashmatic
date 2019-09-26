#!/usr/bin/env bash

lib::7z::install() {
  [[ -n $(which 7z) ]] || run "brew install p7zip"
  [[ -n $(which 7z) ]] || {
    error "7z is not found after installation"
    return 1
  }

  return 0
}

# usage: lib::7z::zip folder1 folder2 ...
# creates: folder1.7z, folder2.7z, etc,.
lib::7z::zip() {
  lib::7z::install

  while [[ -n "$*" ]]; do
    local folder="$1"; shift
    run "7z a -bt -mmt16 \"${folder}\".7z \"${folder}\""
  done
}

7z.a() { lib::7z::zip "$@"; }

lib::7z::unzip() {
  lib::7z::install

  while [[ -n "$*" ]]; do
    local archive="$1"; shift
    run "7z x -bt -mmt16 \"${archive}\""
  done
}

7z.x() { lib::7z::unzip "$@"; }

lib::7z::unzip() {
  lib::7z::install

  while [[ -n "$*" ]]; do
    local archive="$1"; shift
    run "7z x -bt -mmt16 \"${archive}\""
  done
}
