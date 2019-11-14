#!/usr/bin/env bash
# vi: ft=sh
lib::ruby::install-ruby-with-deps() {
  local version="$1"

  declare -a packages=(
    cask bash bash-completion git go haproxy htop jemalloc
    libxslt jq libiconv libzip netcat nginx  openssl pcre
    pstree p7zip rbenv redis ruby_build
    tree vim watch wget zlib
  )

  brew install --display-times ${packages[*]}
}

lib::ruby::install-ruby() {
  local version="$1"
  local version_source="provided as an argument"

  if [[ -z ${version} && -f .ruby-version ]] ; then
    version="$(cat .ruby-version | tr -d '\n')"
    version_source="auto-detected from .ruby-version file"
  fi 

  [[ -z ${version} ]] && {
    error "usage: ${BASH_SOURCE[*]} ruby-version" "Alternatively, create .ruby-version file"
    return 1
  }

  hl::subtle "Installing Ruby Version ${version} ${version_source}."

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

  # Ensure that we get the very latest ruby versions
  [[ -d ~/.rbenv/plugins/ruby-build ]] && { 
    run "cd ~/.rbenv/plugins/ruby-build && git reset --hard && git pull --rebase"
  }

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
ruby.install() {
  lib::ruby::install-ruby "$@"
}

ruby.linked-libs() {
  ruby -r rbconfig -e "puts RbConfig::CONFIG['LIBS']"
}

# ...ruby.compiled-with jemalloc && echo yes
ruby.compiled-with() {
  if [[ -z "$*" ]]; then
    error "usage: ruby.compiled-with <library>"
    return 1
  fi

  ruby -r rbconfig -e "puts RbConfig::CONFIG['LIBS']" | grep -q "$*"
}

ruby.stop() {
  local regex='/[r]uby| [p]uma| [i]rb| [r]ails | [b]undle| [u]nicorn| [r]ake'
  local procs=$(ps -ef | egrep "${regex}" | egrep -v grep | awk '{print $2}' | sort | uniq | wc -l)
  [[ ${procs} -eq 0 ]] && { 
    info: "No ruby processes were found."
    return 0
  }

  local -a pids=$(ps -ef | egrep "${regex}" | egrep -v grep | awk '{print $2}' | sort | uniq | tr '\n' ' -p ')

  h2 "Detected ${#pids[@]} Ruby Processes..., here is the tree:"
  printf "${txtcyn}"
  pstree ${pids[*]}
  printf "${clr}"
  hr

  printf "To abort, press Ctrl-C. To kill them all press any key.."
  press-any-key-to-continue
  
  ps -ef | egrep "${regex}" | egrep -v grep | awk '{print $2}' | sort | uniq | xargs kill -9 
}

