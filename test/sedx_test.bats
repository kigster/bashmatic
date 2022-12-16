#!/usr/bin/env bats

load test_helper

source lib/sedx.sh
source lib/sym.sh
source lib/util.sh
source lib/user.sh
source lib/is.sh

set -e

config-moo() {   
  echo "config/moo.enc" | sedx 's/\.(sym|enc)$//g'
}

@test "sedx() with gnu-sed installed" {
  export BASHMATIC_OS="${BASHMATIC_OS_NAME}"
  if [[ ${BASHMATIC_OS} == "darwin" ]]; then
    if [[ -n $(which brew) && -z $(which gsed) ]]; then
      brew install --force --quiet gnu-sed 2>&1 | cat >/dev/null
    fi
    result=$(config-moo)
    [[ "${result}" == "config/moo" ]]
  else
    true
  fi
}

@test "sedx() without gnu-sed installed" {
  export BASHMATIC_OS="${BASHMATIC_OS_NAME}"
  if [[ ${BASHMATIC_OS} == "darwin" ]]; then
    if [[ -n $(which brew) ]]; then
      if [[ -n "${INTEGRATION_TEST}" ]]; then
        brew uninstall --force --quiet gnu-sed 2>&1 | cat >/dev/null
        result=$(config-moo)
        [[ "${result}" == "config/moo" ]]
      else
        true
      fi
    else
      false
    fi
  else
    true
  fi
}


