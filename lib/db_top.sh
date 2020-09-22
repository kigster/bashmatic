#!/usr/bin/env bash
# vim: ft=bash
#===============================================================================
# DB Top Library Functions
#===============================================================================

export bashmatic_db_top_refresh=${bashmatic_db_top_refresh:-0.5}
export bashmatic_db_top_highlighted_keywords=${bashmatic_db_top_highlighted_keywords:-' (((auto)?(analyze|vacuum))|alter ?(table|index)?|create ?(table|index)?|delete|update|insert)'}

# If the database passed as an argument happens to be named "master*" or
# "(slave|replica)" then run psql and show replication stats.
.db.top.psql.replication() {
  local dbname="$1"
  shift
  local to_file="$1"
  shift

  if [[ "${dbname}" =~ "master" ]]; then
    psql -X -P pager "$@" -c "select * from hb_stat_replication" >>"${to_file}"
  elif [[ "${dbname}" =~ "replica" || "${dbname}" =~ "slave" ]]; then
    psql -X -P pager "$@" -c "select now() - pg_last_xact_replay_timestamp() AS REPLICATION_DELAY_SECONDS" >>"${to_file}"
  else
    return
  fi

  printf "${bldcyn}[${dbname}] ${bldpur}Above: Replication Status${clr}\n\n${bldylw}" >>"${to_file}"
}

# Based oni the DB, renders the given query file
# while substituting several templated keywords like QUERY_WIDTH
.db.top.psql.render-query() {
  local dbname="$1"
  shift
  local tof="$1"
  shift
  local query_width
  local sw=$(screen-width)
  query_width=$((sw - 68))
  sed -e "/^--.*$/d; s/QUERY_WIDTH/${query_width}/g;" "${BASHMATIC_HOME}/.db.active.sql" | tr '\n' ' ' >"${tof}.query"
}

# Given an output file $tof, a database name $dbname with $dbpass,
# evaluate a templated query, while substituting the screen width
# (which depensd on the TTY)
.db.top.connection() {
  local tof="$1"
  shift
  local dbname="$1"
  shift
  local dbpass="$1"
  shift

  local displayname=$(printf "  %-15.15s" "$dbname")
  rm -f "${tof}.errors" >/dev/null

  printf "${bldwht}${bakblu} Database: ${txtblu}${bakpur}${bldwht}${bakpur}${bldylw}${displayname} ${txtpur}${bakylw}${clr}${txtblk}${bakylw} Active Queries (refresh: ${bashmatic_db_top_refresh}secs): ${clr}${txtylw}${clr}\n\n${clr}" >>"${tof}"

  export PGPASSWORD="${dbpass}"

  .db.top.psql.render-query "${dbname}" "${tof}" "$@"
  .db.top.psql.replication "${dbname}" "${tof}" "$@"

  local query="${tof}.query"
  # Run the query
  # Note, eval ensures access to PGPASSWORD variable
  (eval "$(echo psql -X -P pager -f "${query}" "$@")") >"${tof}.out"
  local code=$?

  # Before we exit, let's colorize the SQL output, and highlight some of the
  # important keywords.
  export GREP_COLOR=35
  grep -C 1000 -i --color=always -E -e "${tof}.out" |
    grep -v 'select pid, client_addr' >>"${tof}"

  [[ ${code} -ne 0 ]] && {
    error "psql exited with code ${code}" >>"${tof}.errors"
    return ${code}
  }
}

# Set how often to refresh, i.e. sleep between subsequent renders.
db.top.set-refresh() {
  export bashmatic_db_top_refresh="$1"
}

# Sets the regex used to highlight worsd in the activity queries.
db.top.set-highlighted-keywords() {
  export bashmatic_db_top_highlighted_keywords="$1"
}

db.top.usage() {
  local -a databases=($(db.config.databases))
  usage-box "dbtop database [ database [ database ] ] © Top-like display of the in-flight SQL queries for up to 3 Databases Concurrently" \
    " " " " \
    "${bldpur}Config FilePath:     " "${txtblk}${bakylw}${bashmatic_db_config}" \
    "${bldpur}Available Databases: " "${txtblk}${bakylw}${databases[*]}" \
    " " " " \
    "${bldblu}EXAMPLE: " "${bldylw}\$ ${bldgrn}dbtop ${databases[@]:0:2}"
  exit 0
}

