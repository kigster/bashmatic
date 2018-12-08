#!/usr/bin/env bats
load test_helper

@test "lib::gem::gemfile::version returns correct version" {
  set -e
  export LibGem__GemListCache=/tmp/gem_list_test.txt
  rm -f ${LibGem__GemListCache}
  touch ${LibGem__GemListCache}
  cp -f test/Gemfile.lock .
  result=$(lib::gem::gemfile::version activesupport)
  [[ "${result}" == "5.0.7" ]]
  [[ -d test && -f Gemfile.lock ]] && ( rm -f Gemfile.lock ; true ) 
} 

@test "lib::gem::global::latest-version returns the correct version" {
  set -e
  export LibGem__GemListCache=/tmp/gem_list_test.txt
  gem_cache="${LibGem__GemListCache}"
  echo "activesupport (5.1.0, 5.2.0, 4.2.7)" > ${gem_cache}
  result=$(lib::gem::global::latest-version activesupport)
  [[ "${result}" == "5.2.0" ]]
  [[ -f ${gem_cache} ]] && ( rm -f ${gem_cache}; true )
}
