#!/usr/bin/env bash
# @file dir.sh
# @description 
#   This file contains many useful functions for handling directories, 
#   sync'ing and copying from and to directories, and so on.

#——————————————————————————————————————————————————————————————————————————————————

# @description 
#   Returns the first folder above the given that contains a file.
# @arg1 file without the path to search for, eg ".evnrc"
# @arg2 Starting file path to seartch
# @output File path that's a sub-phat of the @arg2 contaning the file. if no file is found, 1 or 2 is returned.
function dir.with-file() {
  local file="$1"
  local dir="${2:-$(pwd -P)}"

  if [[ ${dir:0:1} != "/" ]]; then
    dir="$(pwd -P)/${dir}"
  fi

  local _d="${dir}"

  while true; do
    local try="${_d}/${file}"
    [[ -f "${try}" ]] && {
      echo "${_d}"
      return 0
    }
    _d="$(dirname "${_d}")"
    if [[ "${_d}" == "/" || "${_d}" == "" ]] ; then
      [[ -f "${_d}/${file}" ]] || {
        echo "No file ${file} was found in the path.">&2
        return 1
      }
      echo "${_d}"
      exit 0
    fi
   done
  return 2
}

function dir.count-slashes() {
  local dir="${1}"
  echo "${dir}" |
    sed 's/[^/]//g' |
    tr -d '\n' |
    wc -c |
    tr -d ' '
}

dir.is-a-dir() {
  local dir="${1}"
  [[ -d "${dir}" ]]
}

dir.expand-dir() {
  local dir="${1}"
  # Replace the ~

  if [[ "${dir:0:1}" != "/" && "${dir:0:1}" != "~" ]]; then
    # it's a local directory
    dir="$(pwd)/${dir}"
  elif [[ "${dir:0:1}" == "~" ]]; then
    # it's a folder relative to our home
    dir="${HOME}/${dir:1:1000}"
  fi

  printf -- "%s" "${dir}"
}

# @description Replaces the first part of the directory that matches ${HOME} with '~/'
dir.short-home() {
  local dir="$1"
  # This does not work for some reason
  # printf -- "%s" "${dir/${HOME}/~}"
  printf -- "%s" "${dir}" | sed -E "s#${HOME}#~#g"
}

# @description 
#     Rsyncs the files from a "from" directory specified by the first argument,
#     to the to directory specified by the second.
# @arg1 The source locl directory
# @arg2 The destination locl directory
# @arg3 optional `--sudo`: runs rsync in sudo mode. Careful!
# @arg4 Any additional arguments to rsync such as --verbose
function dir.rsync-to() {
  local from="$1"; shift
  local to="$1"; shift
  
  local -a extra_rsync_flags
  local sudo=false

  for flag in "$@"; do
    if [[ ${flag} == "--sudo" ]]; then
      sudo=true
    else  
      extra_rsync_flags+=("${flag}")
    fi
  done
  
  local extra_flags="${extra_rsync_flags[*]}"
  
  [[ -d "${from}" ]] || {
    error "usage: dir.rsync-to [ from-dir ] [ enclosing-to-dir ] [ custom-flags ]" "Directory ${from} does not exist."
    return 1
  }

  [[ -d "${to}" ]] || {
    error "usage: dir.rsync-to [ from-dir ] [ enclosing-to-dir ] [ custom-flags ]" "Directory ${to} does not exist."
    return 1
  }

  command -v rsync >/dev/null || package.install rsync
  command -v rsync >/dev/null || {
    error "Unable to find rsync even after installing. Aborting"
    return 2
  }

  local from_pwd="$(cd "${from}" || exit 1; pwd -P)"
  h1.yellow  "Starting RSync" \
    "From    →   ${txtgrn}[${from_pwd}]" \
    "Dest    →   ${txtcyn}[${to}]" \
    "Flags   →   ${txtred}[${extra_flags}]"

  local flags="-aht"
  local command="rsync ${flags} ${extra_flags} \"${from_pwd}\" \"${to}\""
  ${sudo} && command="sudo ${command}"

  h1  "Rsync Command:" "${bldylw}${command}"

  run.ui.press-any-key "Press any key to run this command, or Ctrl-C to abort."

  h2 "Starting rsync process..."
  run.set-next show-output-on 
  run "${command}"
}

# @description 
#   This is a variation on the above that preserves extended attributes
#   of the source files, such as icons for direcories. When copying a 
#   folder from the Mac OS-X this is recommended.
function dir.rsync-from-mac() {
  dir.rsync-to "$1" "$2" "--iconv=utf-8-mac,utf-8 --xattrs" "${@:3}"
}

# @description 
#   This is a variation on the above that preserves extended attributes
#   of the source files, such as icons for direcories, and add --verbose
#   to rsync flags so that you can the files being synced.
function dir.rsync-from-mac-verbose() {
  dir.rsync-to "$1" "$2" "--iconv=utf-8-mac,utf-8 --xattrs" "-v" "${@:3}"
}


