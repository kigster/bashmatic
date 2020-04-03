#!/usr/bin/env bats

load test_helper

source lib/ruby.sh
source lib/gem.sh
source lib/util.sh

@test "gem.gemfile.version returns correct version" {
  set -e
  gem.configure-cache
  gem.cache-refresh
  rm -f ${LibGem__GemListCache}
  mkdir -p $(dirname ${LibGem__GemListCache})
  touch ${LibGem__GemListCache}
  cp -f test/Gemfile.lock .
  result=$(gem.gemfile.version activesupport)
  [[ -d test && -f Gemfile.lock ]] && ( rm -f Gemfile.lock ; true )
  [[ "${result}" == "6.0.2" ]]
}

