#!/usr/bin/env bats
# vim: ft=bash

load test_helper

set +e

source "lib/db.sh"
source "lib/db_top.sh"
source "lib/output.sh"
source "lib/runtime.sh"
source "lib/time.sh"
source "lib/util.sh"
source "lib/array.sh"

export bashmatic_db_test_config="${BATS_TMPDIR}/dbtop.yml"
export bashmatic_db_config="${bashmatic_db_test_config}"

setup() { 
  set -e
  export bashmatic_db_config="${bashmatic_db_test_config}"
  [[ -f ${bashmatic_db_config} ]] || cp -f ${BASHMATIC_HOME}/test/fixtures/dbtop.yml "${bashmatic_db_config}"
  set -e
}

@test "db.config.parse" {
  unset connection_params
  declare -a connection_params
  connection_params=($(db.config.parse development))

  if [[ "${connection_params[0]}" == "dbhost" && \
        "${connection_params[1]}" == "dbname" && \
        "${connection_params[2]}" == "dbuser" && \
        "${connection_params[3]}" == "dbpass" ]]; then
    return 0
  else
    echo 'Parameters are wrong:' "${connection_params}" >&2
    return 1
  fi
}

@test "db.config.databases" {
  db.config.set-file "${bashmatic_db_test_config}"
  # strip the trailing space
  local result="$(db.config.databases | tr '\n' ' ' | sedx 's/ +$//g')"

  [[ "${result}" == "development" ]]
}

@test "db.config.parse non-existent file" {
  export bashmatic_db_config=${BATS_TMPDIR}/none-existant.yml
  set +e
  db.config.parse development
  local rc=$?
  set -e
  if [[ $rc -eq 2 ]]; then
    return 0
  else
    echo "Should not be able to find non existent file, rc = $rc">&2
    return 1
  fi
}

@test "db.config.parse no arguments" {
  set +e
  db.config.parse
  local rc=$?
  set -e
  if [[ $rc -eq 1 ]]; then
    return 0
  else
    echo "Should not be able to find non existent file, rc = $rc">&2
    return 1
  fi
}

@test "db.psql.args.config development — ARGS" {
  set -e
  [[ "${bashmatic_db_test_config}" == "${bashmatic_db_test_config}" ]] || {
    fail "config is wrong, should be ${bashmatic_db_test_config}, is ${bashmatic_db_config}"
    return 100
  }
 
  local args="$(db.psql.args.config development)"
  [[ "${args}" == "-U dbuser -h dbhost dbname"  ]]
}

@test "db.psql.args.config development — ENV" {
  export PGPASSWORD=
  eval "db.psql.args.config development || true"
  [[ "${PGPASSWORD}" == "dbpass" ]]
}
