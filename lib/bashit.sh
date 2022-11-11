#!/usr/bin/env bash
# vim: ft=bash
#
# This file is a wrapper around fantastic BASH framework Bash-It, and specifically
# a multi-line powerline theme provided with it.

export __bashmatic_bash_it_remote="kigster/bash-it"
export __bashmatic_bash_it_source="https://github.com/${__bashmatic_bash_it_remote}"
export __bashmatic_bash_it_loaded=${__bashmatic_bash_it_loaded:-"0"}

function bashit-init() {
  export BASH_IT="${HOME}/.bash_it"
  export BASH_IT_THEME="powerline"
  export BASH_IT_THEME="powerline-multiline"
  # (Advanced): Change this to the name of your remote repo if you
  # cloned bash-it with a remote other than origin such as `bash-it`.
  #export BASH_IT_REMOTE='bash-it'
  export BASH_IT_REMOTE="${__bashmatic_bash_it_remote}"
  # Path to the bash it configuration
  source "${BASH_IT}/bash_it.sh"
  # Your place for hosting Git repos. I use this for private repos.
  export GIT_HOSTING='git@git.domain.com'
  # Uncomment this (or set SHORT_HOSTNAME to something else),
  # Will otherwise fall back on $HOSTNAME.
  export SHORT_HOSTNAME="$(hostname -s)"
  # Set Xterm/screen/Tmux title with only a short username.
  # Uncomment this (or set SHORT_USER to something else),
  # Will otherwise fall back on $USER.
  #export SHORT_USER=${USER:0:8}
  # Set Xterm/screen/Tmux title with shortened command and directory.
  # Uncomment this to set.
  export SHORT_TERM_LINE=true
  export BASH_IT_P4_DISABLED=true
  export SCM=git
  export SCM_CHECK=true
}

# returns the list of predefined themes, one per line
function bashit-colorschemes() {
  find "${BASH_IT}/colorschemes" -type f -name '*.colorscheme.bash' 2>/dev/null |
    tr '\n' '\0' | xargs -0 -n1 basename | sed 's/\.colorscheme\.bash//g'
}

# shellcheck disable=2120
function bashit-colorscheme() {
  local scheme="$1"

  if [[ -z "${scheme}" ]]; then
    if [[ "${ITERM_PROFILE}" =~ "Light" || "${ITERM_PROFILE}" =~ "light" ]]; then
      export scheme=light
    else
      export scheme=dark
    fi
  else
    local theme="${BASH_IT}/colorschemes/${scheme}.colorscheme.bash"
    if [[ -f ${theme} ]]; then
      # shellcheck disable=1090
      source "${theme}"
    else
      error "Color theme ${scheme} does not exist." >&2
    fi
  fi
}

# @description Possible Bash It Powerline Prompt Modules
#
# aws_profile
# battery
# clock
# command_number
# cwd
# dirstack
# gcloud
# go
# history_number
# hostname
# in_toolbox
# in_vim
# k8s_context
# last_status
# node
# python_venv
# ruby
# scm
# shlvl
# terraform
# user_info
# wd
function bashit-prompt-terraform() {
  powerline.prompt.git.max
  powerline.prompt.left terraform scm cwd shlvl last_status
  powerline.prompt.right clock battery user_info hostname
}

function bashit-prompt-k8s() {
  powerline.prompt.git.max
  powerline.prompt.left k8s_context scm cwd shlvl last_status
  powerline.prompt.right clock battery user_info hostname
}

function bashit-prompt-gcloud() {
  powerline.prompt.git.max
  powerline.prompt.left gcloud scm cwd shlvl last_status
  powerline.prompt.right clock battery user_info hostname
}

function bashit-prompt-aws() {
  powerline.prompt.git.max
  powerline.prompt.left aws_profile scm cwd shlvl last_status
  powerline.prompt.right clock battery user_info hostname
}

function bashit-prompt-developer() {
  powerline.prompt.git.max
  powerline.prompt.left go node ruby scm cwd shlvl last_status
  powerline.prompt.right clock battery user_info hostname
}

function bashit-prompt-minimal() {
  powerline.prompt.git.min
  powerline.prompt.left scm cwd last_status
  powerline.prompt.right go node ruby clock battery
}

#—————————————————————————————————————————————————————————————————————


# https://stackoverflow.com/questions/1891797/capturing-groups-from-a-grep-regex
# using BASH to capture group out of the regex. And it's very fast.
function bashit-list-prompts() {
  regex="^bashit-prompt-([a-z0-9]*)"
  for f in $(set | grep -E "$regex"); do [[ $f =~ $regex ]] && echo "${BASH_REMATCH[1]}"; done
}

# @description Installs Bash-It Framework
function bashit-install() {
  if [[ ! -d "${HOME}/.bash_it" && -n $(command -v git 2>/dev/null) ]]; then
    git clone -q "${__bashmatic_bash_it_source}" ~/.bash_it >/dev/null
  fi
  [[ -d ${HOME}/.bash_it ]] || return 1
}

function bashit-activate() {
  local color
  local func

  export __bashmatic_bash_it_loaded=1

  bashit-install
  bashit-init
  bashit-colorscheme dark # default
  bashit-prompt-minimal   # default

  # how look at the arguments
  while true; do
    local arg="$1"
    shift

    [[ -z "${arg}" ]] && break

    color="$(bashit-colorschemes | grep "${arg}")"
    if [[ -n "${color}" ]]; then
      bashit-colorscheme "${color}"
    else
      local func="bashit-prompt-${arg}"
      if is.a-function "${func}"; then
        ${func}
      else
        erroir "Unrecognized argument: [${arg}] is neither a color nor prompt type."
        return 1
      fi
    fi
  done
}

function bashit-refresh() {
  bashit-activate "$@"
}



