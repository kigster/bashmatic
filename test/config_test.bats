#!/usr/bin/env bats

load "test_helper"
require 'lib/config.sh'

set -e

@test "set/get file" {
  dev-tools.config.set-file "${TOOLS_PATH}/test/fixtures/config.yml"

  [[ $(dev-tools.config.get-file) == "${TOOLS_PATH}/test/fixtures/config.yml" ]]
}



