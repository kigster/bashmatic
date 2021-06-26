#!/usr/bin/env bats

load test_helper
set -e 
source lib/array.sh
source lib/is.sh
source lib/util.sh
source lib/user.sh

set +e

@test "array.from.command" {
  set -e
  command="echo one; echo 'twenty two'; echo three; echo; echo four"
  array.from.command my_array "${command}"
  [[ ${#my_array[@]} -eq 4 ]] && 
  [[ ${my_array[0]} == "one" ]] && 
  [[ ${my_array[1]} == "twenty two" ]] && 
  [[ ${my_array[2]} == "three" ]] && 
  [[ ${my_array[3]} == "four" ]]
}

@test "array.min/max positive" {
  declare -a array=(1 495 -2 435 12 0 hello)
  local max="$(array.max "${array[@]}")"
  local min="$(array.min "${array[@]}")"
  set -e
  [[ "${max}" -eq 495 && "${min}" -eq -2 ]]
}

@test "array.min/max negative" {
  declare -a array=(-10 -24 -1 shit)
  local max="$(array.max "${array[@]}")"
  local min="$(array.min "${array[@]}")"
  set -e
  [[ "${max}" -eq -1 && "${min}" -eq -24 ]]
}

@test "array.sort" {
  declare -a array=(hello begin again again)
  local sorted="$(array.sort "${array[@]}")"
  set -e
  [[ "${sorted}" == "again again begin hello" ]]
}

@test "array.sort-numeric" {
  declare -a array=(10 12 0 1 1)
  local sorted="$(array.sort "${array[@]}")"
  set -e
  [[ "${sorted}" == "0 1 1 10 12" ]]
}

@test "array.uniq" {
  declare -a array=(begin hello begin again again)
  local sorted="$(array.uniq "${array[@]}")"
  set -e
  [[ "${sorted}" == "again begin hello" ]]
}

@test "array.eval-in-groups-of" {
  declare -a array=(asciidoc asciidoctor autoconf automake awscli bash zsh)
  local out

  set -e
  out="$(array.eval.in-groups-of 2 echo "${array[@]}" | tr '\n' '|')"
  [[ "${out}" == "asciidoc asciidoctor|autoconf automake|awscli bash|zsh|" ]]

  out="$(array.eval.in-groups-of 3 echo "${array[@]}" | tr '\n' '|')"
  [[ "${out}" == "asciidoc asciidoctor autoconf|automake awscli bash|zsh|" ]]
}

@test "array.join with a pipe" {
  set -e
  declare -a array=("a string" "test2000" "hello" "one")
  result=$(array.join '|' "${array[@]}")
  echo ${result}
  [[ "${result}" == "a string|test2000|hello|one" ]]
}

@test "array.join with comma" {
  set -e
  unset result array code status
  declare -a array=(uno dos tres quatro cinco seis)
  set -e
  result=$(array.join ', ' "${array[@]}")
  [[ ${result} == "uno, dos, tres, quatro, cinco, seis" ]]
  [[ $status -eq 0 ]]
}

@test "array.to.piped-list" {
  set -e
  declare -a array=(orange yellow red)
  [[ $(array.to.piped-list "${array[@]}") == "orange | yellow | red" ]]
  [[ $status -eq 0 ]]
}

versions_array() {
  printf "%s" "11 10 9.6 9.5 9.4 "
}

@test "array.includes() an existing floating point element" {
  set -e
  declare -a array=($(versions_array))

  array.includes 11 "${array[@]}" && \
  array.includes 10 "${array[@]}" && \
  array.includes 9.6 "${array[@]}" && \
  array.includes 9.5 "${array[@]}" && \
  array.includes 9.4 "${array[@]}"
}

@test "array.includes() with non-existing floating point element" {
  declare -a array=(11 10 9.6 9.5 9.4)
  set +e
  array.includes 1.1 "${array[@]}"; code=$?
  set -e
  [[ ${code} -ne 0 ]]
}

@test "array.includes() when one element exists" {
  declare -a array=("")
  set +e
  array.includes test2000 "${array[@]}"; code=$?
  set -e
  [[ ${code} -ne 0 ]]
}

@test "array.includes() when another element exists" {
  declare -a array=("a string" "test2000" "hello" "one")
  set -e
  array.includes "one" "${array[@]}"
}

@test "array.includes() when element does not exist" {
  declare -a array=("a string" "test2000" "hello" "one")
  set +e
  array.includes "two" "${array[@]}"; local code=$?
  set -e
  [[ ${code} -eq 1 ]]
}

@test "array.has-element() when element exists using return value"  {
  declare -a array=("a string" "test2000" "hello" "one")
  array.has-element test2000 "${array[@]}" && true
}

@test "array.has-element() when element exists and has a space using return value" {
  declare -a array=("a string" "test2000" "hello" "one")
  array.has-element "a string" "${array[@]}" && true
}

@test "array.has-element() when element exists, using return value" {
  declare -a array=("a string" "test2000" "hello" "one")
  set +e
  array.has-element test2000 "${array[@]}"; code=$?
  set -e
  [[ ${code} -eq 0 ]]
}

@test "array.has-element() when element exists using output" {
  declare -a array=("a string" "test2000" "hello" "one")
  [[ $(array.has-element hello "${array[@]}") == "true" ]]
}

@test "array.has-element() when element is a substring of an existing element using output" {
  declare -a array=("a string" "test2000" "hello" "one")
  [[ $(array.has-element hell "${array[@]}") == "false" ]]
}

@test "array.has-element when element does not exist using output" {
  declare -a array=("a string" "test2000" "hello" "one")
  [[ $(array.has-element 123 "${array[@]}")  == "false" ]]
}

@test "array.has-element when element does not exist and is a space using output" {
  declare -a array=("a string" "test2000" "hello" "one")
  [[ $(array.has-element ' ' "${array[@]}")  == "false" ]]
}

@test "array.to.bullet-list" {
  declare -a array=(kig pig)
  tmp=$(mktemp)
  array.to.bullet-list "${array[@]}" > ${tmp}

  lines=$(cat "${tmp}" | wc -l | tr -d ' ')
  echo "${tmp}"

  result="$(cat "${tmp}")"
  [[ ${lines} -eq 2 ]] &&
  [[ $(egrep ' • kig' -c ${tmp}) -eq 1 ]] &&
  [[ $(egrep ' • pig' -c ${tmp}) -eq 1 ]]
}

@test "array.force-range > outside the range > less than min" {
  local number=10
  local n=$(array.force-range ${number} 100 150 120 200 1000)
  set -e
  [[ ${n} -eq 100 ]]
}

@test "array.force-range > outside the range > greater than max" {
  local number=2400
  local n=$(array.force-range ${number} 100 150 120 200 1000)
  set -e
  [[ ${n} -eq 1000 ]]
}

@test "array.force-range > within the range " {
  local number=101
  local n=$(array.force-range ${number} 100 150 120 200 1000)
  set -e
  [[ ${n} -eq 101 ]]
}

@test "array.force-range > within the range > equal to a boundary " {
  local number=100
  local n=$(array.force-range ${number} 100 150 120 200 1000)
  set -e
  [[ ${n} -eq 100 ]]
}