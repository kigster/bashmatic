#!/usr/bin/env bats

load test_helper

source lib/ruby.sh
source lib/gem.sh
source lib/util.sh

@test "gem.gemfile.version returns correct 4-part version" {
  gem.cache-refresh
  set -e
  cp test/Gemfile.lock .
  result="$(gem.gemfile.version activesupport)"
  [ "${result}" = "6.0.3.1" ]
}

@test "gem.gemfile.version returns correct 3-part version" {
  gem.cache-refresh
  set -e
  cp test/Gemfile.lock .
  result="$(gem.gemfile.version simple-feed)"
  [ "${result}" = "3.0.1" ]
}
