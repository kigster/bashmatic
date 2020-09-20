# Bashmatic Utilities
# © 2016-2020 Konstantin Gredeskoul, All rights reserved. MIT License.
# Distributed under the MIT LICENSE.

set +e

export Bashmatic__Test=1

load.deps() {
  declare -a deps=(support file assert)
  for dep in ${deps[@]}; do
    local file="${TEST_BREW_PREFIX}/lib/bats-${dep}/load.bash"
    if [[ -f ${file} ]] ; then 
      load ${file}
    else
      echo "Can't load plugin ${dep}" >&2
    fi
  done
}
#[[ -n ${CI} ]] && color.disable
