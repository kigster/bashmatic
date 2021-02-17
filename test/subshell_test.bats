#!/usr/bin/env bats

load test_helper

set -e

@test "bashmatic.detect-subshell - running a script that wants to be run" {
  /usr/bin/env bash ./test/helpers/test-subshell.sh
  [[ $? -eq 0 ]]
}

@test "bashmatic.detect-subshell - sourcing in script that wants to be run" {
  set +e
  /usr/bin/env bash -c 'source ./test/helpers/test-subshell.sh'
  [[ $? -eq 1 ]]
}

@test "bashmatic.detect-subshell - running a script that wants to be sourced in" {
  set +e
  /usr/bin/env bash ./test/helpers/test-source.sh
  [[ $? -eq 1 ]]
}

@test "bashmatic.detect-subshell - sourcing a script that wants to be sourced in" {
  /usr/bin/env bash -c 'source ./test/helpers/test-source.sh'
  [[ $? -eq 0 ]]
}
