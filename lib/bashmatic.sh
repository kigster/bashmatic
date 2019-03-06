#
# © 2019 Author: Konstantin Gredeskoul
# https://github.com/kigster/bashmatic
#
#——————————————————————————————————————————————————————————————————————————————————
#
# BashMatic functions that deal with global bashmatic project.
#
#——————————————————————————————————————————————————————————————————————————————————

# 
# pass number of columns to print, default is 2
bashmatic::functions() {
  local columns="${1:-2}"
  [[ -f lib/Loader.bash ]] || {
    printf "\n${bldred}Sorry, but you must run this command from BashMatic's root folder.\n\n"
    return 1
  }
  
  # grab all function names from lib files                  
  # remove private functions                                
  # remove brackets, word 'function' and empty lines        
  # print in two column format                              
  # replace tabs with spaces.. Geez.                        
  # finally, delete more empty lines with only spaces inside
  local screen_width=$(screen-width)
  [[ -z ${screen_width} ]] && screen_width=80
  
  grep --color=never -h -E '^[a-zA-Z::-]+ *\(\)' lib/*.sh |          \
    grep -v '^_' |                                     \
    sed -E 's/\(\) *.*//g; s/^function //g; /^ *$/d' | \
    sort                                             | \
    pr -l 10000 -${columns} -e4 -w ${screen_width}   | \
    expand -8 |                                        \
    sed -E '/^ *$/d'                                 | \
    grep -v 'Page ' 
}

bashmatic::exit-or-return() {
  local code="${1:-0}"
  [[ -n ${__ran_as_script} ]] && {
    ( [[ -n ${ZSH_EVAL_CONTEXT} && ${ZSH_EVAL_CONTEXT} =~ :file$ ]] || \
    [[ -n $BASH_VERSION && $0 != "$BASH_SOURCE" ]]) && __ran_as_script=0 || __ran_as_script=1
  }
  (( ${__ran_as_script} )) && exit ${code} || return ${code}
}

