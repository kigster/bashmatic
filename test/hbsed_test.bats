#!/usr/bin/env bats

load test_helper

function moo() {
  echo "config/moo.enc" | hbsed 's/\.(sym|enc)$//g'
}

@test "hbsed() runs the correct sed" {
  result=$(moo)
  [[ "${result}" == "config/moo" ]]
}
