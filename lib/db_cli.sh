#!/usr/bin/env bash
# vim: ft=sh
# shellcheck disable=2046

source "${BASHMATIC_HOME}/lib/db.sh"

function db.commands-list() {
  h5 "Available Commands"
  source "${BASHMATIC_LIB}/util.sh"
  db.refresh.actions
  printf "${bldgrn}"
  array.to.bullet-list "${db_actions[@]}" | sed 's/^/     /g'
  echo
  hr
  echo
  exit 0
}

function db.connections-list() {
  h4 "Available Database Connections"
  local -a connections
  connections=($(db.actions.connections))
  printf "${bldblu}"
  array.to.bullet-list "${connections[@]}" | sed 's/^/     /g'
  echo
  hr
  echo
  exit 0
}

function db.actions.commands() {
  db.commands-list
}

declare -a db_actions

function db.refresh.actions() {
  export db_actions=($(util.functions-matching.diff db.actions.))
}

function db.usage() {
  local config="~/$(basename $(dirname "${bashmatic_db_config}"))/$(basename "${bashmatic_db_config}")"
  usage-box "db [global flags] command [command flags] connection [-- psql flags] © Performs one of many supported actions against PostgreSQL" \
    "-q / --quiet" "Suppress the colorful header messages" \
    "-v / --verbose" "Show additional output" \
    "-n / --dry-run" "Only print commands, but do not run them" \
    "├GLOBAL FLAGS:" " " \
    "-w / --width WIDTH" "Use specified screen width instead of automatic." \
    "-f / --filter REGEX" "Defaults to 'idle', but can be set" \
    " " "to remove some active queries from the view." \
    "-C / --commands" "List all sub-commands to the db script" \
    "-c / --connections" "List all available database connections" \
    "-e / --examples" "Show script usage examples" \
    "-h / --help" "Show this help screen" \
    " " " " \
    "├SUMMARY:" " " \
    " " "This tool uses a list of database connections defined in the" \
    " " "YAML file that must be installed at: ${bldylw}${config}" \
    " " " "
}

function db.examples() {
  h2 EXAMPLES \
    "${txtblu}${italic}# List available connection names" \
    "${bldylw}db --connections" \
    " " \
    "${txtblu}${italic}# List available sub-commands" \
    "${bldylw}db --commands" \
    " " \
    "${txtblu}${italic}# Connect to the database named 'staging.core' using psql" \
    "${bldylw}db connect staging.core" \
    " " \
    "${txtblu}${italic}# Show 'db top' for up to 3 databases at once:" \
    "${bldylw}db top prod.core prod.replica1 prod.replica2" \
    " " \
    "${txtblu}${italic}# Use 'pg_activity' to show db top for one connection:" \
    "${bldylw}db pga prod.core" \
    " " \
    "${txtblu}${italic}# Show all settings currently active on production DB in TOML/ini format:" \
    "${txtblu}${italic}# and suppress the header with -q:" \
    "${bldylw}db db-settings-toml prod.core -q" \
    " " \
    "${txtblu}${italic}# Run a query with the default output" \
    "${bldylw}db run -q prod.core 'select relname,n_live_tup from pg_stat_user_tables order by n_live_tup desc'" \
    " " \
    "${txtblu}${italic}# Run the same query, but this time output in a CSV format" \
    "${txtblu}${italic}# NOTE: majority of the flags are passed to the ${bldgrn}psql${clr}${txtblu}${italic} to format the output," \
    "${txtblu}${italic}#       except -q is consumed by the script and turns off the script header." \
    "${txtblu}${italic}#       While -P flag is equivalent to \pset in psql session." \
    "${bldylw}export query='select relname,n_live_tup from pg_stat_user_tables order by n_live_tup desc'" \
    "${bldylw}db run staging.core \"\${query} limit 10\" -q -AX -P pager=0 -P fieldsep=, -P footer=off" \
    " " \
    "${txtblu}${italic}NOTE: read more about psql formatting options via \pset and --pset flags:" \
    "${txtblu}${italic}      ${undgrn}https://bit.ly/psql-pset"
}

export flag_quiet=0
export flag_verbose=0
export flag_filter_active="idle"
export flag_width="$(output.screen-width.actual)"
export action=

function db.main() {
  declare -a psql_extra_args
  export psql_extra_args=()

  # Parse additional flags
  [[ -z "$*" ]] && {
    db.usage
    return
  }

  while :; do
    case $1 in
    -h | --help)
      shift
      db.usage
      return
      ;;

    -e | --examples)
      shift
      db.examples
      return
      ;;

    -c | --connections)
      shift
      db.connections-list
      return
      ;;

    -q | --quiet)
      shift
      export flag_quiet=1
      ;;

    -v | --verbose)
      shift
      export flag_verbose=1
      ;;

    -C | --commands)
      shift
      h3 "Valid actions are:" "${db_actions[@]}"
      exit 0
      ;;

    -f | --filter)
      shift
      [[ "$1" =~ "%" ]] && {
        error "The filter expression is automatically wrapped in '%<expression>%'," \
          "so — no need to add '%' yourself."
        exit 1
      }
      export flag_filter_active="$1"
      shift
      ;;

    -w | --width)
      shift
      is.numeric "$1" || {
        error "Argument to -w | --width must be a number, dear."
        exit 1
      }
      export flag_width="$1"
      shift
      ;;

    [a-z]*)
      [[ -n ${action} ]] && break
      export action="$1"
      shift
      array.includes "${action}" "${db_actions[@]}" || {
        error "Invalid Command" "${action}"
        db.commands-list
        return 1
      }
      export func="db.actions.${action}"
      ;;

    --)
      shift
      # Remaining arguments are for psql
      export psql_extra_args=("$@")
      while (($#)); do
        shift
      done
      ;;

    *)
      [[ -z "$1" ]] && break
      error "Unknown flag $1 —— if it's intended for psql, please add -- before it."
      return 2
      ;;
    esac
  done

  is.a-function "${func}" || {
    error "Invalid action ${action}!"
    db.usage
    return 3
  }

  ${func} "$@"
}

db.cli-setup() {
  db.refresh.actions
  color.enable >/dev/null
  output.constrain-screen-width 110

  if [[ $(screen.width) -lt 110 ]]; then
    error "Please resize your terminal to have at last 110 columns."
    return 1
  fi
}
