#!/usr/bin/env bash

# This library offers functions that all expect to be piped input into

# from a file
# with comments and
# VAR=VALUE
# returns just the variable names
pipe.extract-variables() {
  sedx '/^\(\s*\)#.*$/D; /^\s*$/D; /^[^A-Z].*$/D' | sedx 's/export //ig' | cut -d '=' -f 1
}

pipe.remove-hash-comments() {
  sedx '/^\(\s*\)?#.*$/D; s/#.*$//g;'
}

pipe.remove-blank-lines() {
  sedx '/^$/D'
}


