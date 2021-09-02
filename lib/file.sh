#!/usr/local/bin/env bash
# vim: ft=bash

[[ -f "${BASHMATIC_HOME}/lib/file-helpers.sh" ]] && source "${BASHMATIC_HOME}/lib/file-helpers.sh"

# @description Creates a temporary file and returns it as STDOUT
# shellcheck disable=SC2120
function file.temp() {
  local host="${HOST:-${HOSTNAME:-$(hostname)}}"
  local user="${USER:-"$(whoami)"}"
  local temp_file_pattern=".bashmatic.${host}.${user}.${*/ /}"
  local n="$(epoch)"
  local t=$((n % 99991))
  local file="/tmp/${temp_file_pattern}${n}$$${t}${RANDOM}${RANDOM}"
  # Delete similar looking files that are more than 1 day old
  find "$(dirname "${file}")" -maxdepth 1 \
    -type f \
    -name "${temp_file_pattern}*" \
    -mtime +1 \
    -delete >/dev/null 2>&1
  echo "${file}"
}

function dir.temp() {
  local dir="$(file.temp)/$$/${RANDOM/284/_-=}"
  mkdir -p "${dir}" 2>/dev/null
  [[ -n ${__debug} ]] && {
    info "temporary folder is: ${dir}"
    inf "it exists?  "
    [[ -d ${dir}  ]] && ok:
    [[ -d ${dir}  ]] || not-ok:
  }
  printf "%s" "${dir}"
  trap "rm -rf ${dir}" EXIT
}

file.print-normalized-name() {
  local file="$1"
  echo "${file}" | tr '[:upper:]' '[:lower:]' | sed -E 's/ /-/g;s/[^\A-Za-z0-9.-/&]//g; s/--+/-/g;'
}

# @description This function will rename all files passed to it as follows: spaces
#              are replaced by dashes, non printable characters are removed,
#              and the filename is lower cased. 
#
# @example 
#       file.normalize-files "My Word Document.docx" 
#       # my-word-document.docx
#              
file.normalize-files() {
  trap 'set +x' EXIT INT

  for file in "$@"; do  
    local new_name="$(file.print-normalized-name "${file}")"
    [[ "${file}" == "${new_name}" ]] && continue
    run "mkdir -p \$(dirname \"${new_name}\")"
    if run.config.is-dry-run; then
      info "mv -v \"${file}\" \"${new_name}\""
    else
      run "mv \"${file}\" \"${new_name}\""
    fi
  done
    
  return 
}

# Replaces a given regex with a string
file.gsub() {
  local file="$1"
  shift
  local find="$1"
  shift
  local replace="$1"
  shift
  local
   runtime_options="$*"

  [[ ! -s "${file}" || -z "${find}" || -z "${replace}" ]] && {
    error "Invalid usage of file.sub — " \
      "USAGE: file.gsub <file>    <find-regex>        <replace-regex>" \
      "EG:    file.gsub ~/.bashrc '^export EDITOR=vi' 'export EDITOR=gvim'"
    return 1
  }

  # fix any EDITOR assignments in ~/.bashrc
  ${GrepCommand} -q "${find}" "${file}" || return 0

  [[ -z "${runtime_options}" ]] || run.set-next ${runtime_options}
  # replace
  run "sed -i'' -E -e 's/${find}/${replace}/g' \"${file}\""
}

# @description A super verbose shortcut to [[ file -nt file2 ]]
function file.first-is-newer-than-second() {
  [[ "$1" -nt "$2" ]]
}

# Usage:
#   (( $(file.exists-and-newer-than "/tmp/file.txt" 30) )) && echo "Yes!"
file.exists-and-newer-than() {
  local file="${1}"
  shift
  local minutes="${1}"
  shift
  if [[ -n "$(find "${file}" -mmin -"${minutes}" -print 2>/dev/null)" ]]; then
    return 0
  else
    return 1
  fi
}

# @description Ask the user whether to overwrite the file
file.ask.if-exists() {
  local file="$1"
  shift
  local message="$*"

  [[ -z "${message}" ]] && message="File ${file} exists. Overwrite?"

  if [[ -f ${file} ]]; then
    run.set-next on-decline-return
    run.ui.ask "${message}" || return 1
  fi
  return 0
}

