#!/usr/bin/env bash
# vim :ft=bash
#
# @description Read keys from hash-maps stored as YAML or JSON
#

#  @description Set default format — either YAML or JSON
function config.set-format() {
  local format="${1^^}"
  if [[ "${format}" == "YAML" || "${format}" == "JSON" ]]; then
    export bashmatic__config_format="${format}"
  else
    error "Invalid format $1: only YAML or JSON is supported."
    return 1
  fi
}

# @description Get current format
function config.get-format() {
  echo -n "${bashmatic__config_format}"
}

# @description Set the default config file
function config.set-file() {
  export bashmatic__config_file="$1"
  if [[ ${bashmatic__config_file} =~ \.yml$ || ${bashmatic__config_file} =~ \.yaml$ || \
        ${bashmatic__config_file} =~ \.YML$ || ${bashmatic__config_file} =~ \.YAML$  ]];  then
    config.set-format yaml
  elif [[ ${bashmatic__config_file} =~ \.json$ || ${bashmatic__config_file} =~ \.JSON$ ]]; then
    config.set-format json
  else
    warning "File extension is not recognized." "Use config.set-format [json|yaml]" >&2
  fi
}

# @description Get the file name
function config.get-file() {
  printf "%s" "${bashmatic__config_file}"
}

# @description Reads the value from a two-level configuration hash
# @arg1 hash key
# @arg2 hash sub-key
function config.dig() {
  local key="$1"
  local subkey="$2"
  local format="$(config.get-format)"
  local format_lower="$(config.get-format | tr '[:upper:]' '[:lower:]')"
  local rf="require '${format_lower}'; "
  local load_config="${rf}; def config; ${format}.load(File.read('${bashmatic__config_file}')); end"
  local interpreter="$(command -v ruby)"
  local script

  if [[ -z ${key} ]]; then
    script="${load_config}; ${rf} pp config"
  elif [[ -n ${subkey} ]]; then
    script="${load_config}; ${rf} puts config['${key}']['${subkey}']"
  else
    script="${load_config}; ${rf} pp config['${key}']"
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
  command -v jq >/dev/null || package.install.packages jq
  config.dig "${keys[@]}" | jq "${args[@]}" | tr -d '"'
  config.set-format "${format}"
  return 0
}


