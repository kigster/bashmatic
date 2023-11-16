#!/usr/bin/env bash

# Private Functions
#===============================================================================

function is-verbose() {
  ((flag_verbose))
}

function is-quiet() {
  ((flag_quiet))
}

export bashmatic_db_config=${bashmatic_db_config:-"${HOME}/.db/database.yml"}
declare -a bashmatic_db_connection

unset bashmatic_db_username
unset bashmatic_db_password
unset bashmatic_db_host
unset bashmatic_db_database

db.psql.args-data-only() {
  printf -- "%s" "-t --no-align --pset footer -q -X --tuples-only"
}

db.config.init() {
  export bashmatic_db_connection=(host database username password)
}

db.config.init-max-query-len() {
  local w=$(screen.width.actual)
  local max_query_len

  max_query_len=$(( w - 20 ))
  max_query_len=$(array.force-range "${max_query_len}" 80 1000)

  ((flag_verbose)) && { attention "Queries will be truncated to ${max_query_len} characters" >&2; }

  printf "%d" "${max_query_len}"  # characters
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
  is.a-function ruby.handle-missing || source "${BASHMATIC_LIB}/ruby.sh"
  ruby.handle-missing
  ruby -e "${script[*]}"<"${bashmatic_db_config}"
}

db.config.connections-list() {
  [[ -f ${bashmatic_db_config} ]] || return 2
  ruby.handle-missing
  gem.install colorize >/dev/null
  __yaml_source="${bashmatic_db_config}" ruby <<RUBY
  require 'yaml'
  require 'colorize'
  h = YAML.load(File.read(ENV['__yaml_source']), aliases: true)
  h.each_pair do |name, params|
    printf "%50s → %s@%s/%s\n",
      name.yellow,
      params['username'].blue,
      params['host'].green,
      params['database'].cyan
  end
RUBY
}

