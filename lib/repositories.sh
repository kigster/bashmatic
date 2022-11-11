#!/usr/bin/env bash

export LibRepo__Interrupted=false
source "${BASHMATIC_HOME}/lib/color.sh"

repo.rebase() {
  run "git pull origin main --rebase"
}

repo.stash-and-rebase() {
  run "git stash >/dev/null"
  run "git reset --hard"

  repo.rebase
}

repo.update() {
  local folder="$1"

  h2 "Entering repo ► ${bldgren}${folder}"

  [[ -d "${folder}" ]] || return 1
  [[ -d "${folder}/.git" ]] || return 1

  [[ "$(pwd)" != "${folder}" ]] && {
    cd "${folder}" || return 2
  }

  if [[ -z "$(git status -s)" ]]; then
    repo.rebase
  else
    repo.stash-and-rebase
  fi
}

repos.recursive-update() {
  local repo="${1}"

  run.set-all show-output-off

  if [[ ${LibRepo__Interrupted} == true ]]; then
    warn "Detected SINGINT, exiting..."
    return 2
  fi

  if [[ -n "$repo" ]]; then
    repo.update "$repo"
  else
    for dir in $(find . -type d -name '.git'); do
      local subdir=$(dirname "$dir")
      [[ -n "${BASHMATIC_DEBUG}" ]] && info "checking out sub-folder ${bldcyn}${subdir}..."
      repos.recursive-update "${subdir}"
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

repos.update() {
  export root_folder="$(pwd)"
  bash -c "
    [[ -d ${BASHMATIC_HOME} ]] || {
      echo 'Can not find bashmatic installation sorry'
      return
    }
    source ${BASHMATIC_HOME}/init.sh
    repos.init-interrupt
    repos.recursive-update '$*'
  "
}

repos.catch-interrupt() {
  export LibRepo__Interrupted=true
}

repos.init-interrupt() {
  export LibRepo__Interrupted=false
  trap 'repos.catch-interrupt' SIGINT
}

repos.was-interrupted() {
  [[ ${LibRepo__Interrupted} == true ]]
}


