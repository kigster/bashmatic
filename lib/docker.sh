#!/usr/bin/env bash
#
#———————————————————————————————————————————————————————————————————————————————
# © 2016 — 2017 Author: Konstantin Gredeskoul
# © 2017 Konstantin Gredeskoul, Inc. All rights reserved.
#
# In this library we "document in code" our agreements about running docker.
# We express basic Docker compose commands as library functions that
# "memorize" the frequently used flags and other options, so that we dont' have
# to think about it.
#———————————————————————————————————————————————————————————————————————————————

#===============================================================================
# Private Functions
#===============================================================================

__lib::docker::output-colors() {
  printf "${bldblu}"
  printf "${txtpur}" >&2
}

__lib::docker::reset-colors() {
  reset-color:
  reset-color: >&2
}

__lib::docker::exec() {
  local cmd="$*"
  export LibRun__ShowCommandOutput=${True}
  export LibRun__AbortOnError=${True}
  run "${cmd}"
  echo
}

__lib::docker::last-version() {
  local repo=${1:-${AppDockerRepo}}
  local versions=$(docker images ${repo} | egrep -v 'TAG|latest|none' | awk '{print $2}')

  local max=0
  for v in ${versions}; do
    vi=$(lib::util::ver-to-i ${v})
    [[ ${vi} -gt ${max} ]] && max=${vi}
  done

  lib::util::i-to-ver ${max}
}

__lib::docker::next-version() {
  local repo=${1:-${AppDockerRepo}}
  local version=$(lib::docker::last-version ${repo})
  local vi=$(( $(lib::util::ver-to-i ${version}) + 1 ))
  printf $(lib::util::i-to-ver ${vi})
}


#===============================================================================
# Public Functions
#===============================================================================
lib::docker::last-version() {
  local repo=$1
  [[ -z ${repo} ]] && {
    error "usage: lib::docker::last-version organization/reponame"
    return 1
  }
  __lib::docker::last-version "$@"
}

lib::docker::next-version() {
  local repo=$1
  [[ -z ${repo} ]] && {
    error "usage: lib::docker::next-version organization/reponame"
    return 1
  }
  __lib::docker::next-version "$@"
}

lib::docker::build::container() {
  local tag=${AppDockerRepo:-"local/container"}
  __lib::docker::exec "docker build -m 3G -c 4 --pull -t ${tag} . $*"
}

# Docker Actions
lib::docker::actions::build() {
  lib::docker::build::container "$@"
}

lib::docker::actions::clean() {
  __lib::docker::exec "docker-compose rm"
}

lib::docker::actions::up() {
  __lib::docker::exec "docker-compose up"
}

lib::docker::actions::start() {
  __lib::docker::exec "docker-compose start"
}

lib::docker::actions::stop() {
  __lib::docker::exec "docker-compose stop"
}

lib::docker::actions::pull() {
  local tag=${1:-'latest'}
  __lib::docker::exec "docker pull ${AppDockerRepo}:${tag}"
}

lib::docker::actions::tag() {
  local tag=${1}
  [[ -z ${tag} ]] && return
  __lib::docker::exec docker tag ${AppDockerRepo} "${AppDockerRepo}:${tag}"
}

# Usage:
#  - lib::docker::actions::push  (auto-increments the version, and pushes it + latest
#  - lib::docker::actions::push 1.1.0  # manually supply version, and push it; also set latest to this version.

lib::docker::actions::push() {
  local tag=${1:-$(__lib::docker::next-version)}

  lib::docker::actions::tag latest
  [[ -n ${tag} ]] && lib::docker::actions::tag ${tag}
  __lib::docker::exec docker push "${AppDockerRepo}:${tag}"

  [[ ${tag} != 'latest' ]] && __lib::docker::exec docker push "${AppDockerRepo}:latest"
}

#———————————————————————————————————————————————————————————————————————————————
# Composite Commands
#———————————————————————————————————————————————————————————————————————————————

lib::docker::actions::setup() {
  lib::setup::docker
  lib::docker::pull
  lib::docker::build
}

lib::docker::actions::update() {
  lib::docker::build
  lib::docker::push
}

lib::docker::abort_if_down() {
  inf 'Checking if Docker is running...'
  docker ps 2>/dev/null 1>/dev/null
  code=$?

  if [[ ${code} == 0 ]]; then
    ok:
  else
    not_ok:
    error "docker ps returned ${code}, is Docker running?"
    exit 127
  fi
}
