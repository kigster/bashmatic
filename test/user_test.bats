#!/usr/bin/env bats
load test_helper

source lib/is.sh
source lib/user.sh
source lib/output.sh

set -e

function setup-pairs() {
  user.pairs.set-file "test/fixtures/.pairs"
}

@test "user.pairs.firstname" {
  set -e
  setup-pairs
  [[ $(user.pairs.firstname hst) == "Hunter" ]]
  [[ $(user.pairs.firstname fred) == "Freddie" ]]
  [[ $(user.pairs.firstname eb:) == "Eric" ]]
}

@test "user.pairs.lastname" {
  set -e
  setup-pairs
  [[ $(user.pairs.lastname hst) == "Thompson" ]]
  [[ $(user.pairs.lastname fred) == "Mercury" ]]
  [[ $(user.pairs.lastname eb:) == "Bana" ]]
}


@test "user.pairs.username" {
  set -e
  setup-pairs
  [[ $(user.pairs.username hst) == "highaskite" ]]
  [[ $(user.pairs.username fred) == "queen" ]]
  [[ $(user.pairs.username eb:) == "eric" ]]
}

