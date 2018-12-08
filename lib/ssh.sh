#!/usr/bin/env bash

lib::ssh::load-keys() {
  local pattern="$1"
  find ${HOME}/.ssh -type f -name "id_*${pattern}*" -and -not -name '*.pub' -print -exec ssh-add {} \; 
}


