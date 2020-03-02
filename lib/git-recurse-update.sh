#!/usr/bin/env bash

export LibRepo__Interrupted=false
source "${BASH_SOURCE%/*}/color.sh"

lib::repo::rebase() {
  run "git pull origin master --rebase"
}

function lib::repo::stash-and-rebase() {
  run "git stash >/dev/null"
  run "git reset --hard"

  lib::repo::rebase
}

function lib::repo::update() {
  local folder="$1"

  h2 "Entering repo ► ${bldgren}${folder}"

  [[ -d "${folder}" ]] || return 1
  [[ -d "${folder}/.git" ]] || return 1

  [[ "$(pwd)" != "${folder}" ]] && {
    cd "${folder}" || return 2
  }

  if [[ -z "$(git status -s)" ]]; then
    lib::repo::rebase
  else
    lib::repo::stash-and-rebase
  fi
}

function lib::repos::recursive-update() {
  local repo="${1}"

  run::set-all show-output-off

  if [[ ${LibRepo__Interrupted} == true ]]; then
    warn "Detected SINGINT, exiting..."
    return 2
  fi

  if [[ -n "$repo" ]]; then
    lib::repo::update "$repo"
  else
    for dir in $(find . -type d -name '.git'); do
      local subdir=$(dirname "$dir")
      [[ -n "${DEBUG}" ]] && info "checking out sub-folder ${bldcyn}${subdir}..."
      lib::repos::recursive-update "${subdir}"
      if [[ $? -eq 2 ]]; then
        error "folder ${bldylw}${subdir}${bldred} return error!"
        return 2
      fi
    done
  fi

  if [[ -n ${repo} ]]; then
    info "returning to the root dir ${bldylw}${root_folder}..."
    cd "${root_folder}" >/dev/null || return 2
  fi
}

function repos.update() {
  export root_folder="$(pwd)"
  bash -c "
    [[ -d ~/.bashmatic ]] || {
      echo 'Can not find bashmatic installation sorry'
      return
    }
    source ~/.bashmatic/init.sh
    lib::repos::init-interrupt
    lib::repos::recursive-update '$*'
  "
}

function lib::repos::catch-interrupt() {
  export LibRepo__Interrupted=true
}

function lib::repos::init-interrupt() {
  export LibRepo__Interrupted=false
  trap 'lib::repos::catch-interrupt' SIGINT
}

function lib::repos::was-interrupted() {
  [[ ${LibRepo__Interrupted} == true ]]
}
