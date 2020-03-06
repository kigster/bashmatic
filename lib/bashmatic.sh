#!/usr/bin/env bash
# vi: ft=sh
#
# Public Functions 
#

bashmatic.reload() {
  source "${BashMatic__Init}"
}

bashmatic.version() {
  cat $(dirname "${BashMatic__Init}")/.version
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

bashmatic.functions-from() {
  local pattern="${1}"

  [[ -n ${pattern} ]] && shift
  [[ -z ${pattern} ]] && pattern="*.sh"

  cd ${BashMatic__Home} >/dev/null

  export SCREEN_WIDTH=$(screen-width)

  if [[ ! ${pattern} =~ "*" && ! ${pattern} =~ ".sh" ]]; then
    pattern="${pattern}.sh"
  fi

  egrep -e '^[_a-zA-Z]+.*\(\)' lib/${pattern} | \
    sed -E 's/^lib\/.*\.sh://g' | \
    sed -E 's/^function //g' | \
    sed -E 's/\(\) *{.*$//g' | \
    sed -E '/^ *$/d' | \
    grep -v '^_' | \
    sort | \
    uniq | \
    columnize "$@"

  cd - > /dev/null
}

# pass number of columns to print, default is 2
bashmatic.functions() {
  bashmatic.functions-from '*.sh' "$@"
}

bashmatic.functions.output() {
  bashmatic.functions-from 'output.sh' "$@"
}

bashmatic.functions.runtime() {
  bashmatic.functions-from 'run*.sh' "$@"
}

