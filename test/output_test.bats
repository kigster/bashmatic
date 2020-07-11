#!/usr/bin/env bats
# vim: ft=bash

set +e
load test_helper

source lib/output.sh
source lib/color.sh
source lib/util.sh

set +e

@test "ascii-pipe() should remove color and other escape sequences from STDIN" {
  set -e
  [ -z "$(printf \"${bldred}HELLO${clr}\n\" | ascii-clean)" ]
}