# @description Installs a given file into a provided destination, while
#              making a copy of the destination if it already exists.
# @arg1 File to backup
# @arg2 Destination
# @arg3 [optional] Shortname of the optional backup strategy: 'bak' or 'folder'. 
#                  If not provided, defaults to 'bak'
# Alternatively, set LibFile__ForceOverwrite=1 to overwrite.
# @example
#     file.install-with-backup conf/.psqlrc ~/.psqlrc backup-strategy-function
#
file.install-with-backup() {
  local source="$1"; shift
  if [[ ! -f "${source}" ]]; then
    error "file ${source} can not be found"
    return 1
  fi

  local dest="$1"; shift

  [[ -z ${dest} ]] && {
    error "usage: file.install-with-backup <source> <dest> [ bak | folder ]"
    return 1 
  }

  local backup_strategy="${1:-"bak"}"; shift
  local backup_fn=".file.backup.strategy.${backup_strategy}"

  is.a-function "${backup_fn}" || {
    error "Invalid backup method '${backup_strategy}': supported are: 'bak' and 'folder'"
    return 1
  } 

  if [[ -f "${dest}" ]]; then 
    if [[ -z $(diff "${dest}" "${source}" 2>&1) ]]; then
      info: "The two files ${source} and ${dest} are identical."
      return 0
    else
      if [[ ${LibFile__ForceOverwrite} -eq 1 ]]; then
        info "file ${dest} already exists, but overwrite flag was set, so overwriting."
        run.set-next show-output-on
        run "cp -v \"${source}\" \"${dest}\""
        return 0
      else
        info "creating a backup of ${dest}..."
        ${backup_fn} "${dest}" && {
          success "File ${dest} has been backed up."
        } 
      fi
    fi
  fi

  run "mkdir -p $(dirname "${dest}")"
  run.set-next show-output-on
  run "cp -v ${source} ${dest}"
}

file.last-modified-date() {
  stat -f "%Sm" -t "%Y-%m-%d" "$1"
}

file.last-modified-year() {
  stat -f "%Sm" -t "%Y" "$1"
}

# Return one field of stat -s call on a given file.
file.stat() {
  local file="$1"
  local field="$2"

  [[ -f ${file} ]] || {
    error "file ${file} is not found. Usage: file.stat <filename> <stat-field-name>"
    info "eg: ${bldylw}file.stat README.md st_size"
    return 1
  }

  [[ -n ${field} ]] || {
    error "Second argument field is required."
    info "eg: ${bldylw}file.stat README.md st_size"
    return 2
  }

  # use stat and add local so that all variables created are not global
  eval "$(stat -s "${file}" | tr ' ' '\n' | sed 's/^/local /g')"
  echo "${!field}"
}

file.size() {
  util.os
  if [[ ${AppCurrentOS} =~ linux ]]; then
    stat -c %s "$1"
  else
    file.stat "$1" st_size
  fi
}

file.size.mb() {
  local file="$1"
  shift
  local s=$(file.size "${file}")
  local mb=$(echo $((s / 10000)) | sedx 's/([0-9][0-9])$/.\1/g')
  printf "%.2f MB" ${mb}
}

file.list.filter-existing() {
  for file in "$@"; do
    [[ -f "${file}" ]] && echo "${file}"
  done
}

file.list.filter-non-empty() {
  for file in "$@"; do
    [[ -s "${file}" ]] && echo "${file}"
  done
}

file.source-if-exists() {
  local file
  for file in "$@"; do
    [[ -f "${file}" ]] && source "${file}"
  done
}

files.find() {
  local folder="$1"
  local pattern="${2}"

  [[ -z ${folder} || -z ${pattern} ]] && {
    echo "usage: files.find <folder> <pattern>" >&2
    return 1
  }

  find "$1" -name "${pattern}"
}

# Function:
#   files.map
#
# Arguments:
#   folder:   directory to search for files recursively
#   pattern:  value to pass to find, eg "find . -name 'pattern'"
#   array:    name of an array to assign the results to (optional)
#
# If an array name is provided, this function will print a mini BASH script
# that should be evaluated to store the result of the recurse in
# a local array, eg:
#
# declare -a FILES
# eval "files.map ${HOME} '.bash*' FILES"
#
# echo ${FILES[0]} # => "~/.bashrc"
#
files.map() {
  local folder="${1}"
  local pattern="${2}"
  local array="${3}"

  local -a files
  if bashmatic.bash.version-four-or-later; then
    mapfile -t files < <(files.find "${folder}" "${pattern}")
  else
    files=()
    while IFS='' read -r line; do files+=("$line"); done < <(files.find "${folder}" "${pattern}")
  fi

  if [[ -n ${array} ]]; then
    # shellcheck disable=SC2124
    printf "%s" "unset ${array}; declare -a ${array}; ${array}=(${files[*]}); export ${array}"
  else
    printf "%s" "${files[*]}"
  fi
}

files.map.shell-scripts() {
  files.map "$1" '*.sh' "$2"
}

file.extension.remove() {
  local filename="$1"
  printf "${filename%.*}"
}

file.strip.extension() {
  file.extension.remove "$@"
}

file.extension() {
  local filename="$1"
  printf "${filename##*.}"
}

# usage:
#    file.extension.replace .sh $(find lib -type f -name '*.bash')
# replaces all files under lib/ mathcing *.sh and renames them
# to the given extension.
file.extension.replace() {
  local ext="$1"
  shift

  [[ -z "$1" ]] && {
    info "USAGE: file.extension.replace <new-extension> file1 file2 ... "
    return 1
  }

  ext=".$(echo ${ext} | tr -d '.')"

  local first=true
  for file in "$@"; do
    ${first} || printf " "
    printf "%s%s" "$(file.strip.extension "${file}")" "${ext}"
    first=false
  done
}

file.sync() {
  local from="$1"
  local to="$2"

}

file.find() {
  find . -name "*$1*" -type f -print
}

dir.find() {
  find . -name "*$1*" -type d -print
}
