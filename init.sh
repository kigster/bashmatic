#!/usr/bin/env bash

export True=1
export False=0

bashmatic::-init-source() {
  local source=${BASH_SOURCE[0]}
  printf "%s" "${source}"
}

bashmatic::source-dir() {
  local folder="${1}"

  # Let's list all lib files
  declare -a files=($(ls -1 "${folder}"/*.sh))

  for bash_file in "${files[@]}"; do
    [[ -n ${DEBUG} ]] && printf "sourcing ${txtgrn}$bash_file${clr}...\n" >&2
    source "${bash_file}"
  done
}

bashmatic.setup() {
  # Set this externally if your bashmatic is not installed in ~/.bashmatic
  export BashMatic__Init=$(bashmatic::-init-source)
  export BashMatic__Home="$(cd $(dirname "${BashMatic__Init}"); pwd)"
  export BashMatic__LibDir="${BashMatic__Home}/lib"

  [[ -z ${BashMatic__Downloader} && -n $(which curl) ]] && \
    export BashMatic__Downloader="curl -fsSL --connect-timeout 5 "

  [[ -z ${BashMatic__Downloader} && -n $(which wget) ]] && \
    export BashMatic__Downloader="wget -q -O --connect-timeout=5 - "

  source "${BashMatic__LibDir}/color.sh"
  source "${BashMatic__LibDir}/output.sh"
  source "${BashMatic__LibDir}/time.sh"
  source "${BashMatic__LibDir}/array.sh"

  bashmatic::source-dir "${BashMatic__LibDir}"
}

bashmatic.setup
