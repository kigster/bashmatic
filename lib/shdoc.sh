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

# @description Installs shdoc unless already exists
function shdoc.install() {
  hash -r

  export install_shdoc_path="/usr/local/bin"
  [[ -x ${install_shdoc_path}/shdoc ]] && return 0

  is.command gawk || gawk.install

  local temp="$(file.temp)"
  run "rm -rf ${temp}"
  run "mkdir -p ${temp}"
  run "curl -fsSL https://raw.githubusercontent.com/reconquest/shdoc/master/shdoc -o ${temp}/shdoc"
  sed -E -e 's~#\!/usr/bin/gawk~#\!/usr/bin/env gawk~g' "${temp}/shdoc" > "${temp}/shdoc-executable"
  run "sudo mv ${temp}/shdoc-executable ${install_shdoc_path}/shdoc"
  run "chmod 755 ${install_shdoc_path}/shdoc"
}

# @description Reinstall shdoc completely
function shdoc.reinstall() {
  hash -r
  local i=0
  
  while true; do
    i=$(( i + 1 ))
    [[ $i -gt 3 ]] && {
      error "After 3 attempts still can't find shdoc in /usr/local/bin?"
      return 1
    }
    local shdoc_path="$(which shdoc)"
    [[ ${shdoc_path} =~ ${BASHMATIC_HOME} ]] && continue
    [[ -z "${shdoc_path}" ]] && break
    [[ -f "${shdoc_path}" ]] && run "rm -f ${shdoc_path} || sudo rm -f ${shdoc_path}"
    hash -r
  done

  shdoc.install 
}


    