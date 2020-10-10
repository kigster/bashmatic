#!/usr/bin/env bats

source lib/runtime.sh
source lib/runtime-config.sh
source lib/run.sh
source lib/output.sh

@test "sets next show command output" {
  set -e
  [[ "${LibRun__ShowCommandOutput}" == 0 ]]
  run.set-next show-output-on
  [[ "${LibRun__ShowCommandOutput}" == 1 ]]
}

@test "sets next abort on error for ALL commands" {
  set -e
  [[ "${LibRun__AbortOnError}" == 0 ]]
  run.set-all abort-on-error
  [[ "${LibRun__AbortOnError}" == 1 ]]
}
