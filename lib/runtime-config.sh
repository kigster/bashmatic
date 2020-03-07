#!/usr/bin/env #!/usr/bin/env bash
#
# Created: Sun Oct  7 17:45:18 PDT 2018
# Author: Konstantin Gredeskoul
#
# DESCRIPTION
#
# This library offers a convenient way to define how the `run` function
# behaves.

# For example, to configure the next command to abort on error and show
# comamnd output, previously you would have to do this:
#
#     $ export LibRun__AbortOnError=${True}
#     $ export LibRun__ShowCommandOutput=${True}
#
# Well, now the equivalent is this command:
#
#     $ run.set-next show-output-on abort-on-error
#
# To set the "default" values that affect all subasequent comands,
# use run.set-all.

run.set-next() {
  ____run.configure next "$@"
}

run.set-all() {
  ____run.configure all "$@"
}

run.set-next.list() {
  set | egrep '^____run.set.next' | awk 'BEGIN{FS="."}{print $4}' | hbsed 's/[() ]//g'
}

run.set-all.list() {
  set | egrep '^____run.set.all' | awk 'BEGIN{FS="."}{print $4}' | hbsed 's/[() ]//g'
}

run.inspect() {
  run.inspect
}

##############################################################################
# Command control for all invocations of the run() method.
# These come in two flavors: run:set-next... and run:set-all....
##############################################################################

### NEXT COMMAND
____run.set.next.show-detail-on() {
  export LibRun__Detail=${True}
}
____run.set.next.show-detail-off() {
  export LibRun__Detail=${False}
}

### show details

____run.set.next.show-output-on() {
  export LibRun__ShowCommandOutput=${True}
}
____run.set.next.show-output-off() {
  export LibRun__ShowCommandOutput=${False}
}

### show command itself

____run.set.next.show-command-on() {
  export LibRun__ShowCommand=${True}
}
____run.set.next.show-command-off() {
  export LibRun__ShowCommand=${False}
}

### Reactions to error conditions

____run.set.next.abort-on-error() {
  export LibRun__AbortOnError=${True}
  export LibRun__AskOnError=${False}
}
____run.set.next.ask-on-error() {
  export LibRun__AskOnError=${True}
  export LibRun__AbortOnError=${False}
}
____run.set.next.continue-on-error() {
  export LibRun__AskOnError=${False}
  export LibRun__AbortOnError=${False}
}

### Turns on DRY-RUN when comamnds are printed but not executed.

____run.set.all.dry-run-on() {
  export LibRun__DryRun=${True}
}
____run.set.all.dry-run-off() {
  export LibRun__DryRun=${False}
}

### Prints some additional verbose shit.
____run.set.all.verbose-on() {
  export LibRun__Verbose=${True}
}
____run.set.all.verbose-off() {
  export LibRun__Verbose=${False}
}

### ALL COMMANDS ###
____run.set.all.show-output-on() {
  ____run.set.next.show-output-on
  export LibRun__ShowCommandOutput__Default=${True}
}
____run.set.all.show-output-off() {
  ____run.set.next.show-output-off
  export LibRun__ShowCommandOutput__Default=${False}
}

____run.set.all.show-command-on() {
  ____run.set.next.show-command-on
  export LibRun__ShowCommand__Default=${True}
}
____run.set.all.show-command-off() {
  ____run.set.next.show-command-off
  export LibRun__ShowCommand__Default=${False}
}

# Error Handling
____run.set.all.abort-on-error() {
  ____run.set.next.abort-on-error
  export LibRun__AbortOnError__Default=${True}
  export LibRun__AskOnError__Default=${False}
}
____run.set.all.ask-on-error() {
  ____run.set.next.ask-on-error
  export LibRun__AskOnError__Default=${True}
  export LibRun__AbortOnError__Default=${False}
}
____run.set.all.continue-on-error() {
  ____run.set.next.continue-on-error
  export LibRun__AskOnError__Default=${False}
  export LibRun__AbortOnError__Default=${False}
}

____run.configure() {
  local type=$1
  [[ ${type} == "all" || ${type} == "next" ]] || {
    error "invalid setting type ${type} — expected 'all' or 'next'"
    return 1
  }

  shift

  [[ -z "$*" ]] && {
    ____run.list-options ${type}
    return
  }

  for feature in $@; do
    local func="____run.set.${type}.${feature}"
    if [[ -z $(type ${func} 2>/dev/null) ]]; then
      error "LibRun feature was not recognized:" "${feature}"
      ____run.list-options ${type}
      return 1
    fi
    ${func}
  done
}
____run.list-options() {
  local type=$1
  local func="run.set-${type}.list"
  local prefix="    • "
  info "List of available configuration features for ${type} command(s):\n"
  printf "${prefix}"

  eval ${func} | tr '\n' ',' | hbsed 's/,$//g' | hbsed "s/,/\\n${prefix}/g"
  echo
}
