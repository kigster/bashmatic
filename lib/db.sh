#!/usr/bin/env bash
#===============================================================================
# Private Functions
#===============================================================================

export bashmatic_db_config=${bashmatic_db_config:-"${HOME}/.db/database.yml"}
declare -a bashmatic_db_connection

unset bashmatic_db_username
unset bashmatic_db_password
unset bashmatic_db_host
unset bashmatic_db_database

# @description Print out PostgreSQL settings for a connection specified by args
#
# @example
#    db.psql.db-settings -h localhost -U postgres appdb
#
# @requires
#    Local psql CLI client
db.psql.db-settings() {
  psql "$*" -X -q -c 'show all' | sort | awk '{ printf("%s=%s\n", $1, $3) }' | sed -E 's/[()\-]//g;/name=setting/d;/^[-+=]*$/d;/^[0-9]*=$/d'
}

db.config.init() {
  export bashmatic_db_connection=(host database username password)
}

# @description Returns a space-separated values of db host, db name, username and password
#
# @example
#    db.config.set-file ~/.db/database.yml
#    db.config.parse development
#    #=> hostname dbname dbuser dbpass
#    declare -a params=($(db.config.parse development))
#    echo ${params[0]} # host
#
# @requires
#    Local psql CLI client
db.config.parse() {
  local db="$1"
  [[ -z ${db} ]] && return 1
  [[ -f ${bashmatic_db_config} ]] || return 2
  db.config.init
  local -a script=("require 'yaml'; h = YAML.load(STDIN); ")
  for field in "${bashmatic_db_connection[@]}"; do
    script+=("h.key?('${db}') && h['${db}'].key?('${field}') ? print(h['${db}']['${field}']) : print('null'); print ' '; ")
  done
  cat "${bashmatic_db_config}" | ruby -e "${script[*]}"
}

db.config.set-file() {
  [[ -s "$1" ]] || return 1

  export bashmatic_db_config="$1"
}

db.config.get-file() {
  echo "${bashmatic_db_config}"
}

db.psql.args.config() {
  local -a params
  params=($(db.config.parse "$1"))

  local dbhost
  local dbname
  local dbuser
  local dbpass

  dbhost=${params[0]}
  dbname=${params[1]}
  dbuser=${params[2]}
  dbpass=${params[3]}

  export PGPASSWORD="${dbpass}"
  printf -- "-U ${dbuser} -h ${dbhost} ${dbname}"
}

db.psql.args() {
  if [[ -z "${bashmatic_db_database}" || -z "${bashmatic_db_host}" ]]; then
    if [[ -n "$1" ]]; then
      db.psql.args.config "$1"
    else
      error "Unable to determine DB connection parameters"
      return 1
    fi
  else
    export PGPASSWORD="${bashmatic_db_password}"
    printf -- "-U ${bashmatic_db_username} -h ${bashmatic_db_host} ${bashmatic_db_database}"
  fi
}

db.psql.args.localhost() {
  printf -- "-U postgres -h localhost $*"
}

db.psql.args.maintenance() {
  db.psql.args.localhost "--maintenance-db=postgres $*"
}

db.wait-until-db-online() {
  local db="${1}"
  inf 'waiting for the database to come up...'
  while true; do
    out=$(psql -c "select count(*) from pg_stat_user_tables" "$(db.psql.args "${db}")" 2>&1)
    code=$?
    [[ ${code} == 0 ]] && break # can connect and all is good
    [[ ${code} == 1 ]] && break # db is there, but no database/table is found
    sleep 1
    [[ ${out} =~ 'does not exist' ]] && break
  done
  ui.closer.ok:
  return 0
}

db.pg.local.num-procs() {
  /bin/ps -ef | /bin/grep "[p]ostgres" | wc -l | awk '{print $1}'
}

db.datetime() {
  date '+%Y%m%d-%H%M%S'
}

.db.backup-filename() {
  local dbname=${1:-"development"}
  local checksum=$(db.rails.schema.checksum)
  if [[ -z ${checksum} ]]; then
    error "Can not calculate DB checksum based on Rails DB structure"
  else
    printf "${checksum}.$(util.arch).${dbname}.dump"
  fi
}

# db.dump() {
#   local dbname=${1}
#   shift
#   local psql_args="$*"

#   [[ -z "${psql_args}" ]] && psql_args="-U postgres -h localhost"
#   local filename=$(.db.backup-filename ${dbname})
#   [[ $? != 0 ]] && return

#   [[ ${LibRun__Verbose} -eq ${True} ]] && {
#     info "dumping from: ${bldylw}${dbname}"
#     info "saving to...: ${bldylw}${filename}"
#   }

#   cmd="pg_dump -Fc -Z5 ${psql_args} -f ${filename} ${dbname}"
#   run "${cmd}"

#   code=${LibRun__LastExitCode}
#   if [[ ${code} != 0 ]]; then
#     ui.closer.not-ok:
#     error "pg_dump exited with code ${code}"
#     return ${code}
#   else
#     ui.closer.ok:
#     return 0
#   fi
# }

# db.restore() {
#   local dbname="$1"
#   shift
#   local filename="$1"
#   [[ -n ${filename} ]] && shift

#   [[ -z ${filename} ]] && filename=$(.db.backup-filename ${dbname})

#   [[ dbname =~ 'production' ]] && {
#     error 'This script is not meant for production'
#     return 1
#   }

#   [[ -s ${filename} ]] || {
#     error "can't find valid backup file in ${bldylw}${filename}"
#     return 2
#   }

#   psql_args=$(db.psql.args.default)
#   maint_args=$(db.psql.args.maint)

#   run "dropdb ${maint_args} ${dbname} 2>/dev/null; true"

#   export LibRun__AbortOnError=${True}
#   run "createdb ${maint_args} ${dbname} ${psql_args}"

#   [[ ${LibRun__Verbose} -eq ${True} ]] && {
#     info "restoring from..: ${bldylw}${filename}"
#     info "restoring to....: ${bldylw}${dbname}"
#   }

#   run "pg_restore -Fc -j 8 ${psql_args} -d ${dbname} ${filename}"
#   code=${LibRun__LastExitCode}

#   if [[ ${code} != 0 ]]; then
#     warning "pg_restore completed with exit code ${code}"
#     return ${code}
#   fi
#   return ${LibRun__LastExitCode}
# }
