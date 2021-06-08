#!/usr/bin/env bats

source lib/sedx.sh
source lib/util.sh

set -e

moo() {
  echo "config/moo.enc" | sedx 's/\.(sym|enc)$//g'
}

@test "sedx() without gnu-sed installed" {
  if [[ -n $(which brew) ]]; then
    if [[ -n "${INTEGRATION_TEST}" ]]; then
      brew uninstall --force --quiet gnu-sed 2>&1 | cat >/dev/null
      result=$(moo)
      [[ "${result}" == "config/moo" ]]
    else
      true
    fi
  else
    false
  fi
}

@test "sedx() with gnu-sed installed" {
  if [[ -n $(which brew) && -z $(which gsed) ]]; then
    brew install --force --quiet gnu-sed 2>&1 | cat >/dev/null
  fi
  result=$(moo)
  [[ "${result}" == "config/moo" ]]
}
