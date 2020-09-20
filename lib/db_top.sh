#!/usr/bin/env bash
# vim: ft=bash
#===============================================================================
# DB Top Library Functions
#===============================================================================

.db.top.replication() {
  local dbname="$1"
  shift
  local toc="$1"
  shift

  if [[ "${dbname}" =~ "master" ]]; then
    psql -X -P pager "$@" -c "select * from hb_stat_replication" >>"${toc}"
  elif [[ "${dbname}" == "replica" ]]; then
    psql -X -P pager "$@" -c "select now() - pg_last_xact_replay_timestamp() AS REPLICATION_DELAY_SECONDS" >>"${toc}"
  else
    return
  fi

  printf "${bldcyn}[${dbname}] ${bldpur}Above: Replication Status${clr}\n\n${bldylw}" >>"${toc}"
}

.db.top.psql.active() {
  local tof="$1"
  shift
  local query_width
  local sw=$(screen-width)
  query_width=$((sw - 68))
  sed -e "/^--.*$/d; s/QUERY_WIDTH/${query_width}/g;" "${BASHMATIC_HOME}/.db.active.sql" | tr '\n' ' ' >"${tof}.query"
}

.db.top.connection() {
  local tof="$1"
  shift
  local dbname="$1"
  shift
  local dbpass="$1"
  shift

  rm -f "${tof}.errors" >/dev/null

  printf "${bldcyn}[${dbname}] ${bldpur}Below: Active Queries:${clr}\n\n${bldylw}" >>"${tof}"

  export PGPASSWORD="${dbpass}"
  .db.top.psql.active "${tof}"

  local query="${tof}.query"
  echo psql -X -P pager -f "${query}" "$@"
  eval "$(echo psql -X -P pager -f "${query}" "$@")" >"${tof}.out"
  local code=$?
  grep -E -v 'select.*client_addr' "${tof}.out" >>"${tof}"
  [[ ${code} -ne 0 ]] && {
    error "psql exited with code ${code}" >>"${tof}.errors"
  }
}

db.top() {
  h1 "Please wait while we resolve DB names..."

  local db
  local dbname
  local width_min=90
  local height_min=50
  local width=$(.output.screen-width)
  local height=$(.output.screen-height)

  if [[ ${width} -lt ${width_min} || ${height} -lt ${height_min} ]]; then
    error "Your screen is too small for db.top."
    info "Minimum required screen dimensions are ${width_min} columns, ${height_min} rows."
    info "Your screen is ${bldred}${width}x${height}."
    return
  fi

  local -a connections_arguments
  local -a connections_names
  local -a connections_passwords

  local i=0
  local arguments
  local tof="$(mktemp -d "${TMPDIR:-/tmp/}.XXXXXXXXXXXX")/.db.top.$$"

  for connection in "$@"; do
    db.psql.args "${connection}" >"${tof}"
    arguments="$(cat ${tof})"
    connections_arguments+=("${arguments}")
    connections_names+=("${connection}")
    connections_passwords+=("${PGPASSWORD}")
    i=$((i + 1))
  done

  if [[ ${#connections_names[@]} -eq 0 ]]; then
    error "usage: $0 db1 db2 ... "
    info "eg: db.top prod-master prod-replica1 prod-replica2 "
    ((BASH_IN_SUBSHELL)) && exit 1 || return 1
  fi

  trap "clear" TERM
  trap "clear" EXIT

  local interval=${DB_TOP_REFRESH_RATE:-1}
  local num_dbs=${#connection_names[@]}

  while true; do
    local index=0
    cp /dev/null "${tof}"
    rm -f "${tof}.errors"

    cursor.at.y 0 >"${tof}"

    local screen_height=$(screen.height)

    for dbname in "${connections_names[@]}"; do
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

      local vertical_shift=$((percent_total_height * screen_height / 100))

      cursor.at.y ${vertical_shift} >>"${tof}"
      [[ -n ${DEBUG} ]] && h.blue "screen_height = ${screen_height} | percent_total_height = ${percent_total_height} | vertical_shift = ${vertical_shift}" >>"${tof}"
      hr.colored "${bldpur}" >>"${tof}"
      .db.top.connection "${tof}" "${dbname}" "${connections_passwords[${index}]}" "${connections_arguments[${index}]}"
      index=$((index + 1))
    done

    if [[ -s "${tof}.errors" ]]; then
      error "ERROR runnign psql with args: ${bldylw}${connections_arguments[${index}]}"
      cat "${tof}.errors"
      hr
      cat "${tof}"
      sleep 10
      break
    else
      clear
      cursor.at.y 0
      h.yellow " «   DbTop© v1.1.0 © 2016-2020 Konstantin Gredeskoul • © 2020 All Rights Reserved • MIT License"
      cat "${tof}"
      cursor.at.y $(($(.output.screen-height) + 1))
      printf "${bldwht}Press Ctrl-C to quit.${clr}"
    fi
    sleep "${interval}"
  done
}
