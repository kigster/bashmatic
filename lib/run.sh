#!/usr/bin/env bash

run() {
  .run $@
  return ${LibRun__LastExitCode}
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
