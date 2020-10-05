#!/usr/bin/env bats
# vim: ft=bash

set +e
load test_helper
source lib/color.sh
set +e

@test "color.disable" {
  set -e
  color.disable
  [ -z ${txtblu} ]
}

@test "color.enable" {
  set -e
  color.disable
  [ -z ${txtblu} ]
  color.enable
  [ -n ${txtblu} ]
}

