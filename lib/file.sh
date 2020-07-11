#!/usr/bin/env bash

# Makes a file executable but only if it already contains
# a "bang" line at the top.
#
# Usage: .file.make_executable ${pathname}
.file.make_executable() {
  local file=$1

  if [[ -f ${file} && -n $(head -1 $1 | grep -Ee '#!.*(bash|ruby|env)') ]]; then
    printf "making file ${bldgrn}${file}${clr} executable since it's a script...\n"
    chmod 755 ${file}
    return 0
  else
    return 1
  fi
}

.file.remote_size() {
  local url=$1
  printf $(($(curl -sI $url | grep -i 'Content-Length' | awk '{print $2}') + 0))
}

.file.size_bytes() {
  local file=$1
  printf $(($(wc -c <$file) + 0))
}

# Replaces a given regex with a string
file.gsub() {
  local file="$1"
  shift
  local find="$1"
  shift
  local replace="$1"
  shift
  local runtime_options="$*"

  [[ ! -s "${file}" || -z "${find}" || -z "${replace}" ]] && {
    error "Invalid usage of file.sub — " \
      "USAGE: file.gsub <file>    <find-regex>        <replace-regex>" \
      "EG:    file.gsub ~/.bashrc '^export EDITOR=vi' 'export EDITOR=gvim'"
    return 1
  }

  # fix any EDITOR assignments in ~/.bashrc
  grep -Ee -q "${find}" "${file}" || return 0

  [[ -z "${runtime_options}" ]] || run.set-next ${runtime_options}
  # replace
  run "sed -i'' -E -e 's/${find}/${replace}/g' \"${file}\""
}

# Usage:
#   (( $(file.exists-and-newer-than "/tmp/file.txt" 30) )) && echo "Yes!"
file.exists-and-newer-than() {
  local file="${1}"
  shift
  local minutes="${1}"
  shift
  if [[ -n "$(find ${file} -mmin -${minutes} -print 2>/dev/null)" ]]; then
    return 0
  else
    return 1
  fi
}

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

file.install-with-backup() {
  local source=$1
  local dest=$2
  if [[ ! -f ${source} ]]; then
    error "file ${source} can not be found"
    return -1
  fi

  if [[ -f "${dest}" ]]; then
    if [[ -z $(diff ${dest} ${source} 2>/dev/null) ]]; then
      info: "${dest} is up to date"
      return 0
    else
      ((${LibFile__ForceOverwrite})) || {
        info "file ${dest} already exists, skipping (use -f to overwrite)"
        return 0
      }
      inf "making a backup of ${dest} (${dest}.bak)"
      cp "${dest}" "${dest}.bak" >/dev/null
      ui.closer.ok:
    fi
  fi

  run "mkdir -p $(dirname ${dest}) && cp ${source} ${dest}"
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
  eval $(stat -s ${file} | tr ' ' '\n' | sed 's/^/local /g')
  echo ${!field}
}

file.size() {
  AppCurrentOS=${AppCurrentOS:-$(uname -s)}
  if [[ "Linux" == ${AppCurrentOS} ]]; then
    stat -c %s "$1"
  else
    file.stat "$1" st_size
  fi
}

file.size.mb() {
  local file="$1"
  shift
  local s=$(file.size ${file})
  local mb=$(echo $(($s / 10000)) | sedx 's/([0-9][0-9])$/.\1/g')
  printf "%.2f MB" ${mb}
}

file.list.filter-existing() {
  for file in $@; do
    [[ -f ${file} ]] && echo "${file}"
  done
}

file.list.filter-non-empty() {
  for file in $@; do
    [[ -s ${file} ]] && echo "${file}"
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

file.find() {
  find . -name "*$1*" -type f -print
}

ff() {
  file.find "$@"
}

dir.find() {
  find . -name "*$1*" -type d -print
}
