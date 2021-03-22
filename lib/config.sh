#!/usr/bin/env bash
# vim :ft=bash

export __config_format=${__config_format:-'YAML'}
export __config_file=${__config_file:-"${TOOLS_PATH}/config.yml"}

# Format
function config.set-format() {
  local format="${1^^}"
  if [[ "${format}" == "YAML" || "${format}" == "JSON" ]]; then
    export __config_format="${format}"
  else
    error "Invalid format $1: only YAML or JSON is supported."
    return 1
  fi
}

function config.get-format() {
  echo ${__config_format}
}

# File
function config.set-file() {
  [[ -f $1 ]] || {
    error "File $1 does not exist in $(pwd -P). Can not change config."
    return 1
  }
  export __config_file="$1"
}

function config.get-file() {
  printf "%s" "${__config_file}"
}

# @description Reads the value from a two-level configuration hash
# @arg1 hash key
# @arg2 hash sub-key
function config.dig() {
  local key="$1"
  local subkey="$2"
  local format="$(config.get-format)"
  local rf="require '${format}'.downcase;"
  local load_config="require 'yaml'; def config; YAML.load(File.read('${__config_file}')); end"
  local interpreter=ruby
  is-dbg && interpreter="echo -- ruby"
  local script

  if [[ -z ${key} ]] ; then
    script="${load_config}; ${rf} puts ${format}.dump(config)"
  elif [[ -n ${subkey} ]]; then
    script="${load_config}; ${rf} puts ${format}.dump(config['${key}']['${subkey}'])"
  else
    script="${load_config}; ${rf} puts ${format}.dump(config['${key}'])"
  fi

  ${interpreter} -e "${script}" || {
    error "ERROR while evaluating the following script with ruby $(ruby --version):" \
    "${script}"
    return 1
  }

  return 0
}

# @description Uses `jq` utility to format JSON with color, supports partial
function config.dig.pretty() {
  local -a args
  local -a keys

  for a in "$@"; do
    if [[ $a =~ ^- ]]; then
      args+=("$a")
    else
      keys+=("$a")
    fi
  done

  is-dbg && {
    dbg "args: ${args[*]}"
    dbg "keys: ${keys[*]}"
  }

  local format=$(config.get-format)
  config.set-format JSON
  command -v jq>/dev/null || brew.install.packages jq
  config.dig "${keys[@]}" | jq "${args[@]}"
  config.set-format ${format}
  return 0
}

