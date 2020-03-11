#!/usr/bin/env bats
#
load test_helper

# file.exists-and-newer-than
# file.gsub
# file.install_with_backup
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

source lib/file.sh

set -e

@test "file.source-if-exists()" {
  set -e
  file.source-if-exists test/fixtures/a.sh
  file.source-if-exists test/fixtures/b.sh
}

@test "file.map.shell-scripts()" {
  set -e
  
  declare -a files_array
  eval "$(files.map.shell-scripts test/fixtures files_array)"
  [[ ${#files_array[@]} -eq 2 ]]
}

@test "file.size()" {
  set -e
  [[ $(file.size test/fixtures/b.sh) -eq 13 ]]
}
