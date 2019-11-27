#!/usr/bin/env bash
# vi: ft=sh
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


# pass number of columns to print, default is 2
bashmatic.functions() {
  local columns="${1:-2}"
  local pwd=${PWD}

  cd ${BashMatic__Home} >/dev/null

  # grab all function names from lib files
  # remove private functions
  # remove brackets, word 'function' and empty lines
  # print in two column format
  # replace tabs with spaces.. Geez.
  # finally, delete more empty lines with only spaces inside
  local screen_width=$(screen-width)
  [[ -z ${screen_width} ]] && screen_width=80

  grep --color=never -h -E '^[-\:0-9a-zA-Z_\.]+ *\(\) *{' lib/*.sh | \
    grep -v '^_' |                                     \
    sed -E 's/\(\) *.*//g; s/^function //g; /^ *$/d' | \
    sort                                             | \
    pr -l 10000 -${columns} -e4 -w ${screen_width}   | \
    expand -8 |                                        \
    sed -E '/^ *$/d'                                 | \
    grep -v 'Page '
}

