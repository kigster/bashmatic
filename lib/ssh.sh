#!/usr/bin/env bash

ssh.load-keys() {
  local pattern="$1"
  find ${HOME}/.ssh -type f -name "id_*${pattern}*" -and -not -name '*.pub' -print -exec ssh-add {} \;
}

ssh.keys.generate() {
  local email="$(user.gitconfig.email)"
  [[ -z ${email} ]] && {
    info "Couldnt' get your email from ~/.gitconfig..."
    run.ui.ask-user-value email "What's the email you'd like to use with this key?"
  }

  local date=$( time.now.db )
  if [[ -f ~/.ssh/id_rsa ]]; then
    warning "There is an existing file ${bldred}~/.ssh/id_rsa"
    info "It will be backed up into ~/.ssh/id_rsa.bak.${date}"
    for file in ~/.ssh/id_rsa ~/.ssh/id_rsa.pub; do 
      [[ -f ${file} ]] && run "mv ${file} ${file}.bak.${date}"
    done 
  fi

  run.set-next show-output-on
  run "ssh-keygen -t rsa -b 4096 -C ${email}"
}
