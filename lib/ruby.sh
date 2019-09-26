#!/usr/bin/env bash

lib::ruby::install-ruby() {
  local version="$1"

  [[ -z ${version} ]] && { 
    [[ -f .ruby-version ]] && version="$(cat .ruby-version | tr -d '\n')"
  }

  [[ -z ${version} ]] && { 
    error "usage: lib::ruby::install-ruby ruby-version"
    return 1
  }

  lib::brew::install::packages rbenv ruby-build jemalloc

  eval "$(rbenv init -)"

  run "RUBY_CONFIGURE_OPTS=--with-jemalloc rbenv install ${version}"
}

lib::ruby::gemfile-lock-version() {
  local gem=${1}

  if [[ ! -f Gemfile.lock ]]; then
    error "Can not find Gemfile.lock"
    return 1
  fi

  egrep " ${gem} \([0-9]" Gemfile.lock | sed -e 's/[\(\)]//g' | awk '{print $2}'
}

lib::ruby::bundler-version() {
  if [[ ! -f Gemfile.lock ]]; then
    error "Can not find Gemfile.lock"
    return 1
  fi
  tail -1 Gemfile.lock | hbsed 's/ //g'
}

lib::ruby::version() {
  ruby --version
}
