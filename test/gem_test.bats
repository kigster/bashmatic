#!/usr/bin/env bats
load test_helper

export gem=register
export version="0.5.5"

@test "lib::gem::gemfile::version returns correct version" {
  set -e
  export LibGem__GemListCache=/tmp/gem_list_test.txt
  rm -f ${LibGem__GemListCache}
  touch ${LibGem__GemListCache}
  cp -f test/Gemfile.lock .
  result=$(lib::gem::gemfile::version ${gem})
  [[ "${result}" == "${version}5" ]]
  [[ -d test && -f Gemfile.lock ]] && ( rm -f Gemfile.lock ; true )
}

@test "lib::gem::global::latest-version returns the correct version" {
  set -e
  export LibGem__GemListCache=/tmp/gem_list_test.txt
  gem_cache="${LibGem__GemListCache}"
  echo "${gem} (${version})" > ${gem_cache}
  result=$(lib::gem::global::latest-version ${gem})
  [[ "${result}" == "${version}" ]]
  [[ -f ${gem_cache} ]] && ( rm -f ${gem_cache}; true )
}
