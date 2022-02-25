#!/usr/bin/env bats
# vim: ft=bash

setup() {
  load test_helper

  source lib/util.sh
  source lib/output.sh
  source lib/ruby.sh
  source lib/gem.sh
  alias ${GrepCommand} ="grep -E -e "
}

teardown() {
  rm -f Gemfile.lock
}

@test "gem.gemfile.version returns correct 4-part version" {
  gem.cache-refresh
  set -e
  cp test/Gemfile.lock .
  result="$(gem.gemfile.version activesupport)"
  [ "${result}" == "6.0.3.1" ]
}

@test "gem.gemfile.version returns correct 3-part version" {
  gem.cache-refresh
  set -e
  cp test/Gemfile.lock .
  result="$(gem.gemfile.version simple-feed)"
  [ "${result}" == "3.0.1" ]
}

@test "gem.gemfile.version simple-feed == 3.0.1" {
  gem.cache-refresh
  set -e
  result="$(gem.gemfile.version simple-feed test/Gemfile.lock)"
  [ "${result}" == "3.0.1" ]
}

@test "gem.gemfile.version rails [alt-gemfile] == 4.2.11.3" {
  gem.cache-refresh
  set -e
  result="$(gem.gemfile.version rails test/fixtures/Gemfile.lock.1)"
  [ "${result}" == "4.2.11.3" ]
}
