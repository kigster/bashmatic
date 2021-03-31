#!/usr/bin/env bats
# vim: ft=bash

load test_helper

set -e
source lib/array.sh
source lib/file.sh
source lib/time.sh
source lib/is.sh
source lib/user.sh
source lib/output-utils.sh
source lib/output-boxes.sh
source lib/output-repeat-char.sh
source lib/ruby.sh
source lib/util.sh
source lib/db.sh

setup() {
  set -e
  export ci=""
  [[ -n ${CI} ]] && ci="-ci"
  local config="databases${ci}.yml"
  export bashmatic_db_config="${BATS_TMPDIR}/${config}"
  [[ -f ${bashmatic_db_config} ]] || cp -vn "conf/${config}" ${bashmatic_db_config}
  db.config.set-file ${bashmatic_db_config}
}


@test "db.config.get_file" {
  setup
  set -e
  result="$(db.config.get-file)"
  [ "${result}" == "${bashmatic_db_config}" ]
}

@test "db.config.parse" {
  setup
  set -e
  declare -a result=($(db.config.parse development))
  [ "${result[0]}" == "dbhost" ] &&
  [ "${result[1]}" == "dbname" ] &&
  [ "${result[2]}" == "dbuser" ] &&
  [ "${result[3]}" == "dbpass" ]
}

@test "db run -q postgres 'select extract(epoch from now())' -A -t" {
  set -e
  setup
  result=$(db.actions.run -q postgres 'select extract(epoch from now())::integer' -A -t | tr -d '\n')
  # ❯ db run  -q postgres 'select extract(epoch from now())' -A -t
  # 1616525790.415217
  local epoch=$(epoch)
  # ❯ echo ${seconds:0:9}
  # 161652579
  local diff=$((epoch - result))
  [ ${diff} -gt 2 ]
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



