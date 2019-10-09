#!/usr/bin/env bash

# You can set this variable in the outer scope to override how frequently would bashmatic self-upgrade.
export LibGit__StaleAfterThisManyHours="${LibGit__StaleAfterThisManyHours:-"1"}"
export LibGit__LastUpdateTimestampFile="/tmp/.bashmatic/.config/$(echo ${USER} | lib::util::checksum::stdin)"
export LibGit__QuietUpdate=${LibGit__QuietUpdate:-''}

function lib::git::quiet() {
  [[ -n ${LibGit__QuietUpdate} ]]
}

function lib::git::sync() {
  local dir=${PWD}
  cd ${BashMatic__Home}
  lib::git::repo-is-clean || {
    error "${bldylw}${BashMatic__Home} has locally modified files." \
          "Please commit or stash them to allow auto-upgrade to function as designed."

    git status -s
    cd ${dir} > /dev/null
    return 1
  }

  mkdir -p $(dirname ${LibGit__LastUpdateTimestampFile})
  lib::git::check-if-should-update-repo
  cd ${dir} > /dev/null

  return 0
}

function lib::git::last-update-at {
  local file="${1:-"${LibGit__LastUpdateTimestampFile}"}"
  local last_update=0
  if [[ -f ${file} ]] ; then
    last_update=$(cat $file | tr -d '\n')
  fi
  printf "%d" ${last_update}
}

function lib::git::seconds-since-last-pull() {
  local last_update="$1"
  local now=$(epoch)
  printf $(( now - last_update ))
}

function lib::git::check-if-should-update-repo() {
  local last_update_at=$(lib::git::last-update-at)
  local second_since_update=$(lib::git::seconds-since-last-pull ${last_update_at})
  local update_period_seconds=$(( LibGit__StaleAfterThisManyHours * 60 * 60 ))
  if [[ ${second_since_update} -gt ${update_period_seconds} ]]; then
    [[ ${last_update_at} -gt 0 ]] && {
      lib::git::quiet || hl::blue "BASH Library may be out of date (last updated: $(lib::time::epoch-to-local ${last_update_at})"
    }
    lib::git::sync-remote
  elif [[ -n ${DEBUG} ]]; then
    lib::git::quiet || info "${BashMatic__Home} will update in $(( update_period_seconds - second_since_update )) seconds..."
  fi
}

function lib::git::sync-remote() {
  if lib::git::quiet; then
    ( git remote update && git fetch ) 2>&1 >/dev/null
  else
     run "git remote update && git fetch"
  fi

  local status=$(lib::git::local-vs-remote)

  if [[ ${status} == "behind" ]]; then
    lib::git::quiet || run "git pull --rebase"
    lib::git::quiet && git pull --rebase 2>&1 > /dev/null
  elif [[ ${status} != "ok" ]]; then
    error "Report $(pwd) is ${status} compared to the remote." \
            "Please fix manually to continue."
    return 1
  fi

  echo $(epoch) > ${LibGit__LastUpdateTimestampFile}
  return 0
}

function lib::git::local-vs-remote() {
  local upstream=${1:-'@{u}'}
  local local_repo=$(git rev-parse @)
  local remote_repo=$(git rev-parse "$upstream")
  local base=$(git merge-base @ "$upstream")

  if [[ -n ${DEBUG} ]]; then
    printf "
      pwd         = $(pwd)
      remote      = $(lib::git::remotes)
      base        = ${base}
      upstream    = ${upstream}
      local_repo  = ${local_repo}
      remote_repo = ${remote_repo}
    "
  fi

  local result=
  if [[ "${local_repo}" == "${remote_repo}" ]]; then
    result="ok"
  elif [[ "${local_repo}" == "${base}" ]]; then
    result="behind"
  elif [[ "${remote_repo}" == "${base}" ]]; then
    result="ahead"
  else
    result="diverged"
  fi

  printf '%s' ${result}
  [[ ${result} == "ok" ]] && return 0
  return 1
}

lib::git::repo-is-clean() {
  [[ -z $(git status -s) ]]
}

lib::git::remotes() {
  git remote -v | awk '{print $2}' | uniq
}
