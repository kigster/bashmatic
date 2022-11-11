#!/usr/bin/env bash
#===============================================================================
# Private Functions
#===============================================================================

export RAILS_SCHEMA_RB="db/schema.rb"
export RAILS_SCHEMA_SQL="db/structure.sql"

#===============================================================================
# Public Functions
#===============================================================================

db.rails.schema.file() {
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

db.rails.schema.checksum() {
  if [[ -d db/migrate ]]; then
    find db/migrate -type f -ls | awk '{printf("%10d-%s\n",$7,$11)}' | sort | shasum | awk '{print $1}'
  else
    local schema=$(db.rails.schema.file)
    [[ -s ${schema} ]] || error "can not find Rails schema in either ${RAILS_SCHEMA_RB} or ${RAILS_SCHEMA_SQL}"
    [[ -s ${schema} ]] && shasum.sha-only "${schema}"
  fi
}


