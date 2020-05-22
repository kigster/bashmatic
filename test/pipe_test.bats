#!/usr/bin/env bats

load test_helper

source lib/pipe.sh

set -e

@test "pipe.extract-variables()" {
  set -e
  output="$(cat test/fixtures/script-with-comments.sh | pipe.extract-variables | tr '\n', ',')"

  [[ "${output}" == "ORGAN,DONATE," ]]
}

@test "pipe.remove-hash-comments() strips hash comments" {
  set -e
  output="$(cat test/fixtures/script-with-comments.sh | pipe.remove-hash-comments | pipe.remove-blank-lines | tr '\n' ',')"

  [[ "${output}" == "ORGAN=HEART,DONATE=YES," ]]
}
