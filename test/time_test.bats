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

@test 'lib::time::duration::humanize()' {
  [[ $(lib::time::duration::humanize 1)         ==          "01s" ]] 
  [[ $(lib::time::duration::humanize 64)        ==      "01m:04s" ]] 
  [[ $(lib::time::duration::humanize 164)       ==      "02m:44s" ]] 
  [[ $(lib::time::duration::humanize 1644)      ==      "27m:24s" ]] 
  [[ $(lib::time::duration::humanize 1646324)   == "457h:18m:44s" ]] 
}
