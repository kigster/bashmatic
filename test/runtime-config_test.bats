#!/usr/bin/env bats

source lib/runtime.sh
source lib/runtime-config.sh
source lib/run.sh
source lib/output.sh

@test "sets next show command output" {
  set -e
  [[ "${LibRun__ShowCommandOutput}" == ${False} ]]
  run.set-next show-output-on
  [[ "${LibRun__ShowCommandOutput}" == ${True} ]]
}

@test "sets next abort on error for ALL commands" {
  set -e
  [[ "${LibRun__AbortOnError}" == ${False} ]]
  run.set-all abort-on-error
  [[ "${LibRun__AbortOnError}" == ${True} ]]
}
