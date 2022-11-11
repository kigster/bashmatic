#!/usr/bin/env bash

function ssh.key.copy() {
  cat ~/.ssh/id_rsa.pub | pbcopy
}

function ssh.key.filenames() {
  local name="$1"

  is.not-blank "${name}" && name="_${name}"

  export __bm__private_key_path="${HOME}/.ssh/id_rsa${name}"
  export __bm__public_key_path="${HOME}/.ssh/id_rsa${name}.pub"
  export __bm__ssh_folder="${HOME}/.ssh"
}

function ssh.load-keys() {
  local pattern="$1"

  ssh.key.filenames "$@"

  local dir="${__bm__ssh_folder}"
  local regex="id_*${pattern}*"

  info "Loading keys from ${bldylw}${dir}$(txt-info), matching regex: ${bldred}[${regex}]"

  find "${dir}" -type f \
    -name "${regex}" -and -not \
    -name '*.pub' \
    -exec ssh-add {} \;
}

alias lk="ssh.load-keys"

function ssh.keys.generate() {
  local name="$1"
  local code=0

  local email
  local date="$( time.now.db )"

  ssh.key.filenames "$@"

  if is.a-non-empty-file "${__bm__private_key_path}" ; then
    warning "Private key already exists at the path:" "${bldred}${__bm__private_key_path}"

    is.blank "${name}" && \
      info "NOTE You can pass an optional name argument to this function"
      info "so that the key file will be unique."

    ( run.ui.ask "Replace the existing key (previous key will be backed up)?" )
    
    code=$?

    ((code)) && return 1    
  fi

  is.a-function user.gitconfig.email && \
    email="$(user.gitconfig.email)"
  
  is.blank "${email}" && \
    run.ui.ask-user-value email "Please enter the email address for this key:"

  if [[ -f "${__bm__private_key_path}"  ]]; then
    for file in "${__bm__private_key_path}" "${__bm__public_key_path}"; do 
      [[ -f ${file} ]] && run "mv ${file} ${file}.backup.${date}"
    done 
  fi

  run.set-next show-output-on
  run "ssh-keygen -t rsa -b 4096 -C ${email}"
}



