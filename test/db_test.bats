#!/usr/bin/env bats
# vim: ft=bash

load test_helper
source "lib/db.sh"

setup() { 
  set -e 
  rm -f /tmp/a
  export _bashmatic_db_config="${BATS_TMPDIR}/dbtop.yml"
  [[ -f ${_bashmatic_db_config} ]] || cp -n conf/dbtop.yml $BATS_TMPDIR
  set -e
}

@test "db.config.parse" {
  declare -a result=($(db.config.parse development))
  [[ "${result[0]}" == "dbhost" ]] && 
  [[ "${result[1]}" == "dbname" ]] && 
  [[ "${result[2]}" == "dbuser" ]] && 
  [[ "${result[3]}" == "dbpass" ]]

}

@test "db.config.parse non-existent file" {
  export _bashmatic_db_config=${BATS_TMPDIR}/none-existant.yml
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
  local args=$(db.psql.args development)
  [[ "${args}" == "-U dbuser -h dbhost dbname"  ]]
}

@test "db.psql.args.config development — ENV" {
  export PGPASSWORD=
  eval "db.psql.args development || true"
  [[ "${PGPASSWORD}" == "dbpass" ]]
}
