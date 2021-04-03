#!/usr/bin/env bats

load "test_helper"
load "lib/config.sh"
load "lib/output.sh"
load "lib/ruby.sh"
load "lib/gem.sh"

set -e

function yaml-config() {
  config.set-file ${YAML_CONFIG}
}

function json-config() {
  config.set-file ${JSON_CONFIG}
}

setup() {
  export JSON_CONFIG="${BATS_CWD}/test/fixtures/config.json"
  export YAML_CONFIG="${BATS_CWD}/test/fixtures/config.yaml"
}

# JSON Tests

@test "config.get-file JSON" {
  json-config
  [[ $(config.get-file) == "${JSON_CONFIG}" ]]
}

@test "config.get-formats JSON" {
  json-config
  [[ $(config.get-format) == "JSON" ]]
}

@test "config.dig JSON database host" {
  json-config
  [[ $(config.dig database host) == "localhost" ]]
}

# YAML Tests
@test "config.get-file YAML" {
  yaml-config
  [[ $(config.get-file) == "${YAML_CONFIG}" ]]
}


@test "config.get-formats YAML" {
  yaml-config
  [[ $(config.get-format) == "YAML" ]]
}

@test "config.dig YAML database host" {
  yaml-config
  [[ $(config.dig database host) == "google.com" ]]
}