db.config.connections() {
  ascii-clean "$(db.config.connections-list | awk '{print $1}')"
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

db.psql.report-error() {
  local -a argv=("$@")

  [[ -z "${__psql_stderr}" ]] && return 0
  [[ -s "${__psql_stderr}" ]] || return 0

  error "Error running command: ""${bldylw}psql ${argv[*]}"
  # shellcheck disable=SC2002
  printf -- "${txtred}$(cat "${__psql_stderr}" | sed -E 's/^/   /g')${clr}\n"
  hr
  rm -f "${__psql_stderr}"
  unset __psql_stderr
}

print-cli() {
  is-verbose || return
  notice "Running command line:"
  cursor.up 2
  notice "${itablk}$*"
}

# @description Connect to one of the databases named in the YAML file, and
#              optionally pass additional arguments to psql.
#              Informational messages are sent to STDERR.
#
# @example
#    db.psql.connect production
#    db.psql.connect production -c 'show all'
#
db.psql.connect() {
  local dbname="$1"; shift

  if [[ -z ${dbname} ]]; then
    h1 "USAGE: db.connect connection-name" \
      "WHERE: connection-name is defined by your ${bldylw}${bashmatic_db_config}${clr} file." >&2
    return 0
  fi

  export __psql_stderr="$(file.temp)"
  cp /dev/null "${__psql_stderr}"

  local tempfile=$(mktemp)
  db.psql.args.config "${dbname}" >"${tempfile}"

  local -a args=($(cat "${tempfile}"))
  [[ -n "${psql_extra_args[*]}" ]] && args+=("${psql_extra_args[@]}")

  rm -f "${tempfile}" >/dev/null

  [[ ${flag_quiet} -eq 0 ]] && {
    printf "${txtpur}export PGPASSWORD=[reducted]${clr}\n" >&2
    printf "${txtylw}$(which psql) ${args[*]}${clr}\n" >&2
    (hr; echo) >&2
  }

  set +e
  is-verbose && echo
  if [[ ${action} == "run" ]]; then
    print-cli "psql ${args[*]} --echo-errors $*"
    # print-cli psql --echo-errors "${args[@]}" "$@"
    psql "${args[@]}" --echo-errors "$@" 2>"${__psql_stderr}"
    local code=$?
    [[ ${code} -ne 0 || -s "${__psql_stderr}" ]] && db.psql.report-error "${args[@]}" "$@"
  else
    print-cli "psql ${args[*]} --echo-errors $*"
    eval "psql ${args[*]} --echo-errors $*"
    local code=$?
  fi

  return ${code}
}

# @description Similar to the db.psql.connect, but outputs
#              just the raw data with no headers.a
#
# @example
#    db.psql.connect.just-data production -c 'select datname from pg_database;'
db.psql.connect.just-data() {
  local dbname="$1"; shift
  # shellcheck disable=SC2046
  db.psql.connect "${dbname}" $(db.psql.args-data-only) "$@"
}

db.psql.explain() {
  local dbname="$1"; shift
  db.psql.connect "${dbname}" -t -A -X --pset border=0 -c "'explain $*'"
}

db.psql.run() {
  local dbname="$1"; shift
  local query="$1"; shift
  db.psql.connect.just-data "${dbname}" -c "${query}" "@"
}

db.psql.run-multiple() {
  local dbname="$1"; shift
  local commands
  for arg in "$@"; do
    if [[ ${arg} =~ \" ]]; then
      commands="${commands} -c '$(printf "%s" "${arg}")'"
    else
      commands="${commands} -c \"$(printf "%s" "${arg}")\""
    fi
  done
  echo "${commands}">/tmp/a
  db.psql.connect "${dbname}" -t -A -X --pset border=0 "${commands}"
}

db.psql.list-users() {
  local dbname="$1"; shift
  db.psql.connect "${dbname}" $(db.psql.args-data-only) -c '\\du' | awk 'BEGIN{FS="|"}{print $2}'
}

db.psql.list-tables() {
  local dbname="$1"; shift
  db.psql.connect "${dbname}" $(db.psql.args-data-only) -c '\\dt' | awk 'BEGIN{FS="|"}{print $2}'
}

db.psql.list-indexes() {
  local dbname="$1"; shift
  db.psql.connect "${dbname}" $(db.psql.args-data-only) -c '\\di' | awk 'BEGIN{FS="|"}{print $2}'
}

db.psql.connect.table-settings-show() {
  local dbname="$1"; shift
  local table="$1"; shift
  db.psql.connect "${dbname}" $(db.psql.args-data-only) \
    -c "SELECT relname, reloptions FROM pg_class WHERE relname='${table}';"
}

# @description
#   Set per-table settings, such as autovacuum, eg:
# @example
#   db.psql.connect.table-settings-set prod users autovacuum_analyze_threshold 1000000
#   db.psql.connect.table-settings-set prod users autovacuum_analyze_scale_factor 0
db.psql.connect.table-settings-set() {
  local dbname="$1"; shift
  local table="$1"; shift
  local setting="$1"; shift
  local value="$1"; shift

  [[ -z ${setting} || -z ${value} ]] && {
    error "Either setting or value are not defined.">&2
    return 1
  }

  info "Setting ${setting} = ${value} on table ${table}...."
  db.psql.connect "${dbname}" $(db.psql.args-data-only) \
    -c "ALTER TABLE \"${table}\" SET (${setting} = ${value});"
}

# @description Print out PostgreSQL settings for a connection specified by args
#
# @example
#    db.psql.db-settings -h localhost -U postgres appdb
#
# @requires
#    Local psql CLI client
db.psql.db-settings() {
  psql "$*" -X -q -c "\"show all\"" | sort | awk '{ printf("%s=%s\n", $1, $3) }' | sed -E 's/[()\-]//g;/name=setting/d;/^[-+=]*$/d;/^[0-9]*=$/d'
}

# @description Print out PostgreSQL settings for a named connection
# @arg1 dbname database entry name in ~/.db/database.yml
# @example
#    db.psql.connect.db-settings-pretty primary
#
db.psql.connect.db-settings-pretty() {
  db.psql.connect "$@" -A -X -q -c "\"show all\"" | \
    grep -v 'rows)' | \
    sort | \
    awk "BEGIN{FS=\"|\"}{ printf(\"%-40.40s %-30.30s ## %s\n\", \$1, \$2, \$3) }" | \
    sedx '/##\s*$/d' | \
    GREP_COLOR="1;32" grep -E -C 1000 -i --color=always -e '^([^ ]*)' | \
    GREP_COLOR="3;0;34" grep -E -C 1000 -i --color=always -e '##.*$|$'
}

# @description Print out PostgreSQL settings for a named connection using TOML/ini
#              format.
#
# @arg1 dbname database entry name in ~/.db/database.yml
# @example
#    db.psql.connect.db-settings-toml primary > primary.ini
#
db.psql.connect.db-settings-toml() {
  db.psql.connect.just-data "$1" -c "\"show all\"" | awk 'BEGIN{FS="|"}{printf "%s=%s\n", $1, $2}' | sort
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

db.psql.version() {
  command -v psql >/dev/null || return 1
  psql --version | sed -E 's/[^0-9.]//g'
}

db.postgres.version() {
  command -v postgres >/dev/null || return 1
  postgres --version | sed -E 's/[^0-9.]//g'
}

db.psql.args.localhost() {
  printf -- "-U postgres -h localhost $*"
}

db.psql.args.maintenance() {
  db.psql.args.localhost "--maintenance-db=postgres $*"
}

.db.locks.generate-sql() {
  local table="$1"
  local temp_sql="$(file.temp sql)"
  local max_query_len=$(db.config.init-max-query-len)

  cat <<SQL > "${temp_sql}"
SELECT
    a.pid,
    a.state,
    a.usename,
    a.client_addr,
    a.wait_event_type,
    a.wait_event,
    state,
    t.relname as table_name,
    to_char(now()::time - a.query_start::time, 'HH24:MI:SS') AS duration,
    substring(regexp_replace(substring(a.query, 0, 2000), E'[\n\r]+', '\n', 'g'), 0, ${max_query_len:-1000}) AS sql
FROM
    pg_stat_activity a,
    pg_locks l,
    pg_class t
WHERE
    l.relation = t.oid
    AND t.relkind = 'r'
    AND t.relname ILIKE '%${table}%'
    AND a.pid = l.pid
    AND state != 'idle'
    AND (wait_event IS NOT NULL
        OR wait_event_type IS NOT NULL)
ORDER BY
    duration DESC;
SQL

  printf "%s" "${temp_sql}"
}

db.psql.table-locks() {
  local db="$1"; shift
  local table="$1"; shift
  local file="$(.db.locks.generate-sql "${table}")"

  db.psql.connect "${db}" "$*" -X -x --pset=pager -q -f "${file}" | GREP_COLOR=41 grep --color=always -E "(${table:-"table_name.*$"}|$)"

  [[ -f "${file}" ]] && rm -f "${file}"
}

db.psql.table-locks-query() {
  local db="$1"; shift
  local table="$1"; shift
  local file="$(.db.locks.generate-sql "${table}")"
  printf "\n${txtgrn}"
  cat "${file}"
  printf "\n${clr}"
  [[ -f "${file}" ]] && rm -f "${file}"
}

#—————————————————————————————————————————————————— END OF PSQL FUNCTIONS —————————————————————————————————————————————————————————
#
#—————————————————————————————————————————————————— START DB ACTIONS ——————————————————————————————————————————————————————————————

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

db.actions.table-locks() {
  db.psql.table-locks "$@"
}

db.actions.table-locks-query() {
  db.psql.table-locks-query "$@"
}

db.actions.top() {
  db.top "$@"
}

db.actions.connect() {
  db.psql.connect "$@"
}

db.actions.run() {
  db.psql.run "$@"
}

db.actions.set-max-query-len() {
  db.config.set-max-query-len "$@"
}
# @description
#    Executes multiple commands by passing them to psql each with -c flag. This
#    allows, for instance, setting session values, and running commands such as VACUUM which
#    can not run within an implicit transaction started when joining multiple statements with ";"
#
# @example
#    $ db -q run my_database 'set default_statistics_target to 10; show default_statistics_target; vacuum users'
#    ERROR:  VACUUM cannot run inside a transaction block
#
#    $ db -q run-multiple my_database 'set default_statistics_target to 10' 'show default_statistics_target' 'vacuum users' SET
#    10
#    VACUUM
db.actions.run-multiple() {
  db.psql.run-multiple "$@"
}

db.actions.csv() {
  local dbname=${1};  shift
  [[ -z ${dbname} ]] && return 1
  export flag_quiet=1
  db.psql.connect "${dbname}" -P border=0 -P fieldsep="," --csv -A -X -P pager=off -P footer=off -c "\"$*\""
}

export _bashmatic_db_explain_sql="EXPLAIN (ANALYZE, COSTS, VERBOSE, BUFFERS, FORMAT JSON)"
export _bashmatic_db_analyze_sql="EXPLAIN (COSTS, VERBOSE, BUFFERS, FORMAT JSON)"
export _bashmatic_db_explain=

.db.actions.explain-json() {
  local flags
  local dbname="$1"; shift
  local query="$1"; shift
  local explain_sql="${__bashmatic_db_explain}"
  local explain_json

  if [[ -f "${query}" ]]; then
    local explain="query.explain"
    local explain_json="${query}.explain.json"
    echo "${explain_sql}" > "${explain}"
    cat "${query}" >> "${explain}"
    flags="-f ${explain} -o ${explain_json}"
  else
    query="${query//\"/\\\"}"
    explain_json="$(echo "${query}" | shasum | cut -d' ' -f 1).json"
    flags="-c \"${explain_sql} ${query}\" -o ${explain_json}"
  fi

  db.psql.connect "${dbname}" "-AXt -P pager=off ${flags}"
}

db.actions.explain() {
  db.psql.explain "$@"
}

db.actions.explain-json() {
  export _bashmatic_db_explain="${_bashmatic_db_analyze_sql}"
  .db.actions.explain "$@"
}

db.actions.explain-analyze-json() {
  export _bashmatic_db_explain="${_bashmatic_db_explain_sql}"
  .db.actions.explain "$@"
}

db.actions.data-dir() {
  db.psql.connect "$@" $(db.psql.args-data-only) -c "'show data_directory'" #| $(command -v grep) -E -v 'data_directory|row'
}

# @description Installs (if needed) pg_activity and starts it up against the connection
db.actions.pga() {
  local name="$1"
  command -v python3 >/dev/null    || brew.install.packages python3
  command -v pg_activity>/dev/null || run "python3 -m pip install pg_activity psycopg2-binary"
  command -v pg_activity>/dev/null || {
    local binary=$(find /usr/local/Cellar -type f -name 'pg_activity')
    run "ln -nfs ${binary} /usr/local/bin/pg_activity"
  }
  command -v pg_activity>/dev/null || {
    error "Can't find pg_activity even after install + symlink".
    return 1
  }

  local args=$(db.psql.args.config "${name}")
  db.psql.args.config "${name}">/dev/null

  pg_activity "${args}" --verbose-mode=1 --rds --no-app --no-database --no-user
}

db.actions.list-tables() {
  local dbname="$1"; shift
  db.psql.connect -q "${dbname}" $(db.psql.args-data-only) -c 'select relname from pg_stat_user_tables order by relname asc' "$@"
}

db.actions.table-settings-show() {
  db.psql.connect.table-settings-show "$@"
}

db.actions.table-settings-set() {
  db.psql.connect.table-settings-set "$@"
}

db.actions.connections() {
  db.config.connections
  echo
}

db.actions.list-users() {
  db.psql.list-users "$@"
}

db.actions.list-tables() {
  db.psql.list-tables "$@"
}

db.actions.list-indexes() {
  db.psql.list-indexes "$@"
}

db.actions.db-settings-pretty() {
  db.psql.connect.db-settings-pretty "$@"
}

db.actions.db-settings-toml() {
  db.psql.connect.db-settings-toml "$@"
}


