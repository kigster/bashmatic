#!/usr/bin/env bash
# Private

function .usage.setup() {
  export __color_fg=${1:-${txtylw}}
  export __color_bdr=${2:-${txtblu}}
  export __color_cmd=${3:-${txtgrn}}
  export __color_flag=${4:-${txtpur}}
  export __color_headers=${5:-${bldred}}
  export __color_sub_headers=${5:-${bldcyn}}
}

function .usage.begin() {
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

export LibUsage__MinFlagLen=14
export LibUsage__NoFlagsIndent=15

usage.set-min-flag-len() {
  export LibUsage__MinFlagLen="${1}"
}

function .usage.flags() {
  local -a flags=("$@")
  local line=""
  local n=0
  local l=0

  local l_flags=0
  local l_desc=0

  # First we compute the length of the longest flag, and longest flag
  # description. Yes, I know — total overkill.
  for arg in "${flags[@]}"; do
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
      local left_color=${__color_flag}
      local left_prefix="    "
      if [[ ${arg:0:1} == "├" ]]; then
        .output.box-separator "${__color_bdr}"
        arg=${arg:1}
        left_color="${__color_sub_headers}"
        left_prefix=""
      fi
      line=$(printf "${left_prefix}${left_color}%-${l_flags}s" "${arg}")
    else
      line=$(printf "%s${__color_fg}  %s\n" "${line}" "${arg}")

      .output.boxed-text "${__color_bdr}" "${__color_cmd}" "${line}"
    fi
    n=$((n + 1))
  done

  printf "${__color_bdr}"
  .output.box-bottom
}

# TODO: ensure this works across file sourcing
function .usage-cache-file() {
  local script_name="${BASH_SOURCE[-1]}"
  local script_dir="$(dirname "${script_name}")"
  local script_base="$(basename "${script_name}")"
  local script_usage_cache="${script_dir}/.${script_base}"
  printf "%s" "${script_usage_cache}"
}

function .usage.box() {
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

# Prints usage information for a command.
#
# usage-box "command © title" "flag1" "flag1 description" "flag2" "flag2 description"...
#
# eg:
#    usage-box "/bin/ls © Command that lists all files in the current directory" \
#              "-1" "Force output to be one entry per line." \
#              "-A" "List all entries except for . and ...  " \

export EXPIRE_USAGE_CACHE=${EXPIRE_USAGE_CACHE:-"0"}

function usage-box() {
  local backup="$(.usage-cache-file)"
  if [[ "${EXPIRE_USAGE_CACHE}" -eq 0 && -s "${backup}" ]]; then
    cat "${backup}"
  else
    .usage.box "$@" | tee "${backup}"
  fi
}

function usage-box.section() {
  printf "${__color_headers}"
  .usage.hdr "$*"
}

function usage-box.sub-section() {
  .output.box-separator "${__color_bdr}"
  .output.boxed-text "${__color_bdr}" "${__color_sub_headers}" "$(.usage.hdr "$1")"
}

# Help Helpers that are typically online lineers.

function help-name() {
  box.white-on-green "$@"
}

function help-section() {
  printf "\n${bldgrn}$(echo "$*" | tr '[:lower:]' '[:upper:]')\n"
}

function help-command() {
  printf "    ${bldylw}\$ $*\n"
}

function help-example() {
  printf "    ${bldgrn}\$ $*\n"
}

function help-comment() {
  printf "    ${txtblk}# $*\n"
}

function help-details() {
  printf "    ${txtblu}$*\n"
}

# @description
#     This is a massive hack and I am ashemed to have written it.
#     With that out of the way, here we go. This command generates a pretty usage box
#     for a tool or another command.
#
# @example
#     usage-widget [-]<width> \                         # box width. If it starts with "-" forces cache wipe.
#         "command [flags] <arg1 ... >" \               # <-- USAGE
#         "This command is beyond description." \       # <-- DESCRIPTION
#         "[®]string" \                                 # <-- This and subsequent lines may optionally start with "®" symbol,
#         "[®]string" \                                 #     which will turn them into sub-headings:
#         "[®]string" \
#         "[®]string"
#
# @example
#      usage-widget 90 \
#         "command [flags] <arg1 ... >" \
#         "This command is beyond description." \
#         "®examples" \
#         "Some examples will follow" \
#         "And others won't."
#     ┌──────────────────────────────────────────────────────────────────────────────────────┐
#     │  USAGE:           command [flags] <arg1 ... >                                        │
#     ├──────────────────────────────────────────────────────────────────────────────────────┤
#     │  DESCRIPTION:     This command is beyond description.                                │
#     ├──────────────────────────────────────────────────────────────────────────────────────┤
#     │                                                                                      │
#     │  EXAMPLES:                                                                           │
#     │                   Some examples will follow                                          │
#     │                   And others won't.                                                  │
#     └──────────────────────────────────────────────────────────────────────────────────────┘
#
function usage-widget() {
  local width="$1"
  local cache_wipe=0

  [[ ${width} =~ ^- ]] && {
    cache_wipe=1
    width=${width:1}
  }

  is.numeric "${width}" && {
    shift
    bashmatic.set-widget-width-to "${width}"
  }

  ((cache_wipe)) && rm -f "$(.usage-cache-file)"

  local -a args=("$@")
  is-debug && {
    h1 "Got total of ${#args[@]} arguments."
  }

  local -a details
  local left_space
  left_space="$(cursor.right 1) "

  if [[ ${#args[@]} -gt 2 ]]; then
    for i in $(seq 2 50); do
      [[ -z ${args[$i]} ]] && break

      if [[ ${args[$i]} =~ ^® ]]; then
        details+=("$(cursor.left 4)$(usage-box.section "${args[$i]/®/}")")
        details+=(" ")
      else
        details+=("${left_space}")
        details+=("$(cursor.left 6)${args[$i]}")
      fi
    done
  fi

  usage-box "${args[0]} © ${args[1]}" \
    "$(cursor.up 1; cursor.left 5)" "$(cursor.right 10)" \
    "${details[@]}"
}


