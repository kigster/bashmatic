
bashmatic-validate() {
  local perm="$1"

  local permit_script=false
  local permit_source=false

  [[ ${perm} =~ 'script' ]] && permit_script=true
  [[ ${perm} =~ 'source' ]] && permit_source=true

  export __ran_as_script

  [[ -n ${DEBUG} ]] && {
    printf "permit script: ${permit_script}\n"
    printf "permit source: ${permit_source}\n"
    printf "ran as script: ${__ran_as_script}\n"
  }
    
  # If you want to be able to tell if the script is run or source:
  ( [[ -n ${ZSH_EVAL_CONTEXT} && ${ZSH_EVAL_CONTEXT} =~ :file$ ]] || \
    [[ -n $BASH_VERSION && $0 != "$BASH_SOURCE" ]]) && __ran_as_script=0 || __ran_as_script=1

  (( $__ran_as_script )) && [[ $permit_script == false ]] && {
    error "This script sould not be ran as a script. Try sourcing it in?"
    echo 
    sleep 3
    return 1
  }

  (( $(( $__ran_as_script - 1)) )) && [[ $permit_source == false ]] && {
    error "This script should be executed as is, not sourced in..."
    echo
    sleep 3
    exit 1
  }
}


