#!/usr/bin/env bats
# vim: ft=bash

set +e
load test_helper
source lib/healthsherpa.sh
set +e

@test "healthsherpa" {
  set -e
  [[ 0 -eq 0 ]]
}

