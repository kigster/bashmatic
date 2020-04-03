# Private

.usage.setup() {
  export __color_fg=${1:-${bldylw}}
  export __color_bdr=${2:-${bldblu}}
  export __color_cmd=${3:-${bldgrn}}
  export __color_flag=${4:-${bldpur}}
  export __color_headers=${5:-${bldred}}
}

.usage.begin() {
  .usage.setup "$@"
  .output.box-top "${__color_bdr}"
}

.usage.title() {
  for line in "$@"; do
    .output.boxed-text "${__color_bdr}" "${__color_fg}" "${__color_headers}$(.usage.hdr description) ${__color_fg}${line}"
  done
  .output.box-separator "${__color_bdr}"
}

.usage.command() {
  .output.boxed-text "${__color_bdr}" "${__color_headers}" "$(.usage.hdr usage) ${__color_cmd}$1"
  shift

  for line in "$@"; do
    .output.boxed-text "${__color_bdr}" "${__color_cmd}" "         ${line}"
  done
  .output.box-separator "${__color_bdr}"
}

.usage.hdr() {
  printf "%-15s " "$*:" | tr 'a-z' 'A-Z'
}

export LibUsage__MinFlagLen=15
export LibUsage__NoFlagsIndent=15

usage.set-min-flag-len() {
  export LibUsage__MinFlagLen="${1}"
}

.usage.flags() {
  local -a flags=("$@")
  local line=""
  local n=0
  local l=0

  local l_flags=0
  local l_desc=0

  # First we compute the length of the longest flag, and longest flag
  # description. Yes, I know — total overkill.
  for arg in "$@"; do
    if (($(($n % 2)) == 0)); then
      l=${#arg}
      [[ $l -gt ${l_flags} ]] && l_flags=$l
    else
      [[ $l -gt ${l_desc} ]] && l_desc=$l
    fi
    n=$((n + 1))
  done

  if [[ ${l_flags} -eq 0 ]]; then
    l_flags="${LibUsage__NoFlagsIndent}"
  elif [[ ${l_flags} -lt ${LibUsage__MinFlagLen} ]]; then
    l_flags=${LibUsage__MinFlagLen}
  fi

  local n=0
  .output.boxed-text "${__color_bdr}" "${__color_headers}" "$(.usage.hdr flags)"

  for arg in "$@"; do
    if (($(($n % 2)) == 0)); then
      line=$(printf "${__color_flag}%${l_flags}s" "${arg}")
    else
      line=$(printf "%s${__color_fg}  %s\n" "${line}" "${arg}")

      .output.boxed-text "${__color_bdr}" "${__color_cmd}" "${line}"
    fi
    n=$((n + 1))
  done

  printf "${__color_bdr}"
  .output.box-bottom
}

# Prints usage information for a command.
#
# usage-box "command © title" "flag1" "flag1 description" "flag2" "flag2 description"...
#
# eg:
#    usage-box "/bin/ls © Command that lists all files in the current directory" \
#              "-1" "Force output to be one entry per line." \
#              "-A" "List all entries except for . and ...  " \

usage-box() {
  local command
  local title

  if [[ "${1}" =~ "©" ]]; then
    command="${1/ © */}"
    title="${1/* © /}"
  else
    command="$1"
    title=
  fi

  shift

  .usage.begin
  .usage.command "${command}"
  [[ -n ${title} ]] && .usage.title "${title}"
  [[ -n "$*" ]] && .usage.flags "$@"
}
