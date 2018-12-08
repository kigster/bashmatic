#!/usr/bin/env bash
#===============================================================================
# Private Functions
#===============================================================================

export RAILS_SCHEMA_RB="db/schema.rb"
export RAILS_SCHEMA_SQL="db/structure.sql"

__lib::db::current_settings() {
  psql $* -X -q -c 'show all' | sort | awk '{ printf("%s=%s\n", $1, $3) }' | sed -E 's/[()\-]//g;/name=setting/d;/^[-+=]*$/d;/^[0-9]*=$/d'
}

__lib::db::by_shortname() {
  if [[ -z $1 || $1 == "master" || $1 == "m" ]]; then
    dbtype=master
    export HB_DB_MS="-U ${DBUSER} -h $(aws::rds::hostname production) ${DATABASE_NAME}"
    db=$HB_DB_MS
  elif [[ $1 == "replica1" || $1 == "r1" ]]; then
    export HB_DB_R1="-U ${DBUSER} -h $(aws::rds::hostname production-replica1) ${DATABASE_NAME}"
    dbtype=replica
    db=$HB_DB_R1
  elif [[ $1 == "replica2" || $1 == "r2" ]]; then
    export HB_DB_R2="-U ${DBUSER} -h $(aws::rds::hostname production-replica2) ${DATABASE_NAME}"
    dbtype=replica
    db=$HB_DB_R2
  elif [[ $1 == "replica3" || $1 == "r3" ]]; then
    export HB_DB_R3="-U ${DBUSER} -h $(aws::rds::hostname production-replica3) ${DATABASE_NAME}"
    dbtype=replica
    db=$HB_DB_R3
  else
    dbtype=
  fi
  printf "%s %s" "${dbtype}" "${db}"
}

lib::db::psql::args:: () {
  printf -- "-U ${AppPostgresUsername} -h ${AppPostgresHostname} $*"
}

lib::db::psql-args() {
  lib::db::psql::args::  "$@"
}

lib::db::psql::args::default() {
  printf -- "-U postgres -h localhost $*"
}

lib::db::psql::args::maint() {
  printf -- "-U postgres -h localhost --maintenance-db=postgres $*"
}

