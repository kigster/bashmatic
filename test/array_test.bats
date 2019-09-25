#!/usr/bin/env bats 

load test_helper

@test "lib::array::join with a pipe" {
  declare -a array=("a string" "test2000" "hello" "one")
  result=$(lib::array::join '|' "${array[@]}")
  echo ${result}
  [[ "${result}" == "a string|test2000|hello|one" ]]
}

@test "lib::array::join with comma" {
  unset result array code status
  declare -a array=(uno dos tres quatro cinco seis)
  set -e
  result=$(lib::array::join ', ' "${array[@]}")
  [[ ${result} == "uno, dos, tres, quatro, cinco, seis" ]]
  [[ $status -eq 0 ]]
}

@test "lib::array::join-piped" {
  declare -a array=(orange yellow red)
  [[ $(lib::array::join-piped "${array[@]}") == "orange | yellow | red" ]]
  [[ $status -eq 0 ]]
}

@test "lib::array::contains-element() when one element exists" {
  declare -a array=("a string" "test2000" "hello" "one")
  lib::array::contains-element test2000 "${array[@]}" && true
}

@test "lib::array::contains-element() when another element exists" {
  declare -a array=("a string" "test2000" "hello" "one")
  set +e
  lib::array::contains-element "one" "${array[@]}"; code=$?
  set -e
  [[ ${code} -eq 0 ]]
}

@test "lib::array::contains-element() when element does not exist" {
  declare -a array=("a string" "test2000" "hello" "one")
  set +e
  lib::array::contains-element "two" "${array[@]}"; local code=$?
  set -e
  [[ ${code} -eq 1 ]]
}

@test "array-contains-element() when element exists" {
  declare -a array=("a string" "test2000" "hello" "one")
  array-contains-element test2000 "${array[@]}" && true
}

@test "array-contains-element() when element exists and has a space" {
  declare -a array=("a string" "test2000" "hello" "one")
  array-contains-element "a string" "${array[@]}" && true
}

@test "array-contains-element() when element exists, using return value" {
  declare -a array=("a string" "test2000" "hello" "one")
  set +e
  array-contains-element test2000 "${array[@]}"; code=$?
  set -e
  [[ ${code} -eq 0 ]]
}

@test "array-contains-element() when element exists" {
  declare -a array=("a string" "test2000" "hello" "one")
  [[ $(array-contains-element hello "${array[@]}") == "true" ]]
}

@test "array-contains-element() when element is a substring of an existing element" {
  declare -a array=("a string" "test2000" "hello" "one")
  [[ $(array-contains-element hell "${array[@]}") == "false" ]]
}

@test "array-contains-element when element does not exist" {
  declare -a array=("a string" "test2000" "hello" "one")
  [[ $(array-contains-element 123 "${array[@]}")  == "false" ]]
}

@test "array-contains-element when element does not exist and is a space " {
  declare -a array=("a string" "test2000" "hello" "one")
  [[ $(array-contains-element ' ' "${array[@]}")  == "false" ]]
}

@test "array-bullet-list" {
  declare -a array=(kig pig)
  tmp=$(mktemp)
  array-bullet-list "${array[@]}" > ${tmp}
  
  lines=$(cat "${tmp}" | wc -l | tr -d ' ')
  echo "${tmp}"

  result="$(cat "${tmp}")"
  [[ ${lines} -eq 2                              ]]
  [[ $(cat "${tmp}" | egrep -c ' • kig') -eq 1  ]]
  [[ $(cat "${tmp}" | egrep -c ' • pig') -eq 1  ]]
}
