#!/usr/bin/env bash

export BashMatic__DiffTool="ydiff"

lib::yaml::expand-aliases() {
  ruby -e "require 'yaml'; require 'json'; puts YAML.dump(JSON.parse(JSON.pretty_generate(YAML.load(File.read('${1}')))))"
}

lib::yaml::diff() {
  local f1="$1"; shift
  local f2="$1"; shift

  [[ -f "$f1" && -f "$f2" ]] || {
    h2 "USAGE: ${bldylw}yaml-diff file1.yml file2.yml [ ydiff-options ]"
    return 1
  }

  [[ -n $(which ${BashMatic__DiffTool})  ]] || lib::brew::package::install ${BashMatic__DiffTool}

  local t1="/tmp/${RANDOM}.$(basename ${f1}).$$.yml"
  local t2="/tmp/${RANDOM}.$(basename ${f2}).$$.yml"

  lib::yaml::expand-aliases "$f1" > "$t1"
  lib::yaml::expand-aliases "$f2" > "$t2"

  run::set-next show-output-on
  hr
  run "ydiff $* ${t1} ${t2}"
  hr

  run "rm -rf ${t1} ${t2}"
}

yaml-diff() {
  lib::yaml::diff "$@"
}

lib::yaml::dump() {
  local f1="$1"; shift
  [[ -f "$f1" ]] || {
    h2 "USAGE: ${bldylw}yaml-dump file.yml"
    return 1
  }

  [[ -n $(which ${BashMatic__DiffTool})  ]] || lib::brew::package::install ${BashMatic__DiffTool}
  local t1="/tmp/${RANDOM}.$(basename ${f1}).$$.yml"
  lib::yaml::expand-aliases "$f1" > "$t1"
  vim "$t1"
  run "rm -rf ${t1}"
}

yaml-dump() {
  lib::yaml::dump "$@"
}
