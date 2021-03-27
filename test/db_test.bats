#!/usr/bin/env bats
# vim: ft=bash

load test_helper
source "init.sh"

setup() {
  set -e
  rm -f /tmp/a
  export ci=""
  [[ -n ${CI} ]] && ci="-ci"
  export bashmatic_db_config="${BATS_TMPDIR}/databases${ci}.yml"
  [[ -f ${bashmatic_db_config} ]] || cp -n "conf/databases${ci}.yml" $BATS_TMPDIR
  set -e
}


@test "db run -q postgres 'select extract(epoch from now())' -A -t" {
  result=$(bin/db run -q postgres 'select extract(epoch from now())' -A -t | tr -d '\n')
  # ❯ db run  -q postgres 'select extract(epoch from now())' -A -t
  # 1616525790.415217
  seconds=$(( $(millis) / 1000 ))
  # ❯ echo ${seconds:0:9}
  # 161652579
  [[ "${result}" =~ ${seconds:0:8} ]]
}


@test "db.config.parse" {
  declare -a result=($(db.config.parse development))
  [[ "${result[0]}" == "dbhost" ]] &&
  [[ "${result[1]}" == "dbname" ]] &&
  [[ "${result[2]}" == "dbuser" ]] &&
  [[ "${result[3]}" == "dbpass" ]]

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
  local args=$(db.psql.args development)
  [[ "${args}" == "-U dbuser -h dbhost -d dbname"  ]]
}

@test "db.psql.args.config development — ENV" {
  export PGPASSWORD=
  eval "db.psql.args development || true"
  [[ "${PGPASSWORD}" == "dbpass" ]]
}



