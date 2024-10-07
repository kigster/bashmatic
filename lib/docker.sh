#!/usr/bin/env bash
#
#———————————————————————————————————————————————————————————————————————————————
# © 2016-2024 Konstantin Gredeskoul, All rights reserved. MIT License.
# © 2016-2024 Konstantin Gredeskoul, All rights reserved. MIT License.
#
# In this library we "document in code" our agreements about running docker.
# We express basic Docker compose commands as library functions that
# "memorize" the frequently used flags and other options, so that we dont' have
# to think about it.
#———————————————————————————————————————————————————————————————————————————————

#===============================================================================
# Private Functions
#===============================================================================

.docker.exec() {
  local cmd="$*"
  export LibRun__ShowCommandOutput=${True}
  export LibRun__AbortOnError=${True}
  run "${cmd}"
  echo
}

.docker.last-version() {
  .docker.check-repo "${1}" || return 1

  local versions="$(docker images "${AppDockerRepo}" | ${GrepCommand} -v 'TAG|latest|none' | awk '{print $2}')"

  local max=0
  for v in ${versions}; do
    vi=$(util.ver-to-i "${v}")
    [[ ${vi} -gt ${max} ]] && max=${vi}
  done

  util.i-to-ver "${max}"
}

.docker.next-version() {
  .docker.check-repo "${1}" || return 1

  local version
  version="$(docker.last-version "${AppDockerRepo}")"

  local vi=$(($(util.ver-to-i "${version}") + 1))
  printf "%s" "$(util.i-to-ver "${vi}")"
}

.docker.check-repo() {
  local repo="$1"

  if [[ -z "${AppDockerRepo}" ]]; then
    if [[ -n "${repo}" ]]; then
      docker.set-repo "${repo}"
      return
    else
      error "AppDockerRepo is not set. Please call docker.set-repo <repo-name> to set."
      info "eg. docker.set-repo reinvent-one/ruby:2.7"
      return 1
    fi
  elif [[ "${AppDockerRepo}" != "${repo}" && -n "${repo}" ]]; then
    docker.set-repo "${repo}"
  fi

  return 0
}
#===============================================================================
# Public Functions
#===============================================================================
docker.set-repo() {
  [[ -n "$1" ]] && export AppDockerRepo="$1"
}

docker.last-version() {
  .docker.check-repo "${1}" || return 1

  [[ -z ${AppDockerRepo} ]] && {
    error "usage: docker.last-version organization/reponame:version"
    return 1
  }
  .docker.last-version "$@"
}

docker.next-version() {
  .docker.check-repo "${1}" || return 1

  [[ -z ${AppDockerRepo} ]] && {
    error "usage: docker.next-version [ organization/repo-name:version ]"
    return 1
  }
  .docker.next-version "$@"
}

docker.build.container() {
  .docker.check-repo "${1}" || return 1
  local tag=${AppDockerRepo}
  .docker.exec "docker build -m 3G -c 4 --pull -t ${tag} . $*"
}

# Docker Actions
docker.actions.build() {
  docker.build.container "$@"
}

docker.actions.clean() {
  .docker.exec "docker-compose rm"
}

docker.actions.up() {
  .docker.exec "docker-compose up"
}

docker.actions.start() {
  .docker.exec "docker-compose start"
}

docker.actions.stop() {
  .docker.exec "docker-compose stop"
}

docker.actions.pull() {
  local tag=${1:-'latest'}
  .docker.check-repo "${2}" || return 1
  .docker.exec "docker pull ${AppDockerRepo}:${tag}"
}

docker.actions.tag() {
  local tag=${1}
  [[ -z ${tag} ]] && return 1
  .docker.check-repo "${2}" || return 1
  .docker.exec docker tag "${AppDockerRepo}" "${AppDockerRepo}:${tag}"
}

# Usage:
#  - docker.actions.push  (auto-increments the version, and pushes it + latest
#  - docker.actions.push 1.1.0  # manually supply version, and push it; also set latest to this version.

docker.actions.push() {
  local tag=${1:-$(.docker.next-version)}
  .docker.check-repo "${2}" || return 1

  docker.actions.tag latest
  [[ -n ${tag} ]] && docker.actions.tag "${tag}"

  .docker.check-repo || return 1
  .docker.exec docker push "${AppDockerRepo}:${tag}"

  [[ ${tag} != 'latest' ]] && .docker.exec docker push "${AppDockerRepo}:latest"
}

#———————————————————————————————————————————————————————————————————————————————
# Composite Commands
#———————————————————————————————————————————————————————————————————————————————

docker.actions.setup() {
  setup.docker
  docker.pull
  docker.build
}

docker.actions.update() {
  docker.build
  docker.push
}

docker.abort-if-down() {
  local should_exit="${1:-true}"

  inf 'Checking if Docker is running...'
  docker ps 2>/dev/null 1>/dev/null
  code=$?

  if [[ ${code} == 0 ]]; then
    ui.closer.ok:
  else
    ui.closer.not-ok:
    error "docker ps returned ${code}, is Docker running?"
    [[ "${should_exit}" == "true" ]] && exit 127
    return 127
  fi
}

docker.images-named() {
  local name="${1}"
  local func="${2}"

  docker.abort-if-down false || return 127

  hl.subtle "Processing Docker images matching ${name} with function ${func}..."

  local images="$(docker images | grep "^${name}" | sed 's/  */ /g' | cut -d ' ' -f 3 | tr '\n' ' ')"
  ${func} "${images}"
}

# Removes stopped containers. Pass "-f" as argument to force.
docker.containers.clean() {
  local -a args=("$@")
  run "docker rm $(docker ps -q -a) ${args[*]}"
}

# Removes image passed as an argument
docker.image.rm() {
  run "docker image rm ${*}"
}

# Inspect image
docker.image.inspect() {
  run.set-next show-output-on

  local jq=" | jq"
  [[ -z $(command -v jq) ]] && jq=

  run "docker image inspect ${*} $jq"
}

# Removes images that are unused and have no label or tag attached
docker.images.clean() {
  local name=${1:-"<none>"}
  docker.images-named "${name}" "docker.image.rm"
}

# Removes images that are unused and have no label or tag attached
docker.images.inspect() {
  local name=${1:-"<none>"}
  docker.images-named "${name}" "docker.image.inspect"
}


