#!/usr/bin/env bats
# vim: ft=bash

set +e
load test_helper

source lib/output.sh
source lib/color.sh
source lib/util.sh

set -e

@test "ascii-pipe() should remove color and other escape sequences from STDIN" {
  set -e
  [ -z "$(printf \"${bldred}HELLO${clr}\n\" | ascii-clean)" ]
}

@test "output.has-stdin()" {
  if [[ -z ${CI} ]]; then
    set -e
    has_stdin=0
    echo hello | output.has-stdin && has_stdin=1
    [[ ${has_stdin} -eq 1 ]]
  fi
}

@test "output.is-pipe()" {
  set -e
  is_pipe=0
  output.is-pipe | cat>/dev/null && is_pipe=1
  [[ ${is_pipe} -eq 1 ]]
} 

@test "output.screen-width.actual()" {
  local w=$(output.screen-width.actual)
  [[ $w -eq $COLUMNS ]]
}

@test "output.screen-height.actual()" {
  local h=$(output.screen-height.actual)
  [[ $h -eq $LINES ]]
}