db.top() {
  local dbname
  local width_min=90
  local height_min=50
  local width=$(screen.width)
  local height=$(screen.height)

  if [[ "$1" == '--help' || "$1" == '-h' || -z "$1" ]]; then
    db.top.usage
    return 1
  fi

  if [[ ${width} -lt ${width_min} || ${height} -lt ${height_min} ]]; then
    error "Your screen is too small for db.top."
    info "Minimum required screen dimensions are ${width_min} columns, ${height_min} rows."
    info "Your screen is ${bldred}${width}x${height}."
    return
  fi

  local -a connections_arguments
  local -a connections_names
  local -a connections_passwords

  local code=0
  local i=0
  local arguments
  local tof="$(mktemp -d "${TMPDIR:-/tmp/}.XXXXXXXXXXXX")/.db.top.$$"

  cp /dev/null "${tof}" >/dev/null

  for connection in "$@"; do
    db.psql.args.config "${connection}" 2>&1 >/dev/null || {
      return 1
    }

    db.psql.args "${connection}" >"${tof}"

    arguments="$(cat "${tof}" | tr -d '\n')"
    connections_arguments+=("${arguments}")
    connections_names+=("${connection}")
    connections_passwords+=("${PGPASSWORD}")
    i=$((i + 1))
  done

  if [[ ${#connections_names[@]} -eq 0 ]]; then
    h1 "${bldgrn}USAGE: db.top db1 db2 ... " "   EG: db.top prod-master prod-replica1 prod-replica2"
    return 1
  fi

  ((BASH_IN_SUBSHELL)) && {
    trap "clear" TERM
    trap "clear" EXIT
  }

  local interval=${bashmatic_db_top_refresh:-1}
  local num_dbs=${#connections_names[@]}
  h1 "Refreshing activity for ${num_dbs} databases..."
  while true; do
    local index=0
    rm -f "${tof}.errors"
    cp /dev/null "${tof}"

    local screen_height=$(screen.height)

    for dbname in "${connections_names[@]}"; do
      local percent_total_height=0

      if [[ ${num_dbs} -eq 1 ]]; then
        [[ ${index} -eq 0 ]] && percent_total_height=5

      elif [[ ${num_dbs} -eq 2 ]]; then
        [[ ${index} -eq 0 ]] && percent_total_height=4
        [[ ${index} -eq 1 ]] && percent_total_height=66

      elif [[ ${num_dbs} -eq 3 ]]; then
        [[ ${index} -eq 0 ]] && percent_total_height=4
        [[ ${index} -eq 1 ]] && percent_total_height=45
        [[ ${index} -eq 2 ]] && percent_total_height=75
      fi

      local vertical_shift=$((percent_total_height * screen_height / 100))

      cursor.at.y ${vertical_shift} >>"${tof}"
      [[ -n ${DEBUG} ]] && {
        .output.set-indent 0
        h1 -- "Database: ${dbname}" \
          "PSQL arguments:" \
          "${connections_arguments[${index}]}" >>"${tof}"
      }
      .db.top.connection "${tof}" "${dbname}" "${connections_passwords[${index}]}" "${connections_arguments[${index}]}"
      index=$((index + 1))
    done

    clear

    if [[ -s "${tof}.errors" ]]; then
      error "ERROR running psql with args: ${bldylw}${connections_arguments[${index}]}"
      printf "${bldred}"
      cat "${tof}.errors"
      printf "${clr}\n"
      h3 "Output:"
      cat "${tof}"
      code=111
      break
    else
      .output.set-indent 0
      hl.green "DbTop© v1.1.0 © 2016-2020 Konstantin Gredeskoul • © All Rights Reserved • MIT License —— "
      cat "${tof}"
      cursor.at.y $(($(.output.screen-height) + 1))
      printf "${bldwht}Press Ctrl-C to quit.${clr}"
      code=0
    fi
    sleep "${interval}"
  done
  return ${code}
}
