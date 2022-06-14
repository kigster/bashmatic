#!/usr/bin/env bats
load test_helper

source lib/time.sh
source lib/dir.sh
source lib/file.sh

export HOME_DIR=${HOME/\/$(whoami)/}

set -e

setup() {
  export TEMP_DIR=$(file.temp -d)
}

@test "dir.with-file()" {
  local TEMP_DIR="$(mktemp -d)"
  local path="${TEMP_DIR}/a/b/c/d"
  mkdir -p "${path}"

  local a=".a-file"
  local a_path="${TEMP_DIR}/a/b/${a}"
  touch ${a_path}

  local b=".b-file"
  local b_path="${TEMP_DIR}/a/b/c/d/${b}"
  touch ${b_path}

  local a_dir=$(dir.with-file "${a}" "${path}")
  local b_dir=$(dir.with-file "${b}" "${path}")

  [[ ${a_dir} == "${TEMP_DIR}/a/b" && "${b_dir}" == "${TEMP_DIR}/a/b/c/d" ]] 
   
}

@test "dir.short-home ${HOME}/workspace/project" {
  export HOME
  export 
  local dir="$(dir.short-home "${HOME}/workspace/project")"
  echo "${dir}" > /tmp/a
  [[ "${dir}" == '~/workspace/project' ]]
  [[ -z $(echo "${dir}" | grep "${HOME}") ]]
}

@test "dir.short-home /usr/local/bin" {
  [[ $(dir.short-home /usr/local/bin) == "/usr/local/bin" ]]
}

@test "dir.count-slashes() on a folder with 6 slashes" {
  dir="${HOME_DIR}/alex/workspace/ruby/kigster/sym"
  [[ $(dir.count-slashes "${dir}") -eq 6 ]]
}

@test "dir.count-slashes() on a folder with 3 slashes" {
  dir="~/Windows Operating Verbose System/Program Fracken Files Yo"
  [[ $(dir.count-slashes "${dir}") -eq 2 ]]
}

@test "dir.count-slashes() on a folder with no slashes" {
  dir="shit hit the fan"
  [[ $(dir.count-slashes "${dir}") -eq 0 ]]
}

@test "dir.is-a-dir() on an existing dir" {
  dir="/tmp"
  [[ $(dir.is-a-dir "${dir}") -eq true ]]
}

@test "dir.is-a-dir() on a non-existing dir" {
  dir="/tmp/azsdfasdfasd9asd/oazsifoasdufolids/sld5-1474905687.${RANDOM}"
  [[ $(dir.is-a-dir "${dir}") -eq false ]]
}

@test "dir.expand-dir on ~/tmp dir" {
  [[ "$(dir.expand-dir ~/tmp)" =~ "${HOME_DIR}" ]]
  [[ "$(dir.expand-dir ~/tmp)" == "${HOME}/tmp" ]]
}
@test "dir.expand-dir on /tmp/mahaha dir" {
  [[ "$(dir.expand-dir /tmp/mahaha)" == "/tmp/mahaha" ]]
}

@test "dir.expand-dir on tmp dir" {
  [[ "$(dir.expand-dir tmp)" == "$(pwd)/tmp" ]]
}
