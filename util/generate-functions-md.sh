#!/usr/bin/env bash

source ${HOME}/.bashmatic/init.sh

list.modules() {
  ls -1 ${BASHMATIC_HOME}/lib/*.sh | sed -E 's/.*lib\///g; s/\.sh//g'
}

generate() {
  h1 "Generating FUNCTIONS.md..."
  local temp=/tmp/FUNCTIONS.md
  run "rm -f ${temp} && touch ${temp}"

  printf "\n# BashMatic\n\n" >>${temp}

  printf "\n## Table of Contents\n\n" >>${temp}

  printf "\n## List of Bashmatic Modules\n\n" >>${temp}
  for module in $(list.modules); do
    printf "* %s\n" "[${module}](#module-${module})" >>${temp}
  done
  printf "\n## List of Bashmatic Functions\n\n\n" >>${temp}
  local code='```'

  for module in $(list.modules); do
    printf "${bldblu}—————————————————————— ${module} ——————————————————————————\n"
    printf "\n%s\n\n" "### Module \`${module}\`" >>${temp}
    printf "${bldgrn}❯"
    for function in $(bashmatic.functions-from ${module} 1); do
      printf "❯"
      echo '#### `'$function'`' >>$temp
      printf "\n%sbash\n" ${code} >>${temp}
      type ${function} | tail +2 >>${temp}
      printf "\n%s\n\n" ${code} >>${temp}
    done

    printf "\n%s\n\n" "---" >>${temp}
    printf "${clr}\n"
  done

  printf "\n\n## Copyright\n\n" >>${temp}
  printf "\n\n© 2020 Konstantin Gredeskoul, All rights reserved, MIT License." >>${temp}

  run "mv ${temp} ${HOME}/.bashmatic"
  eval "code ~/.bashmatic/FUNCTIONS.md"
}

generate
