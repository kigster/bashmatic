#!/usr/bin/env bats
#
load test_helper

source lib/bashmatic.sh
source lib/shasum.sh
source lib/array.sh
source lib/output.sh

fixtures checksum

set -e

@test "shasum.sha-only()" {
  set -e
  local sha1="$(shasum.sha-only test/fixtures/checksums/comedy_errors_1.adoc)"
  local sha2="$(shasum.sha-only test/fixtures/checksums/comedy_errors_2.md)"
  [[ ${sha1} == "e856053296ed5b14e8ec6882323ad8c77e21546a" ]] &&
  [[ ${sha2} == "7ecc7702c4804ea98c3835d3786a65d52255b8e6" ]]
}

@test "shasum.all-files()" {
  set -e
  local sha1="$(shasum.all-files test/fixtures/checksums/*)"
  [[ ${sha1} == "d55548fda197a22fe82969d8f4cf20869bd1d9b4" ]]
}

@test "shasum.all-files-in-dir test/fixtures/checksums" {
  set -e
  local sha1="$(shasum.all-files-in-dir  test/fixtures/checksums)"
  [[ ${sha1} == "d55548fda197a22fe82969d8f4cf20869bd1d9b4" ]]
}

@test "shasum.all-files-in-dir test/fixtures/checksums '*.adoc'" {
  set -e
  local sha1="$(shasum.all-files-in-dir test/fixtures/checksums '*.adoc')"
  [[ ${sha1} == "d41be3118c7c9ede0ef16ef8338348f13cd2eef7" ]]
}

@test "shasum.all-files-in-dir test/fixtures/checksums '*.md'" {
  set -e
  local sha1="$(shasum.all-files-in-dir test/fixtures/checksums '*.md')"
  [[ ${sha1} == "f9f90c8b04fa1bb7cbe04f6e8e468d163a87e66c" ]]
}


