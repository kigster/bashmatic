#!/usr/bin/env bash

export True=1
export False=0

export BashMatic__SearchTarget="Loader.bash"
export BashMatic__Loader=$(find -L . -maxdepth 3 -type f -name "${BashMatic__SearchTarget}" -print 2>/dev/null | tail -1)

if [[ -z ${BashMatic__Loader} ]]; then
  printf "${bldred}ERROR: ${clr}Can not find ${bldylw}${BashMatic__SearchTarget}${clr} file, aborting."
  (( $_s_ )) && return 1 || exit 1
fi

export BashMatic__LibDir=$(dirname "${BashMatic__Loader}")

lib::bash-source() {
  local folder=${1}

  [[ -n ${DEBUG} ]] && printf "sourcing folder ${bldylw}$folder${clr}...\n" >&2
  # Let's list all lib files
  declare -a files=($(ls -1 ${folder}/*.sh))

  for bash_file in ${files[@]}; do
    [[ -n ${DEBUG} ]] && printf "sourcing ${txtgrn}$bash_file${clr}...\n" >&2
    source ${bash_file}
  done
}

[[ -n ${BashMatic__LibDir} ]] && lib::bash-source "${BashMatic__LibDir}"

