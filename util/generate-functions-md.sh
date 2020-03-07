#!/usr/bin/env bash

source ${HOME}/.bashmatic/init.sh

generate() {
  h1 "Generating FUNCTIONS.md..."
  local temp=/tmp/FUNCTIONS.md
  run "rm -f ${temp} && touch ${temp}"

  printf "\n# BashMatic\n" >>${temp}
  printf "\n## Function Listing\n\n\n" >>${temp}
  printf "\n## Function Implementations\n" >>${temp}

  local code='```'
  printf "${bldgrn}"
  for function in $(bashmatic.functions 1); do
    printf "."
    echo '### `'$function'`' >>$temp
    printf "\n%sbash\n" ${code} >>${temp}
    type ${function} | tail +2 >>${temp}
    printf "\n%s\n\n" ${code} >>${temp}
  done

  printf "${clr}\n"

  run "mv ${temp} ${HOME}/.bashmatic"

  eval "code ~/.bashmatic/FUNCTIONS.md"
}

generate
