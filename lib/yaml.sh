#!/usr/bin/env bash

export BashMatic__DiffTool="ydiff"

yaml.expand-aliases() {
  local file="${1}"
  local temp=$(mktemp)
  cat <<-RUBY > "${temp}"
  require 'yaml'; 
  puts YAML.dump(YAML.load(File.read('${file}'), aliases: true))
RUBY
  ruby "${temp}"
  rm -f "${temp}"
}

yaml.diff() {
  local f1="$1"
  shift
  local f2="$1"
  shift

  [[ -f "$f1" && -f "$f2" ]] || {
    h2 "USAGE: ${bldylw}yaml-diff file1.yml file2.yml [ ydiff-options ]"
    return 1
  }

  [[ -n $(which ${BashMatic__DiffTool}) ]] || brew.package.install ${BashMatic__DiffTool}

  local t1="/tmp/${RANDOM}.$(basename "${f1}").$$.yml"
  local t2="/tmp/${RANDOM}.$(basename "${f2}").$$.yml"

  yaml.expand-aliases "$f1" >"$t1"
  yaml.expand-aliases "$f2" >"$t2"

  run.set-next show-output-on
  hr
  run "ydiff $* ${t1} ${t2}"
  hr

  run "rm -rf ${t1} ${t2}"
}

yaml-diff() {
  yaml.diff "$@"
}

yaml.dump() {
  local f1="$1"
  shift
  [[ -f "$f1" ]] || {
    h2 "USAGE: ${bldylw}yaml-dump file.yml" >&2
    return 1
  }

  [[ -n $(which ${BashMatic__DiffTool}) ]] || brew.package.install ${BashMatic__DiffTool}
  local t1="$(mktemp)"
  export yaml_dump_file="$t1.$(basename "$f1")"
  yaml.expand-aliases "$f1" > "${yaml_dump_file}"
  cat "${yaml_dump_file}"
}

yaml.edit() {
  yaml.dump "$@"
  vim "${yaml_dump_file}"
}

yaml-dump() {
  yaml.dump "$@"
}


