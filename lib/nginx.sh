#!/usr/bin/env bash
# -*- coding: utf-8 -*-
function nginx.csr.create() {
  if [[ -z  "$*" ]]; then
    info "USAGE: ${bldylw}nginx.csr.create domain [ domain2 [ domain ] ]"
    return 0
  fi
  for domain in "$@"; do
    run "openssl req -new -newkey rsa:4096 -nodes -keyout $domain.key -out $domain.csr"
  done 
}