__lib::db::args_for() {
  declare -a results=( $(__lib::db::by_shortname $1) )
  if [[ ${#results[@]} -gt 1 ]]; then
    db=${results[@]:1}
    dbtype=${results[0]}
  fi
  printf "%s" "${db}"
}

__lib::db::psql() {
  local db=$1

  declare -a results=( $(__lib::db::by_shortname $1) )
  if [[ ${#results[@]} -gt 1 ]]; then
    db=${results[@]:1}
    dbtype=${results[0]}
  fi

  info "database: ${bldylw}${db}" >&2
  info "_db_type: ${bldylw}${dbtype}" >&2

  printf "psql ${db}"
}

__lib::db::wait_for_db() {
  local db=${1}
  inf 'waiting for the database to come up...'
  while true; do
    out=$(psql -c "select count(*) from accounts" $(lib::db::psql::args::  ${db}) 2>&1)
    code=$?
    [[ ${code} == 0 ]] && break # can connect and all is good
    [[ ${code} == 1 ]] && break # db is there, but no database/table is found
    sleep 1
    [[ ${out} =~ 'does not exist' ]] && break
  done
  ok:
  return 0
}

__lib::db::aliases() {
  alias hb.db.log='pgbadger --prefix "%t:%r:%u@%d:[%p]:" '
}

__lib::db::num_procs() {
  ps -ef | grep [p]ostgres | wc -l | awk '{print $1}'
}

__lib::db::datetime() {
  date '+%Y%m%d-%H%M%S'
}

__lib::db::backup-filename() {
  local dbname=${1:-"development"}
  local checksum=$(lib::db::rails::schema::checksum)
  if [[ -z ${checksum} ]]; then
    error "Can not calculate DB checksum based on Rails DB structure"
  else
    printf "${checksum}.$(lib::util::arch).${dbname}.dump"
  fi
}

__lib::db::is_valid() {
  local dbname="${1}"
  [[ -z ${dbname} ]] && return 1

  psql -U postgres -h localhost -c 'select count(*) from accounts' ${dbname} 1>/dev/null 2>/dev/null
  code=$?
  return ${code}
}

__lib::db::top::page() {
  local tof=$1; shift
  local dbtype=$1; shift
  local db="$*"

  printf "${bldcyn}[${dbtype}] ${bldpur}${db} ${clr}\n\n" >> ${tof}

  printf "${bldblu}" >> ${tof}
  if [[ "${dbtype}" == 'master' ]]; then
    psql -X -P pager ${db} -c "select * from hb_stat_replication" >> ${tof}
  else
    psql -X -P pager ${db} -c "select now() - pg_last_xact_replay_timestamp() AS REPLICATION_DELAY_SECONDS" >> ${tof}
  fi

  local query_width=$(( $(__lib::output::screen-width) - 78 ))

  printf "${bldcyn}[${dbtype}] ${bldpur}Above: Replication Status / Below: Active Queries:${clr}\n\n${bldylw}" >> ${tof}

  psql -X -P pager ${db} -c \
      "select pid, client_addr || ':' || client_port as Client, substring(state for 10) as State, now() - query_start as Duration, waiting as Wait, substring(query for ${query_width}) as Query from pg_stat_activity where state != 'idle' order by Duration desc" | \
      egrep -v 'select.*client_addr' 2>&1 >> ${tof}
}

#===============================================================================
# Public Functions
#===============================================================================

lib::db::rails::schema::file() {
  if [[ -f "${RAILS_SCHEMA_RB}" && -f "${RAILS_SCHEMA_SQL}" ]]; then
    if [[ "${RAILS_SCHEMA_RB}" -nt "${RAILS_SCHEMA_SQL}" ]]; then
      printf "${RAILS_SCHEMA_RB}"
    else
      printf "${RAILS_SCHEMA_SQL}"
    fi
  elif [[ -f "${RAILS_SCHEMA_RB}" ]]; then
    printf "${RAILS_SCHEMA_RB}"
  elif [[ -f "${RAILS_SCHEMA_SQL}" ]]; then
    printf "${RAILS_SCHEMA_SQL}"
  fi
}

lib::db::rails::schema::checksum() {
  if [[ -d db/migrate ]]; then
    find db/migrate -type f -ls | awk '{printf("%10d-%s\n",$7,$11)}' | sort | shasum | awk '{print $1}'
  else
    local schema=$(lib::db::rails::schema::file)
    [[ -s ${schema} ]] || error "can not find Rails schema in either ${RAILS_SCHEMA_RB} or ${RAILS_SCHEMA_SQL}"
    [[ -s ${schema} ]] && lib::util::checksum::files "${schema}"
  fi
}

lib::db::top() {
  local dbnames=$@

  h1 "Please wait while we resolve DB names using AWSCLI..."

  local db
  local dbtype
  local width_min=90
  local height_min=50
  local width=$(__lib::output::screen-width)
  local height=$(__lib::output::screen-height)

  if [[ ${width} -lt ${width_min} || ${height} -lt ${height_min} ]] ; then
    error "Your screen is too small for db.top."
    info "Minimum required screen dimensions are ${width_min} columns, ${height_min} rows."
    info "Your screen is ${bldred}${width}x${height}."
    return
  fi

  declare -A connections=()
  declare -a connection_names=()
  local i=0


  for dbname in $dbnames; do
    declare -a results=( $(__lib::db::by_shortname $dbname) )
    if [[ ${#results[@]} ]]; then
      dbtype="${results[0]}"
      i=$(( $i + 1 ))
      db="${results[@]:1}"
      if [[ -n ${dbtype} ]]; then
        [[ ${dbtype} == "master" ]] && dbname="master"
        [[ ${dbtype} == "replica" ]] && dbname="replica-${dbname}"
        connections[${dbname}]="${db}"
        connection_names[$i]=${dbname}
      fi
    fi
  done

  if [[ ${#connections[@]} == 0 ]] ; then
    error "usage: $0 db1, db2, ... "
    info  "eg: lib::db::top m r2 "
    (( $_s_ )) && return 1 || exit 1
  fi

  trap "clear" TERM
  trap "clear" EXIT

  local clear=0
  local interval=${DB_TOP_REFRESH_RATE:-0.5}
  local num_dbs=${#connection_names[@]}

  local tof="$(mktemp -d "${TMPDIR:-/tmp/}.XXXXXXXXXXXX")/.db.top.$$"
  cp /dev/null ${tof}

  while true; do
    local index=0
    cursor.at.y 0
    local screen_height=$(screen.height)

    for __dbtype in "${connection_names[@]}"; do
      index=$(( ${index} + 1 ))

      local percent_total_height=0

      if [[ ${num_dbs} -eq 2 ]]; then
        [[ ${index} -eq 2 ]] && percent_total_height=66

      elif [[ ${num_dbs} -eq 3 ]]; then
        [[ ${index} -eq 2 ]] && percent_total_height=50
        [[ ${index} -eq 3 ]] && percent_total_height=80

      elif [[ ${num_dbs} -eq 4 ]]; then
        [[ ${index} -eq 2 ]] && percent_total_height=40
        [[ ${index} -eq 3 ]] && percent_total_height=60
        [[ ${index} -eq 4 ]] && percent_total_height=80
      fi
      
      local vertical_shift=$(( ${percent_total_height} * ${screen_height} / 100 ))

      cursor.at.y ${vertical_shift} >> ${tof}
      [[ -n ${DEBUG} ]] && h::blue "screen_height = ${screen_height} | percent_total_height = ${percent_total_height} | vertical_shift = ${vertical_shift}" >> ${tof}
      hr::colored ${bldpur} >> ${tof}
      __lib::db::top::page "${tof}" "${__dbtype}" "${connections[${__dbtype}]}"
    done
    clear
    h::yellow " «   DB-TOP V0.1.2 © 2018 Konstantin Gredeskoul Inc. » "
    cat ${tof}
    cursor.at.y $(( $(__lib::output::screen-height) + 1 ))
    printf "${bldwht}Press Ctrl-C to quit.${clr}"
    cp /dev/null ${tof}
    sleep ${interval}
  done
}

lib::db::dump() {
  local dbname=${1}; shift
  local psql_args="$*"

  [[ -z "${psql_args}" ]] && psql_args="-U postgres -h localhost"
  local filename=$(__lib::db::backup-filename ${dbname})
  [[ $? != 0 ]] && return

  [[ ${LibRun__Verbose} -eq ${True} ]] && {
    info "dumping from: ${bldylw}${dbname}"
    info "saving to...: ${bldylw}${filename}"
  }

  cmd="pg_dump -Fc -Z5 ${psql_args} -f ${filename} ${dbname}"
  run "${cmd}"

  code=${LibRun__LastExitCode}
  if [[ ${code} != 0 ]]; then
    not_ok:
    error "pg_dump exited with code ${code}"
    return ${code}
  else
    ok:
    return 0
  fi
}

lib::db::restore() {
  local dbname="$1"; shift
  local filename="$1"; [[ -n ${filename} ]] && shift

  [[ -z ${filename} ]] && filename=$(__lib::db::backup-filename ${dbname})

  [[ dbname =~ 'production' ]] && {
    error 'This script is not meant for production'; return 1; }

  [[ -s ${filename} ]] || {
    error "can't find valid backup file in ${bldylw}${filename}"; return 2; }

  psql_args=$(lib::db::psql::args::default)
  maint_args=$(lib::db::psql::args::maint)

  run "dropdb ${maint_args} ${dbname} 2>/dev/null; true"

  export LibRun__AbortOnError=${True}
  run "createdb ${maint_args} ${dbname} ${psql_args}"

  [[ ${LibRun__Verbose} -eq ${True} ]] && {
    info "restoring from..: ${bldylw}${filename}"
    info "restoring to....: ${bldylw}${dbname}"
  }

  run "pg_restore -Fc -j 8 ${psql_args} -d ${dbname} ${filename}"
  code=${LibRun__LastExitCode}

  if [[ ${code} != 0 ]]; then
    warning "pg_restore completed with exit code ${code}"
    return ${code}
  fi
  return ${LibRun__LastExitCode}
}

hb.db.dump() {
  lib::db::dump "$@"
}

hb.db.restore() {
  lib::db::restore "$@"
}

hb.db() {
  bash -c "$(__lib::db::psql $@)"
}

hb.db.top() {
  lib::db::top "$@"
}
