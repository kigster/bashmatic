#!/usr/bin/env bats
load test_helper

source lib/dir.sh

@test "lib::dir::count-slashes() on a folder with 6 slashes" {
  dir="/Users/alex/workspace/ruby/kigster/sym"
  [[ $(lib::dir::count-slashes "${dir}") -eq 6 ]]
}

@test "lib::dir::count-slashes() on a folder with 3 slashes" {
  dir="~/Windows Operating Verbose System/Program Fracken Files Yo"
  [[ $(lib::dir::count-slashes "${dir}") -eq 2 ]]
}

@test "lib::dir::count-slashes() on a folder with no slashes" {
  dir="shit hit the fan"
  [[ $(lib::dir::count-slashes "${dir}") -eq 0 ]]
}

@test "lib::dir::is-a-dir() on an existing dir" {
  dir="/tmp"
  [[ $(lib::dir::is-a-dir "${dir}") -eq true ]]
}

@test "lib::dir::is-a-dir() on a non-existing dir" {
  dir="/tmp/azsdfasdfasd9asd/oazsifoasdufolids/sld5-1474905687.${RANDOM}"
  [[ $(lib::dir::is-a-dir "${dir}") -eq false ]]
}
