#!/usr/bin/env bash

# This library offers functions that all expect to be piped input into

# from a file
# with comments and
# VAR=VALUE
# returns just the variable names
pipe.extract-variables() {
  sedx -E '/^\(\s*\)#.*$/D;/^\s*$/D;/^[^A-Z].*$/D;s/export //gi;' | cut -d '=' -f 1
}

pipe.remove-hash-comments() {
  sedx -E '/^\(\s*\)?#.*$/D; s/#.*$//g;'
}

pipe.remove-blank-lines() {
  sedx -E '/^$/D'
}
