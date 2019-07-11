#!/usr/bin/env bash

export True=1
export False=0

# Set this externally if your bashmatic is not installed in ~/.bashmatic
export BashMatic__Home=${BashMatic__Home:-"${HOME}/.bashmatic"}
export BASHMATIC_HOME="${BashMatic__Home}"

export BashMatic__SearchTarget="Loader.bash"
export BashMatic__Loader=$(find -L . -maxdepth 3 -type f -name "${BashMatic__SearchTarget}" -print 2>/dev/null | tail -1)

[[ -z ${BashMatic__Downloader} && -n $(which curl) ]] && export BashMatic__Downloader="curl -fsSL --connect-timeout 5 "
[[ -z ${BashMatic__Downloader} && -n $(which wget) ]] && export BashMatic__Downloader="wget -q -O --connect-timeout=5 - "

[[ -d "${BashMatic__Home}" && -z ${BashMatic__Loader} ]] && \
  export BashMatic__Loader=$(find "${BashMatic__Home}" -maxdepth 3 -type f -name "${BashMatic__SearchTarget}" -print 2>/dev/null | tail -1)

if [[ -z "${BashMatic__Loader}" ]]; then
  printf "${bldred}ERROR: ${clr}Can not find ${bldylw}${BashMatic__SearchTarget}${clr} file, aborting.\n\n"

  printf "${bldblu}If you installed BashMatic not in ~/.bashmatic (it's default home), \n"
  printf "you might consider setting environment variable ${bldylw}BashMatic__Home${bldblu} \n"
  printf "like so:\n\n"
  
  printf "   ${bldylw}echo 'export BashMatic__Home=/Users/kig/.scripts/bashmatic' >> ~/.bash_profile${clr}\n\n"

  printf "${bldblu}Have you installed BashMatic using the bootstrap script? If not,\n"
  printf "Run the following command:\n\n"

  printf "   ${bldylw}cd ~/; curl -fsSL http://bit.ly/bashmatic-bootstrap | /usr/bin/env bash${clr}\n\n"

  (( ${__ran_as_script} )) && exit 1 || return 1
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

source "${BashMatic__LibDir}/Initializer.bash"
