#!/usr/bin/env bash

# @file Bashmatic Utilities and aliases for Git revision control system.
# @brief Lots of useful utilities and helpers.

git.configure-auto-updates() {
  # You can set this variable in the outer scope to override how frequently would bashmatic self-upgrade.
  export LibGit__StaleAfterThisManyHours="${LibGit__StaleAfterThisManyHours:-"1"}"
  export LibGit__LastUpdateTimestampFile="/tmp/.bashmatic/.config/$(echo ${USER} | util.checksum.stdin)"
  mkdir -p $(dirname ${LibGit__LastUpdateTimestampFile})
}

git.quiet() {
  [[ -n ${LibGit__QuietUpdate} ]]
}

git.sync() {
  local dir="$(pwd)"
  cd "${BASHMATIC_HOME}" >/dev/null
  git.repo-is-clean || {
    output.is-ssh || warning "${bldylw}${BASHMATIC_HOME} has locally modified files." \
      "Please commit or stash them to allow auto-upgrade to function as designed." >&2
    cd "${dir}" >/dev/null
    return 1
  }

  git.update-repo-if-needed
  cd "${dir}" >/dev/null
  return 0
}

git.sync-dirs() {
  local pattern="${1:-'*'}"
  set -e
  run.set-all abort-on-error
  for dir in $(find . -type d -depth 1 -name "${pattern}*"); do
    hl.yellow-on-gray "syncing [$dir]..."
    cd $dir>/dev/null
    run "git pull --rebase"
    cd ->/dev/null
  done
}


git.last-update-at() {
  git.configure-auto-updates

  local file="${1:-"${LibGit__LastUpdateTimestampFile}"}"
  local last_update=0
  [[ -f ${file} ]] && last_update="$(cat $file | tr -d '\n')"
  printf "%d" ${last_update}
}

git.seconds-since-last-pull() {
  local last_update="$1"
  local now=$(epoch)
  printf $((now - last_update))
}

git.update-repo-if-needed() {
  local last_update_at=$(git.last-update-at)
  local second_since_update=$(git.seconds-since-last-pull ${last_update_at})
  local update_period_seconds=$((LibGit__StaleAfterThisManyHours * 60 * 60))
  if [[ ${second_since_update} -gt ${update_period_seconds} ]]; then
    git.sync-remote
  elif [[ -n ${DEBUG} ]]; then
    git.quiet || info "${BASHMATIC_HOME} will update in $((update_period_seconds - second_since_update)) seconds..."
  fi
}

git.save-last-update-at() {
  echo $(epoch) >${LibGit__LastUpdateTimestampFile}
}

git.sync-remote() {
  if git.quiet; then
    (git remote update && git fetch) 2>&1 >/dev/null
  else
    run "git remote update && git fetch"
  fi

  local status=$(git.local-vs-remote)

  if [[ ${status} == "behind" ]]; then
    git.quiet || run "git pull --rebase"
    git.quiet && git pull --rebase 2>&1 >/dev/null
  elif [[ ${status} != "ahead" ]]; then
    git.save-last-update-at
  elif [[ ${status} != "ok" ]]; then
    error "Report $(pwd) is ${status} compared to the remote." \
      "Please fix manually to continue."
    return 1
  fi
  git.save-last-update-at
  return 0
}

git.local-vs-remote() {
  local upstream=${1:-'@{u}'}
  local local_repo=$(git rev-parse @)
  local remote_repo=$(git rev-parse "$upstream")
  local base=$(git merge-base @ "$upstream")

  if [[ -n ${DEBUG} ]]; then
    printf "
      pwd         = $(pwd)
      remote      = $(git.remotes)
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

git.repo-is-clean() {
  local repo="${1:-${BASHMATIC_HOME}}"
  cd "${repo}" >/dev/null
  if [[ -z $(git status -s) ]]; then
    cd - >/dev/null
    return 0
  else
    cd - >/dev/null
    return 1
  fi
}

git.remotes() {
  git remote -v | awk '{print $2}' | uniq
}

bashmatic.auto-update() {
  [[ ${Bashmatic__Test} -eq 1 ]] && return 0

  git.configure-auto-updates

  git.repo-is-clean || {
    output.is-ssh || {
      h1 "${BASHMATIC_HOME} has locally modified changes." \
        "Will wait with auto-update until it's sync'd up."
    }
    return 1
  }

  git.sync
}

git.commits.last.sha() {
  git log --pretty=format:"%H" -1
}

git.commits.last.message() {
  git log --pretty=format:"%s" -1
}

git.branch.current() {
  git rev-parse --abbrev-ref HEAD
}

# @description Reads the remote of a repo by name provided as
#   an argument (or defaults to "origin") and opens it in the browser.
#
# @example
#   git clone git@github.com:kigster/bashmatic.git
#   cd bashmatic
#   source init.sh
#   git.open
#   git.open origin # same thing
#
# @arg $1 optional name of the remote to open, defaults to "orogin"
#
git.open() {
  local remote="${1:-"origin"}"
  local url=$(git remote get-url origin | sed -E 's/git@/https:\/\//g;s/com:/com\//g')
  info "Opening URL ${bldylw}${url}"
  open -a 'Google Chrome' ${url}
}
