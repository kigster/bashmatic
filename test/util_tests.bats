#!/usr/bin/env bats

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

@test "is-function with a valid function" {
  set +e
  is-function lib::util::generate-password
  code=$?
  [[ ${code} -eq 0 ]]
}

@test "is-function with a invalid function" {
  set +e
  is-function asdf::sdfkljdsf::sdfksdjf
  code=$?
  [[ ${code} -ne 0 ]]
}
