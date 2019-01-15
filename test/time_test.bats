#!/usr/bin/env bats
#
load test_helper

set -e

@test "millis()" {
  then=$(millis)
  sleep 0.01
  now=$(millis)

  [ ${now} -gt 0 ] &&
  [ ${now} -gt ${then} ] &&
  [ $(( ${now} - ${then})) -gt 10 ] &&
  [ $(( ${now} - ${then})) -lt 150 ]
}

@test "epoch()" {
  then=$(epoch)
  sleep 1
  now=$(epoch)

  [ ${now} -gt 0 ] &&
  [ ${now} -gt ${then} ] &&
  [ $(( ${now} - ${then})) -gt 0 ] &&
  [ $(( ${now} - ${then})) -lt 3 ]
}

@test "lib::time::epoch::minutes-ago()" {
  one_minute_ago=$(lib::time::epoch::minutes-ago)
  now=$(epoch)
  diff=$(( ${now} - ${one_minute_ago} ))
  [[ ${diff} -lt 65 && ${diff} -gt 58 ]]
}

@test "lib::time::epoch-to-iso()" {
  now=$(lib::time::epoch-to-iso $(epoch))
  [[ "${now}" =~ "00:00" ]]
}

@test 'lib::time::epoch-to-local()' {
  date=$(lib::time::epoch-to-local $(epoch))
  [[ "${date}" =~ $(date '+%Y') ]]
}
