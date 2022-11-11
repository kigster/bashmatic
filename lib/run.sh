#!/usr/bin/env bash

export LibRun__AskDeclineFunction="exit"
export LibRun__AskDeclineFunction__Default="exit"

run() {
  .run $@
  return "${LibRun__LastExitCode}"
}

# Waits until the user presses any key to continue.
run.ui.press-any-key() {
  local prompt="$*"
  trap 'return 1' INT
  [[ -z ${prompt} ]] && prompt="Press any key to continue..."
  br
  printf "    ${txtgrn}${italic}${prompt} ${clr}  "
  read -r -s -n1 key
  cursor.rewind
  printf "                                                           "
  cursor.up 2
  cursor.rewind
  echo
}

# Usage:
#  run.ui.ask-user-value GITHUB_ORG "Please enter the name of your Github Organization:"
#  sets the value of $GITHUB_ORG to whatever user entered.
run.ui.ask-user-value() {
  local variable="$1"
  shift
  local text="$*"
  local user_input

  trap 'echo; echo Aborting at user request... ; echo; abort; return' int

  ask "${text}"
  # create a variable to hold the input
  read user_input
  # Check if string is empty using -z. For more 'help test'
  if [[ -z "${user_input}" ]]; then
    error "Sorry, I didn't get that. Please try again or press Ctrl-C to abort."
    return 1
  else
    eval "export ${variable}=\"${user_input}\""
    return 0
  fi
}

run.ui.retry-command() {
  local command="$*"
  local retries=5

  n=0
  until [ $n -ge ${retries} ]; do
    [[ ${n} -gt 0 ]] && info "Retry number ${n}..."

    command && break # substitute your command here

    n=$(($n + 1))
    sleep 1
  done
}

run.ui.get-user-value() {
  run.ui.retry-command run.ui.ask-user-value "${@}"
}

# Ask the user if they want to proceed, defaulting to Yes.
# Choosing no exits the program. The arguments are printed as a question.
run.ui.ask() {
  local question=$*
  local func="${LibRun__AskDeclineFunction}"

  # reset back to default
  export LibRun__AskDeclineFunction="${LibRun__AskDeclineFunction__Default}"

  echo
  inf "${bldcyn}${question}${clr} [Y/n] ${bldylw}"
  read a 2>/dev/null
  code=$?
  if [[ ${code} != 0 ]]; then
    error "Unable to read from STDIN."
    eval "${func} 12"
  fi
  echo
  if [[ ${a} == 'y' || ${a} == 'Y' || ${a} == '' ]]; then
    info "${bldblu}Roger that."
    info "Let's just hope it won't go nuclear on us :) 💥"
    hr
    echo
  else
    info "${bldred}(Great idea!) Abort! Abandon ship!  🛳   " >&2
    hr >&2
    echo
    eval "${func} 1"
  fi
}


