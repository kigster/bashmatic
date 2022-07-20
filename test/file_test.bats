#!/usr/bin/env bats
# vim: ft=bash
load test_helper

# file.exists-and-newer-than
# file.gsub
# file.install-with-backup
# file.last-modified-date
# file.last-modified-year
# file.list.filter-existing
# file.list.filter-non-empty
# file.size
# file.size.mb
# file.source-if-exists
# file.stat
# files.find
# files.map
# files.map.shell-scripts

source lib/file-helpers.sh
source lib/file.sh
source lib/time.sh
source lib/util.sh
source lib/bashmatic.sh

@test 'file.count.lines()' {
  local lines=$(file.count.lines test/fixtures/Gemfile.lock.1)
  set -e
  [[ ${lines} -eq 799 ]]
}

@test 'file.count.words()' {
  local words=$(file.count.words test/fixtures/Gemfile.lock.1)
  set -e
  [[ ${words} -eq 1991 ]]
}

@test 'file.first-is-newer-than-second()' {
  local old_file="test/fixtures/a.sh"
  local newer_file="test/fixtures/b.sh"
  touch "${newer_file}"
  
  set -e

  file.first-is-newer-than-second "${newer_file}" "${old_file}" && return 0
}

@test "file.temp()" {
  set -e
  local f="$(file.temp)"
  [[ $(dirname $f) == "/tmp" && $f =~ ".bashmatic" ]]
}

@test "file.source-if-exists()" {
  set -e
  file.source-if-exists test/fixtures/a.sh
  file.source-if-exists test/fixtures/b.sh
}

@test "file.map.shell-scripts()" {
  set -e

  declare -a files_array
  eval "$(files.map.shell-scripts test/fixtures files_array)"
  [[ ${#files_array[@]} -gt 2 ]]
}

@test "file.size()" {
  set -e
  [[ $(file.size test/fixtures/b.sh) -eq 14 ]]
}

@test "file.extension()" {
  set -e
  [[ "$(file.extension test/fixtures/b.sh)" == "sh" ]]
}

@test "file.strip.extension()" {
  set -e
  [[ "$(file.strip.extension test/fixtures/b.sh)" == "test/fixtures/b" ]]
}

@test "file.extension.replace() single file" {
  set -e
  local result="$(file.extension.replace .adoc test/fixtures/b.sh)"
  [[ "${result}" == "test/fixtures/b.adoc" ]]
}

@test "file.extension.replace() list of files: result size comparison" {
  set -e
  local -a files=( $(find lib -type f -name '*.sh') )
  local -a result=( $(file.extension.replace .bash "${files[@]}") )

  # first check the sizes
  [[ ${#result[@]} -eq ${#files[@]} ]]

  # now we'll just check that the random element of the array
  # is as we expect it.

  local index=$(util.random-number ${#result[@]})

  # first check the actual arrays
  [[ "${result[${index}]/.bash/.sh}" == "${files[${index}]}" ]]
}
