#!/usr/bin/env bats
#

load test_helper

source lib/time.sh
source lib/util.sh

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

@test "time.epoch.minutes-ago()" {
  one_minute_ago=$(time.epoch.minutes-ago)
  now=$(epoch)
  diff=$(( ${now} - ${one_minute_ago} ))
  [[ ${diff} -lt 65 && ${diff} -gt 58 ]]
}

@test "time.epoch-to-iso()" {
  now=$(time.epoch-to-iso $(epoch))
  [[ "${now}" =~ "00:00" ]]
}

@test 'time.epoch-to-local()' {
  date=$(time.epoch-to-local $(epoch))
  [[ "${date}" =~ $(date '+%Y') ]]
}

@test 'time.duration.humanize()' {
  [[ $(time.duration.humanize 1)         ==          "01s" ]]
  [[ $(time.duration.humanize 64)        ==      "01m:04s" ]]
  [[ $(time.duration.humanize 164)       ==      "02m:44s" ]]
  [[ $(time.duration.humanize 1644)      ==      "27m:24s" ]]
  [[ $(time.duration.humanize 1646324)   == "457h:18m:44s" ]]
}
