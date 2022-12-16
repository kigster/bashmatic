#!/usr/bin/env bats
# vim: ft=bash

load test_helper

source lib/time.sh
source lib/util.sh
source lib/user.sh


# duration 'sleep 1.1'
# 0 minutes 1.100 seconds
@test 'time.a-command' {
  set -e
  time.a-command 'sleep 1.2' | grep -E -q "0 minutes 1.[0-9]{3} seconds"
}

@test 'date.now.with-time.and.zone()' {
  if [[ -n ${CI} ]] ; then
    echo "Skipping this test on CI...."
  else
    local t=$(date.now.with-time.and.zone)
    local zone="$(date '+%z')"
    set -e
    [[ ${t} =~ ${zone} ]]
  fi
}

@test "time.with-duration()" {
  time.with-duration.start
  sleep 0.1
  local -a duration
  duration=( $(time.with-duration.end) )
  local period=${duration[0]}
  local units=${duration[1]}

  set -e
  [[ "$units" == "sec" ]] &&
  [[ "$period" =~ ^[0-9]+(\.[0-9]+)?$ ]]
}

@test "time.with-duration(namespace)" {
  time.with-duration.start moofie
  sleep 0.1
  export -a duration=( $(time.with-duration.end moofie) )
  export period="${duration[-2]}"
  export units="${duration[-1]}"

  echo ${period} > /tmp/aaa
  echo ${inits} >> /tmp/aaa

  set -e
  [[ ${period} =~ 0\.[0-9][0-9][0-9]$ ]] &&
  [[ ${units} == "sec" ]]
}

@test "millis()" {
  set -e
  then=$(millis)
  sleep 0.01
  now=$(millis)

  set -e
  [ ${now} -gt 0 ] &&
  [ ${now} -gt ${then} ] &&
  [ $(( ${now} - ${then})) -gt 10 ] &&
  [ $(( ${now} - ${then})) -lt 150 ]
}

@test "epoch()" {
  set -e
  then=$(epoch)
  sleep 1
  now=$(epoch)

  set -e
  [ ${now} -gt 0 ] &&
  [ ${now} -gt ${then} ] &&
  [ $(( ${now} - ${then})) -gt 0 ] &&
  [ $(( ${now} - ${then})) -lt 3 ]
}

@test "time.epoch.minutes-ago()" {
  set -e
  one_minute_ago=$(time.epoch.minutes-ago)
  now=$(epoch)
  diff=$(( ${now} - ${one_minute_ago} ))
  [[ ${diff} -lt 65 && ${diff} -gt 58 ]]
}

@test "time.now.with-ms()" {
  set -e
  local now=$(time.now.with-ms)
  [[ "${now}" =~ [0-9]?[0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9]$ ]]
}

@test "time.epoch-to-iso()" {
  set -e
  now=$(time.epoch-to-iso $(epoch))
  [[ "${now}" =~ "00:00" ]]
}

@test 'time.epoch-to-local()' {
  set -e
  date=$(time.epoch-to-local $(epoch))
  [[ "${date}" =~ $(date '+%Y') ]]
}

@test 'time.duration.humanize()' {
  set -e
  [[ $(time.duration.humanize 1)         ==          "01s" ]]
  [[ $(time.duration.humanize 64)        ==      "01m:04s" ]]
  [[ $(time.duration.humanize 164)       ==      "02m:44s" ]]
  [[ $(time.duration.humanize 1644)      ==      "27m:24s" ]]
  [[ $(time.duration.humanize 1646324)   == "457h:18m:44s" ]]
}

