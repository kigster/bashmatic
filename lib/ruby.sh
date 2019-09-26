#!/usr/bin/env bash

lib::ruby::install-ruby() {
  local version="$1"

  [[ -z ${version} ]] && {
    [[ -f .ruby-version ]] && {
      hl::subtle "Auto-detected ruby version: ${version}"
      version="$(cat .ruby-version | tr -d '\n')"
    }
  }

  [[ -z ${version} ]] && {
    error "usage: ${BASH_SOURCE[*]} ruby-version"
    return 1
  }

  lib::ruby::validate-version "${version}" || return 1

  lib::brew::install::packages rbenv ruby-build jemalloc
  eval "$(rbenv init -)"

  run "RUBY_CONFIGURE_OPTS=--with-jemalloc rbenv install -s ${version}"
  return "${LibRun__LastExitCode:-"0"}"
}

lib::ruby::validate-version() {
  local version="$1"
  local -a ruby_versions=()

  run "brew upgrade ruby-build || true"
  lib::array::from-command-output ruby_versions 'rbenv install --list | sed -E "s/\s+//g"'

  lib::array::contains-element "${version}" "${ruby_versions[@]}" || {
    error "Ruby Version provided was found by rbenv: ${bldylw}${version}"
    return 1
  }

  return 0
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

# Public Interfaces
bashmatic.ruby.install() {
  lib::ruby::install-ruby "$@"
}

bashmatic.ruby.compiled-libs() {
  ruby -r rbconfig -e "puts RbConfig::CONFIG['LIBS']"
}

# ...ruby.compiled-with jemalloc && echo yes
bashmatic.ruby.compiled-with() {
  ruby -r rbconfig -e "puts RbConfig::CONFIG['LIBS']" | grep -q "$*"
}
