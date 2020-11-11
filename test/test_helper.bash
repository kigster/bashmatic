# Bashmatic Utilities
# vim: ft=bash
# © 2016-2020 Konstantin Gredeskoul, All rights reserved. MIT License.
# Distributed under the MIT LICENSE.

os="$(uname -s | tr [:upper:] [:lower:])"
set +e

export Bashmatic__Test=1

load.deps() {
  ( git submodule update && git submodule sync ) 1>/dev/null 2>&1
  declare -a deps=(support file assert)
  for dep in ${deps[@]}; do
    local file="${TEST_BREW_PREFIX}/lib/bats-${dep}/load.bash"
    if [[ -f ${file} ]]; then
      load ${file}
    else
      echo "Can't load plugin ${dep}" >&2
    fi
  done
}
#[[ -n ${CI} ]] && color.disable
