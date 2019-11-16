#!/usr/bin/env bash

export BashMatic__DiffTool="ydiff"

lib::yaml::expand() {
  ruby -e "require 'yaml'; puts YAML.dump(YAML.load(File.read('${1}')))"
}

lib::yaml::diff() {
  local f1="$1"; shift
  local f2="$1"; shift

  [[ -f "$f1" && -f "$f2" ]] || {
    h2 "USAGE: ${bldylw}yaml-diff file1.yml file2.yml [ ydiff-options ]"
    return 1
  }

  [[ -n $(which ${BashMatic__DiffTool})  ]] || lib::brew::package::install ${BashMatic__DiffTool}

  local t1="/tmp/${RANDOM}.$(basename ${f1}).$$"
  local t2="/tmp/${RANDOM}.$(basename ${f2}).$$"

  lib::yaml::expand "$f1" > "$t1"
  lib::yaml::expand "$f2" > "$t2"

  run::set-next show-output-on
  run "ydiff $* ${t1} ${t2}"
}

yaml-diff() {
  lib::yaml::diff "$@"
}
