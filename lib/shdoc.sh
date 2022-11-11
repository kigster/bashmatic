#!/usr/bin/env bash
# @file lib/shdoc.sh
# @brief Helpers to install gawk and shdoc properly.0
# @description see `${BASHMATIC_HOME}/lib/shdoc.md` for an example of how to use SHDOC.
#              and also [project's github page](https://github.com/reconquest/shdoc).

# vim: ft=bash
# NOTE: shdoc in bashmatic's bin folder uses functions here to install gawk and shdoc.

# @description Installs gawk into /usr/local/bin/gawk
function gawk.install() {
  local gawk_path="$(command -v gawk 2>/dev/null)"
  [[ -n "${gawk_path}" && -x "${gawk_path}" ]] || brew.install.package gawk
}


