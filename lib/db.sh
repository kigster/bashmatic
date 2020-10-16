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
  ruby -e "${script[*]}"<"${bashmatic_db_config}"
}

db.config.connections() {
  [[ -f ${bashmatic_db_config} ]] || return 2
  ruby -e "require 'yaml'; h = YAML.load(STDIN); puts h.keys.join(\"\n\")" <"${bashmatic_db_config}"
}

db.config.set-file() {
  [[ -s "$1" ]] || return 1
  export bashmatic_db_config="$1"
}

db.config.get-file() {
  echo "${bashmatic_db_config}"
}

db.psql.args.config() {
  local output="$(db.config.parse "$1")"
  local -a params

  [[ -z ${output} || "${output}" =~ "null" ]] && {
    section.red 65 "Unknown database connection — ${bldylw}$1." >&2
    info "The following are connections defined in ${bldylw}${bashmatic_db_config/${HOME}/\~}:\n" >&2
    for c in $(db.config.connections); do info " • ${c}" >&2; done
    echo >&2
    exit 1
  }

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
  printf -- "-U ${dbuser} -h ${dbhost} -d ${dbname}"
}

db.psql.connect() {
  local dbname="$1"; shift
  if [[ -z ${dbname} ]]; then
    h1 "USAGE: db.connect connection-name" \
      "WHERE: connection-name is defined by your ${bldylw}${bashmatic_db_config}${clr} file."
    return 0
  fi
  local tempfile=$(mktemp /tmp/.bashmatic.db.${RANDOM} || exit 1)
  db.psql.args.config "${dbname}" >"${tempfile}"
  local -a args=($(cat "${tempfile}"))
  rm -f "${tempfile}" >/dev/null
  printf "${txtpur}export PGPASSWORD=[reducted]${clr}\n"
  printf "${txtylw}$(which psql) ${args[*]}${clr}\n"
  hr
  psql "${args[@]}" "$@"
}

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

# @description Print out PostgreSQL settings for a named connection
# @arg1 dbname database entry name in ~/.db/database.yml
# @example
#    db.psql.connect.settings primary
db.psql.connect.settings() {
  db.psql.connect "$@" -A -X -q -c 'show all' | \
    grep -v 'rows)' | \
    sort | \
    awk "BEGIN{FS=\"|\"}{ printf(\"%-40.40s %-40.40s         ## %s\n\", \$1, \$2, \$3) }" | \
    sedx '/##\s*$/d' | \
    GREP_COLOR="1;32" grep -E -C 1000 -i --color=always -e '^([^ ]*)' | \
    GREP_COLOR="3;1;30" grep -E -C 1000 -i --color=always -e '##.*$|$'
}

# @description Print out PostgreSQL settings for a named connection
# @arg1 dbname database entry name in ~/.db/database.yml
# @example
#    db.psql.connect.raw-settings primary
db.psql.connect.raw-settings() {
  db.psql.connect "$@" -A -X -q -c 'show all' | \
    grep -v 'rows)' | \
    sort | \
    awk "BEGIN{FS=\"|\"}{ printf(\"%s=%s\\n\", \$1, \$2) }"
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

db.actions.top() {
  db.top "$@" 
}

db.actions.connect() {
  db.psql.connect "$@"
}

db.actions.connections() {
  db.config.connections
}

db.actions.settings-table() {
  db.psql.connect.settings "$@"
}

db.actions.settings-raw() {
  db.psql.connect.raw-settings "$@"
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
