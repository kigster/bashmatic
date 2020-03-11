#!/usr/bin/env bats
#

load test_helper

source lib/util.sh

set -e

@test "util.generate-password() generates correct length" {
  len=64

  pw1=$(util.generate-password ${len})
  pw2=$(util.generate-password ${len})

  [ ${#pw1} -eq ${len} ] &&
  [ ${#pw2} -eq ${len} ]
}

@test "util.generate-password() generates different passwords" {
  len=64

  pw1=$(util.generate-password ${len})
  pw2=$(util.generate-password ${len})

  [ "${pw1}" != "${pw2}" ]
}

moo() {
  export MOO_CALLED=true
}

@test "util.call-if-function() - when function exists" {
  set -e
  [[ -z ${MOO_CALLED} ]]

  util.call-if-function moo
  [[ ${MOO_CALLED} == "true" ]]
}

@test "util.call-if-function() - when function does not exist" {
  set +e
  util.call-if-function asdfasdfsdf
  code=$?
  set -e
  [[ ${code} -eq 1 ]]
}

@test "util.is-a-function() - when function exists" {
  util.is-a-function util.generate-password
}

@test "util.is-a-function() - when function does not exists" {
  set +e
  util.is-a-function util.generate-password123
  code=$?
  set -e
  [ $code -ne 0 ]
}
