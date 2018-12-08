#!/usr/bin/env bash

# Makes a file executable but only if it already contains
# a "bang" line at the top.
#
# Usage: __lib::file::make_executable ${pathname}
__lib::file::make_executable() {
  local file=$1

  if [[ -f ${file} && -n $(head -1 $1 | egrep '#!.*(bash|ruby|env)') ]]; then
    printf "making file ${bldgrn}${file}${clr} executable since it's a script...\n"
    chmod 755 ${file}
    return 0
  else
    return 1
  fi
}

__lib::file::remote_size() {
  local url=$1
  printf $(($(curl -sI $url | grep -i 'Content-Length' | awk '{print $2}') + 0))
}

__lib::file::size_bytes() {
  local file=$1
  printf $(($(wc -c < $file) + 0))
}
# Usage:
#   (( $(lib::file::exists_and_newer_than "/tmp/file.txt" 30) )) && echo "Yes!"
lib::file::exists_and_newer_than() {
  [[ -n "$(find ${1} -mmin -${2} -print 2>/dev/null)" ]]
}

lib::file::install_with_backup() {
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
      (( ${LibFile__ForceOverwrite} )) || {
        info "file ${dest} already exists, skipping (use -f to overwrite)"
        return 0
      }
      inf "making a backup of ${dest} (${dest}.bak)"
      cp "${dest}" "${dest}.bak" >/dev/null
      ok:
    fi
  fi

  run "mkdir -p $(dirname ${dest}) && cp ${source} ${dest}"
}

lib::file::last-modified-date() {
  stat -f "%Sm" -t "%Y-%m-%d" "$1"
}

lib::file::last-modified-year() {
  stat -f "%Sm" -t "%Y" "$1"
}

# Return one field of stat -s call on a given file.
file::stat() {
  local file="$1"
  local field="$2"

  [[ -f ${file} ]] || {
    error "file ${file} is not found. Usage: file::stat <filename> <stat-field-name>"
    info "eg: ${bldylw}file::stat README.md st_size"
    return 1
  }
  
  [[ -n ${field} ]] || {
    error "Second argument field is required."
    info "eg: ${bldylw}file::stat README.md st_size"
    return 2
  }

  # use stat and add local so that all variables created are not global
  eval $(stat -s ${file} | tr ' ' '\n' | sed 's/^/local /g')
  echo ${!field}
}

file::size() {
  file::stat "$1" st_size
}

