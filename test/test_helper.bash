# Bashmatic Utilities
# vim: ft=bash
# © 2016-2022 Konstantin Gredeskoul, All rights reserved. MIT License.
# Distributed under the MIT LICENSE.

set +e

export Bashmatic__Test=1

load.bashmatic-deps() {
  source "${BASHMATIC_INIT}"  
  load "${BASHMATIC_LIB}/output.sh"
  load "${BASHMATIC_LIB}/output-boxes.sh"
  load "${BASHMATIC_LIB}/output-utils.sh"
  load "${BASHMATIC_LIB}/time.sh"
  load "${BASHMATIC_LIB}/sedx.sh"
  load "${BASHMATIC_LIB}/util.sh"
}

load.deps() {
  load.bashmatic-deps
  ( git submodule update && git submodule sync ) 1>/dev/null 2>&1
  declare -a deps=(support file assert)
  for dep in "${deps[@]}"; do
    local file="${TEST_BREW_PREFIX}/lib/bats-${dep}/load.bash"
    if [[ -f ${file} ]]; then
      h.yellow "Loading Bats ${dep} plugin from Brew..."
      load "${file}"
    else
      h.green "Loading Bats ${dep} plugin from sources..."
      load "${ProjectRoot}/test/test_helper/bats-${dep}/load"
    fi
  done
}

# https://github.com/bats-core/bats-core/blob/master/test/test_helper.bash
emulate_bats_env() {
  export BATS_CWD="$PWD"
  export BATS_TEST_PATTERN="^[[:blank:]]*@test[[:blank:]]+(.*[^[:blank:]])[[:blank:]]+\{(.*)\$"
  export BATS_TEST_FILTER=
  export BATS_ROOT_PID=$$
  export BATS_EMULATED_RUN_TMPDIR="$BATS_TMPDIR/bats-run-$BATS_ROOT_PID"
  export BATS_RUN_TMPDIR="$BATS_EMULATED_RUN_TMPDIR"
  mkdir -p "$BATS_RUN_TMPDIR"
}

fixtures() {
  export FIXTURE_ROOT="$BATS_TEST_DIRNAME/fixtures/$1"
  export RELATIVE_FIXTURE_ROOT="${FIXTURE_ROOT#$BATS_CWD/}"
}

make_bats_test_suite_tmpdir() {
  export BATS_TEST_SUITE_TMPDIR="$BATS_RUN_TMPDIR/bats-test-tmp/$1"
  mkdir -p "$BATS_TEST_SUITE_TMPDIR"
}

filter_control_sequences() {
  "$@" | sed $'s,\x1b\\[[0-9;]*[a-zA-Z],,g'
}

if ! command -v tput >/dev/null; then
  tput() {
    printf '1000\n'
  }
  export -f tput
fi

emit_debug_output() {
  printf '%s\n' 'output:' "$output" >&2
}

test_helper::cleanup_tmpdir() {
  if [[ -n "$1" && -z "$BATS_TEST_SUITE_TMPDIR" ]]; then
    BATS_TEST_SUITE_TMPDIR="$BATS_RUN_TMPDIR/bats-test-tmp/$1"
  fi
  if [[ -n "$BATS_TEST_SUITE_TMPDIR" ]]; then
    rm -rf "$BATS_TEST_SUITE_TMPDIR"
  fi
  if [[ -n "$BATS_EMULATED_RUN_TMPDIR" ]]; then
    rm -rf "$BATS_EMULATED_RUN_TMPDIR"
  fi
}

load ${BASHMATIC_HOME}/test/test_helper/bats-support/load
load ${BASHMATIC_HOME}/test/test_helper/bats-assert/load
load ${BASHMATIC_HOME}/test/test_helper/bats-file/load
