#!/usr/bin/env bats

load "test_helper"
load "lib/config.sh"
load "lib/output.sh"

@setup() {
  set -e
  config.set-file "${TOOLS_PATH}/test/fixtures/config.yml"
}

@test "TOOLS_PATH" {
  [[ -z ${TOOLS_PATH} ]] &&
  [[ -d ${TOOLS_PATH} ]] && 
  [[ -f ${TOOLS_PATH}/bin/setup ]] && 
  [[ -f ${TOOLS_PATH}/bin/encrypt ]]
}

@test "set/get file" {
  [ $(config.get-file) == "${TOOLS_PATH}/test/fixtures/config.yml" ]
}



