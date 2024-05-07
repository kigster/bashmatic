#!/usr/bin/env bash
# @brief Functions in this file manage git repos, including this one.

function git.repo.latest-remote-tag() {
  local repo_url="$1"
  git ls-remote --tags --sort="v:refname" "${repo_url}" | grep -E \-v '(latest|stable)' | grep -E -v '\^{}'| tail -1 | awk 'BEGIN{FS="/"}{print $3}'
}

function git.repo.latest-local-tag() {
  git tag -l | sort | tail -1
}

function git.repo.next-local-tag() {
  local tag=$(git.repo.latest-local-tag)
  [[ -z ${tag} ]] && tag="0.0.0"
  ruby -e "prefix='${tag}'.gsub(/^([^\d]+).*/, '\1'); version='${tag}'.gsub(/[^\d.]/, '').split(/\./).map(&:to_i); version[2]+=1; puts \"#{prefix}#{version.join('.')}\""
}

function git.configure-auto-updates() {
  export LibGit__StaleAfterThisManyHours="${LibGit__StaleAfterThisManyHours:-"1"}"
  export LibGit__LastUpdateTimestampFile="${BASHMATIC_TEMP}/.config/$(echo "${USER}" | shasum.sha-only-stdin)"
  mkdir -p "$(dirname "${LibGit__LastUpdateTimestampFile}")"
}

# @description Sets or gets user values from global gitconfig.
# @example Print current user's email
#     git.cfgu email
#
# @example Set currrent email
#     git.cfgu email kigster@gmail.com
#
# @example Print all global values
#     git.cfgu
function git.cfgu() {
  [[ -z $1 ]] && {
    git config --global -l
    return
  }
  if [[ -n $2 ]]; then
    rm -f ~/.gitconfig.lock
    git config --global --replace-all user."$1" "$2"
  else
    if [[ $1 =~ - ]]; then
      git config --global "$1"
    else
      git config --global user."$1"
    fi
  fi
}

# used in tests
function git.config.kigster() {
  [[ $(git.cfgu name) == "Konstantin Gredeskoul" && \
  $(git.cfgu email) == "kigster@gmail.com" ]] && return 0

  git.cfgu name "Konstantin Gredeskoul"
  git.cfgu email "kigster@gmail.com"
}

function git.quiet() {
  [[ -n ${LibGit__QuietUpdate} ]]
}

function git.sync() {
  local dir="$(pwd -P)"
  cd "${BASHMATIC_HOME}" >/dev/null
  git.repo-is-clean || {
    output.is-ssh || warning "${BASHMATIC_HOME} has locally modified files." \
      "Please commit or stash them to allow auto-upgrade to function as designed." >&2
    cd "${dir}" >/dev/null
    return 1
  }

  if is-debug; then
    git.update-repo-if-needed
  else
    git.update-repo-if-needed >&2 1>/dev/null
  fi

  cd "${dir}" >/dev/null
  return 0
}

function git.sync-dirs() {
  local pattern="${1:-'*'}"
  set -e
  run.set-all abort-on-error
  for dir in $(find . -type d -maxdepth 1 -name "${pattern}*"); do
    hl.yellow-on-gray "syncing [$dir]..."
    cd "$dir" >/dev/null
    run "git pull --rebase"
    cd - >/dev/null
  done
}

function git.last-update-at() {
  git.configure-auto-updates

  local file="${1:-"${LibGit__LastUpdateTimestampFile}"}"
  local last_update=0
  if [[ ${LibGit__ForceUpdate} -eq 0 && -f ${file} ]]; then
    last_update="$(cat "$file" | tr -d '\n')"
  else
    last_update=0
  fi
  printf "%d" ${last_update}
}

function git.seconds-since-last-pull() {
  local last_update="$1"
  local now=$(epoch)
  printf $((now - last_update))
}

function git.is-it-time-to-update() {
  local last_update_at=$(git.last-update-at)
  local second_since_update=$(git.seconds-since-last-pull "${last_update_at}")
  local update_period_seconds=$((LibGit__StaleAfterThisManyHours * 60 * 60))
  [[ ${second_since_update} -gt ${update_period_seconds} ]]
}

function git.update-repo-if-needed() {
  git.is-it-time-to-update && git.sync-remote
}

function git.save-last-update-at() {
  echo $(epoch) >"${LibGit__LastUpdateTimestampFile}"
}

function git.sync-remote() {
  git.is-it-time-to-update || return 0

  if git.quiet; then
    (git remote update && git fetch) 2>&1 >/dev/null
  else
    run "git remote update && git fetch"
  fi

  local git_status="$(git.local-vs-remote)"

  if [[ ${git_status} == "behind" ]]; then
    git.quiet || run "git pull --rebase"
    git.quiet && git pull --rebase 2>&1 >/dev/null
  elif [[ ${git_status} != "ahead" ]]; then
    git.save-last-update-at
  elif [[ ${git_status} != "ok" ]]; then
    error "Report $(pwd) is ${status} compared to the remote." \
      "Please fix manually to continue."
    return 1
  fi
  git.save-last-update-at
  return 0
}

