#!/usr/bin/env bash
#
# Public Functions 
#

bashmatic.reload() {
  source "${BashMatic__Init}"
}

bashmatic.load-at-login() {
  local init_file="${1}"
  local -a init_files=(~/.bashrc ~/.bash_profile ~/.profile)

  [[ -n "${init_file}" && -f "${init_file}" ]] && init_files=("${init_file}")

  for file in "${init_files[@]}"; do
    if [[ -f "${file}" ]] ; then
      grep -q bashmatic "${file}" && {
        success "BashMatic is already loaded from ${bldblu}${file}"
        return 0
      }
      grep -q bashmatic "${file}" || {
        h2 "Adding BashMatic auto-loader to ${bldgrn}${file}..."
        echo "source ${BashMatic__Home}/init.sh" >> "${file}"
      }
      source "${file}"
      break
    fi
  done
}

