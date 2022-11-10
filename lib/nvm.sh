#!/usr/bin/env bash

declare -a __bashmatic_nvm_dirs

export __bashmatic_nvm_dirs=(
  "${HOME}/.nvm"
  /usr/local/Cellar/nvm
  /usr/local/opt/nvm
)

export __default_nvm_home="${__bashmatic_nvm_dirs[0]}"

# @description Returns true if NVM_DIR is correctly set, OR if
#              a directory passed as an argument contains nvm.sh
function nvm.is-valid-dir() {
  [[ -z $1 ]] && return 1
  local d="$1"
  [[ -d "${d}" && -s "${d}/nvm.sh" ]]
}

# @description
#   Returns success and exports NVM_DIR whenver nvm.sh is found underneath any
#   of the possible locations tried.
function nvm.detect() {
  for dir in "${__bashmatic_nvm_dirs[@]}"; do
    nvm.is-valid-dir "${dir}" && {
      export NVM_DIR="${dir}"
      source "${NVM_DIR}/nvm.sh"
      return 0
    }
  done
  return 1
}

# @description Installs NVM via Curl if not already installed.
function nvm.install() {
  h.blue "Installing nvm_.."
  # This both installs NVM and also evals the lines it outputs during installation matching NVM_DIR
  # this ensures that NVM is fully loaded after this line
  local temp="/tmp/nvm_$$"
  (curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh 2>/dev/null| bash 2>/dev/null) | grep NVM_DIR > "${temp}"
  # Honestly we probably don't need to do this, since we still call nvm_load later...
  # But then we have to guess where NVM_DIR once again, when we can just eval it and be done with it...
  source "${temp}"
  rm -f "${temp}"
  return 0
}

function nvm.use() {
  [[ -f .nvmrc ]] || return 1
  is.a-function nvm || nvm.load
  local node_version="$(cat .nvmrc | head -1)"
  info "Activating NodeJS ${bldred}${node_version}..."
  nvm use "${node_version}" && return 0

  warning "No version ${node_version} was detected, installing"
  run.set-next show-output-on
  run "nvm install ${node_version}"

  nvm use "${node_version}" && return 0
  error "Unable to install node version ${node_version}"
  return 1
}

# @description Loadd
function nvm.load() {
  nvm.detect || nvm.install
  is.a-function nvm || {
    [[ -s "$NVM_DIR/nvm.sh" ]]          && source "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
  }

  [[ -f .nvmrc ]] && {
    nvm use 1>/dev/null 2>&1 || {
      h3 "NVM must install Node version $(cat .nvmrc), please wait..."
      run "nvm install && nvm use"
    }
  }
}

function node.install.pin.version() {
  local node_version="${1:-${node_version}}"
  if is.command volta; then
    volta install "node@${node_version}"
    volta pin "node@${node_version}"
  else
    nvm.activate
  fi
}

function nvm.activate() {
  is.an-existing-file .nvmrc && { 
    export node_version=$(cat .nvmrc | tr -d 'v')
    info "Detected node version ${node_version}"  
  } 
  nvm.load
}