# shellcheck disable=2120
function git.local-vs-remote() {
  local upstream=${1:-'@{u}'}
  local local_repo=$(git rev-parse @)
  local remote_repo=$(git rev-parse "$upstream")
  local base=$(git merge-base @ "$upstream")

  if [[ -n ${BASHMATIC_DEBUG} ]]; then
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

# shellcheck disable=2120
function git.repo-is-clean() {
  local repo="${1:-${BASHMATIC_HOME:="${HOME}/.bashmatic"}}"
  cd "${repo}" >/dev/null
  if [[ -z $(git status -s) ]]; then
    cd - >/dev/null
    return 0
  else
    cd - >/dev/null
    return 1
  fi
}

function git.remotes() {
  git remote -v | awk '{print $2}' | uniq
}

function git.remote() {
  if git.remotes | grep -q "git@"; then
    git.remotes | egrep "git@" | sort | head -1
  else
    git.remotes | sort | head -1
  fi
}

function git.commits.last.sha() {
  git log --pretty=format:"%H" -1
}

function git.commits.last.message() {
  git log --pretty=format:"%s" -1
}

function git.branch.current() {
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
function git.repo() {
  local url=$(git remote get-url origin | sed -E 's/git@/https:\/\//g;s/com:/com\//g')
  printf -- "%s" "${url}"
}

# @description Returns a URL on Github website that points to the
# .  README on the current branch.
function git.repo.current() {
  local url="$(git.repo)"
  local current_branch="$(git.branch.current)"
  local readme="README.md"
  for file in README.md README README.txt README.adoc CHANGELOG.md; do
    if [[ -s "${file}" ]] ; then
      export readme="${file}"
      break
    fi
  done
  # blob/kig/obfuscated-vars/README.adoc
  local full_url="${url}/blob/${current_branch}/${readme}"
  printf -- "%s" "${full_url}"
}

function git.open.current() {
  local url=$(git.repo.current)
  info "git.open() -> ${bldylw}${url}"
  open -a 'Google Chrome' "${url}"
}

function git.open.repo() {
  local url=$(git.repo)
  info "git.open.repo() -> ${bldylw}${url}"
  open -a 'Google Chrome' "${url}"
}

# Convert a local git remote URL from https:// ... to git@ format.
function git.repo.remote-to-git@() {
  local f=".git/config"
  if [[ -f "$f" ]]; then
    grep -q "url = git@" "$f" && {
      info "The repo is already using git@ syntax for the remote."
      return 0
    }
    cat "${f}" | sed -E 's#url = https://github\.com/([^/]*)/#url = git@github\.com:\1/#g' >"${f}.ssh"
    mv "${f}" "${f}.https"
    cd .git
    ln -nfs config.ssh config
    cd - >/dev/null
    hr
    info "Created an ssh version of .git/config file, and symlinked it:"
    ls -l .git/config*
    info "Your new remote:"
    info $(grep "git@" "${f}")
    hr
  fi
}

function git.squash() {
  local number="${1}"
  is.numeric "${number}" || {
    info "USAGE: git.squash <number> # of commits to go back"
    return
  }
  run "git reset --soft HEAD~${number}"

  info "We've squashed down ${number} commits locally."
  info "Now, you must commit this squash, and likely force push."
}

function git.current-branch() {
  git branch --no-color | grep -F "*" | cut -f 2 -d " "
}

function git.upstream() {
  local this_branch=$(git.current-branch)
  this_branch=${this_branch:-main}
  run.set-next show-output-on
  run "git branch --set-upstream-to=origin/${this_branch} ${this_branch}"
}

# @description Given a git URL splits it into 5 array elements:
#    protocol, separator, hostname, user, repo
# @example
#    declare -a remote_elements
#    export remote_elements=($(git.remote))
#

function git.parse-remote() {
  local url="${1:-$(git.remote)}"
  local re="^(https|git)(:\/\/|@)([^\/:]+)[\/:]([^\/:]+)\/(.+)(\.git)?$"

  [[ $url =~ $re ]] || {
    error "git remote [${url}] does not match regualar expression." >&2
    return 1
  }

  local protocol="${BASH_REMATCH[1]}"
  local separator="${BASH_REMATCH[2]}"
  local hostname="${BASH_REMATCH[3]}"
  local user="${BASH_REMATCH[4]}"
  local repo="${BASH_REMATCH[5]}"

  printf "%s %s %s %s %s\n" "${protocol}" "${separator}" "${hostname}" "${user}" "${repo}"
}

function git.is-valid-repo() {
  if [[ ! -d .git ]] ; then
    error "Please run this script at the root of your project / git repo." >&2
    return 1
  fi
}

# @description Prints the value from github config
# @arg1 [ local | global ] which config to look at (defaults to global)
# @arg2... tokens to print 
# @example
#   git.cfg.get github.token user.name user.email
# dsf09098f09ds8f0s98df09809
# John Doe
# jonny@hotmail.com
function git.cfg.get() {
  local section="global"

  if [[ "$1" == "local" || "$1" == "global" ]] ; then
    section="$1"
    shift
  fi

  local command="get"
  local cmd
  if [[ -z "$*" ]] ; then
    cmd="git config --${section} --list"
  elif [[ "$*" =~ ^[a-z\.]*$ ]]; then
    for token in "$@"; do
      # shellcheck disable=SC2086
      cmd="git config --${section} --${command} ${token}"
    done
  else
    cmd="git config --${section} --get-all '$*'"
  fi

  h1 "${cmd}"
  eval "${cmd}"
}

function git.generate-changelog() {
  local token=$(git config user.token)

  git.is-valid-repo || return 2
  gem.install github_changelog_generator

  local -a remote_parts
  remote_parts=($(git.parse-remote "$(git.remote)"))

  local user=${remote_parts[3]}
  local repo=${remote_parts[4]}
  local host=${remote_parts[2]}
  
  [[ ${host} =~ github.com ]] || {
    error "Can only generate changelog for Github Repos at the moment, sorry."
    return 1
  }

  run "rm -f CHANGELOG.md"
  run "bundle exec github_changelog_generator --project ${repo/\.git/} --user ${user} -t ${token} --no-verbose"

  [[ -s "CHANGELOG.md" ]] || {
    error  "CHANGELOG.md has not been generated."
    return 1
  }

  success "CHANGELOG.md is ready."

  return 0
}




