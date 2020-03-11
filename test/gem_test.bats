#!/usr/bin/env bats
load test_helper

source lib/ruby.sh
source lib/gem.sh
source lib/hbsed.sh
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
  [[ "${result}" == "5.2.0" ]]
  [[ -d test && -f Gemfile.lock ]] && ( rm -f Gemfile.lock ; true )
}

@test "gem.global.latest-version returns the correct version" {
  set -e
  gem.configure-cache
  mkdir -p $(dirname ${LibGem__GemListCache})
  gem.cache-refresh
  gem_cache="${LibGem__GemListCache}"
  echo "activesupport (5.1.0, 5.2.0, 4.2.7)" > ${gem_cache}
  result=$(gem.global.latest-version activesupport)
  [[ "${result}" == "5.2.0" ]]
  [[ -f ${gem_cache} ]] && ( rm -f ${gem_cache}; true )
}
