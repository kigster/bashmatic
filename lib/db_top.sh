#!/usr/bin/env bash
# vim: ft=bash
#===============================================================================
# DB Top Library Functions
#===============================================================================

export bashmatic_db_top_refresh=${bashmatic_db_top_refresh:-0.5}

.db.top.psql.replication() {
  local dbname="$1"
  shift
  local toc="$1"
  shift

  if [[ "${dbname}" =~ "master" ]]; then
    psql -X -P pager "$@" -c "select * from hb_stat_replication" >>"${toc}"
  elif [[ "${dbname}" =~ "replica" || "${dbname}" =~ "slave" ]]; then
    psql -X -P pager "$@" -c "select now() - pg_last_xact_replay_timestamp() AS REPLICATION_DELAY_SECONDS" >>"${toc}"
  else
    return
  fi

  printf "${bldcyn}[${dbname}] ${bldpur}Above: Replication Status${clr}\n\n${bldylw}" >>"${toc}"
}

.db.top.psql.active() {
  local dbname="$1"
  shift
  local tof="$1"
  shift
  local height="$1"
  shift
  local query_width
  local sw=$(screen-width)
  query_width=$((sw - 72))
  sed -e "/^--.*$/d; s/QUERY_WIDTH/${query_width}/g;s/LIMIT/${height}/g" "${BASHMATIC_HOME}/.db.active.sql" | tr '\n' ' ' >"${tof}.query"
}

.db.top.connection() {
  local tof="$1"
  shift
  local dbname="$1"
  shift
  local dbpass="$1"
  shift
  local height="$1"
  shift

  local displayname=$(printf "  %-15.15s" "$dbname")
  rm -f "${tof}.errors" >/dev/null

  printf "${bldwht}${bakblu} Database: ${txtblu}${bakpur}${bldwht}${bakpur}${bldylw}${displayname} ${txtpur}${bakylw}${clr}${txtblk}${bakylw} Active Queries (refresh: ${bashmatic_db_top_refresh}secs, Max Queries Shown: ${height}): ${clr}${txtylw}${clr}\n\n${clr}" >>"${tof}"

  export PGPASSWORD="${dbpass}"

  .db.top.psql.active "${dbname}" "${tof}" "${height}" "$@"
  .db.top.psql.replication "${dbname}" "${tof}" "$@"

  local query="${tof}.query"
  (eval "$(echo psql -X -P pager -f "${query}" "$@")") >"${tof}.out"
  local code=$?

  # grep --color=never -E -v 'EEEselect.*client_addr'
  export GREP_COLOR=35
  grep -C 1000 -i --color=always -E -e ' (((auto)?(analyze|vacuum))|delete|update|insert|create (table|index)|alter (table|index)?)' "${tof}.out" |
    egrep -v -- '^(--|.*select pid, client_addr)' >>"${tof}"

  [[ ${code} -ne 0 ]] && {
    error "psql exited with code ${code}" >>"${tof}.errors"
    return ${code}
  }
}

db.top.set-refresh() {
  export bashmatic_db_top_refresh="$1"
}

.db.top.vertical-offset() {
  local num_dbs="$1"
  local index="$2"
  local offset

  if [[ ${num_dbs} -eq 1 ]]; then
    [[ ${index} -eq 0 ]] && offset=5
    [[ ${index} -eq 1 ]] && offset=100

  elif [[ ${num_dbs} -eq 2 ]]; then
    [[ ${index} -eq 0 ]] && offset=4
    [[ ${index} -eq 1 ]] && offset=66
    [[ ${index} -eq 2 ]] && offset=100

  elif [[ ${num_dbs} -eq 3 ]]; then
    [[ ${index} -eq 0 ]] && offset=4
    [[ ${index} -eq 1 ]] && offset=45
    [[ ${index} -eq 2 ]] && offset=75
    [[ ${index} -eq 3 ]] && offset=100
  fi

  printf "%d" ${offset}
}

db.top() {
  local dbname
  local width_min=90
  local height_min=30
  local width=$(screen.width)
  local height=$(screen.height)

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
      local percent_total_height
      local percent_total_height_next
      percent_total_height=$(.db.top.vertical-offset "${num_dbs}" ${index})
      percent_total_height_next=$(.db.top.vertical-offset "${num_dbs}" $((index + 1)))

      local vertical_shift=$((percent_total_height * screen_height / 100))
      local vertical_shift_next=$((percent_total_height_next * screen_height / 100))
      local height=$((vertical_shift_next - vertical_shift - 7))

      cursor.at.y ${vertical_shift} >>"${tof}"
      [[ -n ${DEBUG} ]] && {
        .output.set-indent 0
        info "CURRENT ❯${bldylw} % = ${percent_total_height}, %++ = ${percent_total_height_next}" >>"${tof}"
        h1 -- "Database: ${dbname}" \
          "PSQL arguments:" \
          "${connections_arguments[${index}]}" >>"${tof}"
      }
      .db.top.connection "${tof}" "${dbname}" "${connections_passwords[${index}]}" "${height}" "${connections_arguments[${index}]}"
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
