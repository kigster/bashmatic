#!/usr/bin/env bash
# vim: ft=bash
#———————————————————————————————————————————————————————————————————————————————
# © 2016-2021 Konstantin Gredeskoul, All rights reserved. MIT License
# Ported from the licensed under the MIT license Project Pullulant.
# Changes are © 2016-2021 Konstantin Gredeskoul All rights reserved. MIT License
#———————————————————————————————————————————————————————————————————————————————
#
# @description GPG related utilities

#———————————————————————————————————————————————————————————————————————————————
#  gpgit
#———————————————————————————————————————————————————————————————————————————————

function gpgit.install-deps() {
  util.os
  case "${AppCurrentOS}" in
  darwin)
      brew.install.packages "coreutils gawk gnu-sed git tar xz-utils bzip lzip file jq curl gzip"
    ;;
  linux)
    # Install dependencies and optional dependencies
    run "sudo apt-get install bash gnupg2 git tar xz-utils coreutils gawk grep sed"
    run "sudo apt-get install gzip bzip lzip file jq curl"
    ;;
  esac
}

function gpgit.install() {
  gpgit.install-deps

  # Download and verify source
  VERSION=1.4.1
  run "wget \"https://github.com/NicoHood/gpgit/releases/download/${VERSION}/gpgit-${VERSION}.tar.xz\""
  run "wget \"https://github.com/NicoHood/gpgit/releases/download/${VERSION}/gpgit-${VERSION}.tar.xz.asc\""
  run "gpg2 --keyserver hkps://keyserver.ubuntu.com --recv-keys 97312D5EB9D7AE7D0BD4307351DAE9B7C1AE9161"

  gpg2 --verify "gpgit-${VERSION}.tar.xz.asc" "gpgit-${VERSION}.tar.xz"

  # Extract, install and run GPGit
  tar -xf "gpgit-${VERSION}.tar.xz"
  sudo make -C "gpgit-${VERSION}" PREFIX=/usr/local install
  gpgit --helpp
}

