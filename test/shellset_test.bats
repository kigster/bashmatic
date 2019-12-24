#!/usr/bin/env bats
#

load test_helper
source lib/shell-set.sh

set -e

@test "shell-set::is-set -e" {
  set -e
  shell-set::is-set e && true
}

@test "shell-set::is-set -e subshell" {
  val=$(set -e; shell-set::is-set e && echo "minus-e")
  set -e
  [ ${val} == "minus-e" ]
}

@test "shell-set::is-set +e subshell" {
  val=$(set +e; shell-set::is-set e || echo "plus-e")
  set -e
  [ ${val} == "plus-e" ]
}

