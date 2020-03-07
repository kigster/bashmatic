#!/usr/bin/env bats
#
load test_helper

set -e

@test "file.source-if-exists()" {
  set -e

  [[ -z ${AAA} ]]
  [[ -z ${BBB} ]]
  [[ -z ${CCC} ]]

  file.source-if-exists test/fixtures/a.sh
  file.source-if-exists test/fixtures/b.sh

  [[ -n ${AAA} ]]
  [[ -n ${BBB} ]]
  [[ -z ${CCC} ]]
}
