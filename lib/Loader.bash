#!/usr/bin/env bash
#
# This is the primary loader script for all of BashMatic goodies.
#
# To use it, add `source ~/.bashmatic/lib/Loader.bash` to your
# ~/.bash_profile or any other initialization file.
#
# If you choose to install bashmatic to another folder, please set
# BASHMATIC_HOME environment variable to point to the installation.
# Once set, initialize bashmatic like so:
#
#   export BASHMATIC_HOME=~/.custom/path/bashmatic
#   eval $("${BASHMATIC_HOME}/bin/init")
#

set +e

export True=1
export False=0

export BashMatic__DefaultHome="${HOME}/.bashmatic"
export BashMatic__SearchTarget="Loader.bash"

# Public function for everyone to use ;)
# first argument is the numeric exit code.
# second and third, etc. args are optional message to print.
bashmatic::exit-or-return() {
  local code="${1:-0}"; shift
  local message=$(echo "${*}" | tr '\n' ' ')

  if [[ -n "${message}" ]]; then
    if [[ ${code} -eq 0 ]]; then
      printf "\n   ${bldgrn} ✅  ${message}${clr}\n\n"
    else
      printf "\n   ${bldylw} ⚠️  ${message}${clr}\n\n"
    fi
  fi

  [[ -n ${__ran_as_script} ]] && {
    ( [[ -n ${ZSH_EVAL_CONTEXT} && ${ZSH_EVAL_CONTEXT} =~ :file$ ]] || \
    [[ -n $BASH_VERSION && $0 != "$BASH_SOURCE" ]]) && __ran_as_script=0 || __ran_as_script=1
  }

  (( ${__ran_as_script} )) && exit ${code} || return ${code}
}

__bashmatic::phone-home() {
  #—————— determine bashmatic home folder —————————————————
  # Set BASHMATIC_HOME externally if your bashmatic is not installed in ~/.bashmatic
  local -a locations_to_try=("${BASHMATIC_HOME}" "${BashMatic__DefaultHome}")
  local try_path

  for try_path in ${locations_to_try[@]}; do
    export BashMatic__Loader="${try_path}/lib/Loader.bash"
    [[ -s "${BashMatic__Loader}" ]] && {
      export BASHMATIC_HOME="${try_path}"
      return 0
    }
  done
  return 127
}

__bashmatic::home-not-found() {
  # Can't use our UI functions here, since we aren't loaded yet.
  printf "${bldred}ERROR: ${clr}Can not find ${bldylw}${BashMatic__SearchTarget}${clr} file, aborting.\n\n"

  # dc = default color
  local dc="${txtcyn}"
  printf "${dc}
    We suggest that you install BashMatic to ${bldylw}${BashMatic__DefaultHome}${dc}

    If you choose to install BashMatic to another location, don't forget to set the
    ${bldylw}BASHMATIC_HOME${dc} environment variable to point to the installation.

    Here is an example you should add to your ~/.bash_profile:${bldgrn}

      export BASHMATIC_HOME=~/.custom/path/bashmatic
      eval \$(\"\${BASHMATIC_HOME}/bin/init\")

    ${dc}Or you could just install it via Curl and the bootstrap script on Github:${bldgrn}

      cd ~/; curl -fsSL http://bit.ly/bashmatic-bootstrap | /usr/bin/env bash${dc}

    ${dc}Whichever method you prefer, we home you can get BashMatic running soon!\n\n"  \
    sed -E 's/^\s+//g'
  return 0
}

bashmatic::source::directory() {
  local folder=${1}
  local bash_file

  [[ -n ${BASHMATIC_DEBUG} ]] && printf "sourcing folder ${bldylw}$folder${clr}...\n" >&2
  # Let's list all lib files
  local -a files=($(ls -1 ${folder}/*.sh))

  for bash_file in ${files[@]}; do
    [[ -n ${BASHMATIC_DEBUG} ]] && printf "sourcing ${txtgrn}$bash_file${clr}...\n" >&2
    source ${bash_file}
  done
}

__bashmatic::lock-and-loaded() {
  export BashMatic__LibDir=$(dirname "${BashMatic__Loader}")
  [[ -n ${BashMatic__LibDir} ]] && bashmatic::source::directory "${BashMatic__LibDir}"
}

#—————  now load and initialize ourselves finally!  ——————————
bashmatic::initialize() {
  if __bashmatic::phone-home ; then
    __bashmatic::lock-and-loaded
  else
    __bashmatic::home-not-found && bashmatic::exit-or-return
  fi
}

bashmatic::initialize
