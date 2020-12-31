#!/usr/bin/env bats
load test_helper

source ../lib/is.sh
source ../lib/user.sh
source ../lib/output.sh
source ../lib/bashmatic.sh
source lib/cache.sh

set -e

@test "hash in a hash" {
  declare -A cache

  declare -A hash_files
  declare -A hash_colors

  hash_files[.bashrc]=yes
  hash_files[.bash_login]=no

  hash_colors[yellow]="#FFFF00"
  hash_colors[red]="#FF0000"
  hash_colors[blue]="#0000FF"

  cache[files]="${hash_files[@]}"
  cache[colors]="${hash_colors[@]}"

  export cache

  # End of the setup, now to test.
  
  local -A local_colors=${cache["colors"]}
  local -A local_files=${cache["files"]}

  [[ ${local_colors["yellow"]} == "#FFFF00" ]] &&
    [[ -z ${local_colors["green"]} ]] &&
    [[ ${local_files[".bash_login"]} == "no" ]] && 
    [[ ${local_files[".bashrc"]} == "yes" ]]
}

