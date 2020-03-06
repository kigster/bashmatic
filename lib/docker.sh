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

__lib::docker::exec() {
  local cmd="$*"
  export LibRun__ShowCommandOutput=${True}
  export LibRun__AbortOnError=${True}
  run "${cmd}"
  echo
}

__lib::docker::last-version() {
  __lib::docker::check-repo "${1}" || return 1

  local versions="$(docker images "${AppDockerRepo}" | egrep -v 'TAG|latest|none' | awk '{print $2}')"

  local max=0
  for v in ${versions}; do
    vi=$(lib::util::ver-to-i "${v}")
    [[ ${vi} -gt ${max} ]] && max=${vi}
  done

  lib::util::i-to-ver "${max}"
}

__lib::docker::next-version() {
  __lib::docker::check-repo "${1}" || return 1

  local version
  version="$(lib::docker::last-version "${AppDockerRepo}")"

  local vi=$(($(lib::util::ver-to-i "${version}") + 1))
  printf "%s" "$(lib::util::i-to-ver "${vi}")"
}

__lib::docker::check-repo() {
  local repo="$1"

  if [[ -z "${AppDockerRepo}" ]]; then
    if [[ -n "${repo}" ]]; then
      lib::docker::set-repo "${repo}"
      return
    else
      error "AppDockerRepo is not set. Please call lib::docker::set-repo <repo-name> to set."
      info "eg. lib::docker::set-repo reinvent-one/ruby:2.7"
      return 1
    fi
  elif [[ "${AppDockerRepo}" != "${repo}" && -n "${repo}" ]]; then
    lib::docker::set-repo "${repo}"
  fi

  return 0
}
#===============================================================================
# Public Functions
#===============================================================================
lib::docker::set-repo() {
  [[ -n "$1" ]] && export AppDockerRepo="$1"
}

lib::docker::last-version() {
  __lib::docker::check-repo "${1}" || return 1

  [[ -z ${AppDockerRepo} ]] && {
    error "usage: lib::docker::last-version organization/reponame:version"
    return 1
  }
  __lib::docker::last-version "$@"
}

lib::docker::next-version() {
  __lib::docker::check-repo "${1}" || return 1

  [[ -z ${AppDockerRepo} ]] && {
    error "usage: lib::docker::next-version [ organization/repo-name:version ]"
    return 1
  }
  __lib::docker::next-version "$@"
}

lib::docker::build::container() {
  __lib::docker::check-repo "${1}" || return 1
  local tag=${AppDockerRepo}
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
  __lib::docker::check-repo "${2}" || return 1
  __lib::docker::exec "docker pull ${AppDockerRepo}:${tag}"
}

lib::docker::actions::tag() {
  local tag=${1}
  [[ -z ${tag} ]] && return 1
  __lib::docker::check-repo "${2}" || return 1
  __lib::docker::exec docker tag "${AppDockerRepo}" "${AppDockerRepo}:${tag}"
}

# Usage:
#  - lib::docker::actions::push  (auto-increments the version, and pushes it + latest
#  - lib::docker::actions::push 1.1.0  # manually supply version, and push it; also set latest to this version.

lib::docker::actions::push() {
  local tag=${1:-$(__lib::docker::next-version)}
  __lib::docker::check-repo "${2}" || return 1

  lib::docker::actions::tag latest
  [[ -n ${tag} ]] && lib::docker::actions::tag "${tag}"

  __lib::docker::check-repo || return 1
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

lib::docker::abort-if-down() {
  local should_exit="${1:-true}"

  inf 'Checking if Docker is running...'
  docker ps 2>/dev/null 1>/dev/null
  code=$?

  if [[ ${code} == 0 ]]; then
    ok:
  else
    not_ok:
    error "docker ps returned ${code}, is Docker running?"
    [[ "${should_exit}" == "true" ]] && exit 127
    return 127
  fi
}

lib::docker::images-named() {
  local name="${1}"
  local func="${2}"

  lib::docker::abort-if-down false || return 127

  hl::subtle "Processing Docker images matching ${name} with function ${func}..."

  local images="$(docker images | grep "^${name}" | sed 's/  */ /g' | cut -d ' ' -f 3 | tr '\n' ' ')"
  ${func} ${images}
}

# Removes stopped containers. Pass "-f" as argument to force.
lib::docker::containers::clean() {
  local -a args=("$@")
  run "docker rm $(docker ps -q -a) ${args[*]}"
}

# Removes image passed as an argument
lib::docker::image::rm() {
  run "docker image rm ${*}"
}

# Inspect image
lib::docker::image::inspect() {
  run::set-next show-output-on

  local jq=" | jq"
  [[ -z $(command -v jq) ]] && jq=

  run "docker image inspect ${*} $jq"
}

# Removes images that are unused and have no label or tag attached
lib::docker::images::clean() {
  local name=${1:-"<none>"}
  lib::docker::images-named "${name}" "lib::docker::image::rm"
}

# Removes images that are unused and have no label or tag attached
lib::docker::images::inspect() {
  local name=${1:-"<none>"}
  lib::docker::images-named "${name}" "lib::docker::image::inspect"
}

