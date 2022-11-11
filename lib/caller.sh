#!/usr/bin/env bash

# Prints a stack trace, from the most recent to the least recent, including
# frame number, file name, and location, and function name.
#
# Example:
#   0 [ t.bash:5                                 ]: c
#   1 [ /Users/kig/.bashmatic/lib/7z.sh:48       ]: b
#   2 [ t.bash:10                                ]: a
#   3 [ t.bash:13                                ]: main
#
caller.stack() {
  local index=${1:-"-1"}
  while true; do
    index=$((index + 1))
    caller ${index} 2>&1 1>/dev/null || break

    local -a frame=($(caller ${index} | tr ' ' '\n'))
    printf "%3d [ %-40.40s ]: %s\n" ${index} "${frame[2]}:${frame[0]}" "${frame[1]}"
  done
}

# Same thing, shorter.
stack.frame() {
  caller.stack 0
}


