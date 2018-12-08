#!/usr/bin/env bats

source lib/hbsed.sh

function moo() {
  echo "config/moo.enc" | hbsed 's/\.(sym|enc)$//g'
}

@test "hbsed() without gnu-sed installed" {
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

@test "hbsed() with gnu-sed installed" {
  if [[ -n $(which brew) && -z $(which gsed) ]]; then
    brew install --force --quiet gnu-sed 2>&1 | cat >/dev/null
  fi
  result=$(moo)
  [[ "${result}" == "config/moo" ]]
}
