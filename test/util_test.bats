#!/usr/bin/env bats
#

load test_helper

set -e

@test "lib::util::generate-password() generates correct length" {
  len=64

  pw1=$(lib::util::generate-password ${len})
  pw2=$(lib::util::generate-password ${len})

  [ ${#pw1} -eq ${len} ] &&
  [ ${#pw2} -eq ${len} ]
}

@test "lib::util::generate-password() generates different passwords" {
  len=64

  pw1=$(lib::util::generate-password ${len})
  pw2=$(lib::util::generate-password ${len})

  [ "${pw1}" != "${pw2}" ]
}

function moo() {
  export MOO_CALLED=true
}

@test "lib::util::call-if-function() - when function exists" {
  set -e
  [[ -z ${MOO_CALLED} ]] 

  lib::util::call-if-function moo
  [[ ${MOO_CALLED} == "true" ]] 
}

@test "lib::util::call-if-function() - when function does not exist" {
  set +e
  lib::util::call-if-function asdfasdfsdf
  code=$?
  set -e
  [[ ${code} -eq 1 ]]
}

@test "lib::util::is-a-function() - when function exists" {
  lib::util::is-a-function lib::util::generate-password
}

@test "lib::util::is-a-function() - when function does not exists" {
  set +e
  lib::util::is-a-function lib::util::generate-password123
  code=$?
  set -e
  [ $code -ne 0 ]
}
