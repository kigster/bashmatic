#!/usr/bin/env bash
# vim: ft=bash
# © 2016-2024 Konstantin Gredeskoul
#
user.gitconfig.email() {
  if [[ -s ${HOME}/.gitconfig ]]; then
    grep email "${HOME}/.gitconfig" | sedx 's/.*=\s?//g'
  fi
}

user.gitconfig.name() {
  if [[ -s ${HOME}/.gitconfig ]]; then
    grep name "${HOME}/.gitconfig" | sedx 's/.*=\s?//g'
  fi
}

user.finger.name() {
  [[ -n $(which finge) ]] && finger "${USER}" | head -1 | sedx 's/.*Name: //g'
}

user.username() {
  echo "${USER:-$(whoami)}"
}

user() {
  local user
  user=$(user.finger.name)
  [[ -z "${user}" ]] && user="$(user.gitconfig.name)"
  [[ -z "${user}" ]] && user="$(user.gitconfig.email)"
  [[ -z "${user}" ]] && user="$(user.username)"
  echo "${user}"
}

#———————————————————————————————————————————————————————————————————————————————————————————————————
# Get user's name and email from the "${bashmatic_git_pairs}" file.
# https://github.com/pivotal-legacy/git_scripts
#
#———————————————————————————————————————————————————————————————————————————————————————————————————
#
# Please NOTE: these functions only support names in the format "Firstname Lastname".
# It does NOT support punctuation, middle names, etc.
export bashmatic_git_pairs="${HOME}/.pairs"

user.pairs.set-file() {
  [[ -s "$1" ]] || {
    error "Please pass a valid path to the .pairs file, typically in your home. You passed: [$1]"
    return 1
  }

  export bashmatic_git_pairs="$1"
}

user.pairs.firstname() {
  [[ ! -s "${bashmatic_git_pairs}" || -z "$1" ]] && return
  grep -i "$1" "${bashmatic_git_pairs}" | head -1 | awk '{print $2}' | tr -d ';'
}

user.pairs.lastname() {
  [[ ! -s "${bashmatic_git_pairs}" || -z "$1" ]] && return
  grep -i "$1" "${bashmatic_git_pairs}" | head -1 | awk '{print $3}' | tr -d ';'
}

user.pairs.username() {
  [[ ! -s "${bashmatic_git_pairs}" || -z "$1" ]] && return
  grep -i "$1" "${bashmatic_git_pairs}" | head -1 | awk '{print $4}' | tr -d ';'
}

user.pairs.email() {
  [[ ! -s "${bashmatic_git_pairs}" || -z "$1" ]] && return
  local username="$(user.pairs.username "$1")"
  local domain="$(grep domain "${bashmatic_git_pairs}" | sed 's/.*domain://g' | tr -d ' ')"
  [[ -n ${username} && -n "${domain}"  ]] || {
    error "Couldn't determine username or domain from ${bashmatic_git_pairs} file for input ${bldwht}$*"
    return 1
  }
  echo "${username}@${domain}"
}
#———————————————————————————————————————————————————————————————————————————————————————————————————

function user.first() {
  user | tr '\n' ' ' | ruby -ne 'puts $_.split(/ /).first.capitalize'
}

# https://apple.stackexchange.com/questions/20547/how-do-i-find-my-ip-address-from-the-command-line
function user.my.external-ip() {
  ( curl -s http://checkip.dyndns.org/ | sed 's/[a-zA-Z<>/ :]//g' | sed -E 's/^[\d\.]//g; s/\r//g;' 2>&1 )
}

function user.my.ip() {
  user.my.external-ip | tr -d '\n'
}
#
# https://apple.stackexchange.com/questions/20547/how-do-i-find-my-ip-address-from-the-command-line
function user.my.local-ip() {
  ifconfig -l | xargs -n1 ipconfig getifaddr
}

function user.my.reverse-ips() {
  local ip="$(user.my.ip)"
  local output=$(curl -s "https://api.hackertarget.com/reverseiplookup/?q=${ip}" 2>&1)

  if [[ ${output} =~ Membership ]]; then
    error "You have exceeded the number of free API calls to determine your reverse IP." \
          "Please visit https://hackertarget.com/scan-membership/ if you wish to " \
          "increase your limit." >&2
    return 1
  else
    echo
  fi
}

user.host() {
  local host=
  host=$(user.my.reverse-ip)
  [[ -z ${host} ]] && host=$(user.my.ip)
  printf "${host}"
}

user.login-shell() {
  basename "$(user.login-shell-path)"
}

# @description
#   Attempts to resolve users' login shell with full path.
#
user.login-shell-path() {
  if [[ -n $(command -v finger 2>/dev/null) ]]; then
    finger "${USER}" | grep Shell: | sed 's/^.*Shell: //g'
  elif grep -q "${USER}" /etc/passwd 2>/dev/null ; then
    grep "${USER}" /etc/passwd | sed 's/.*://g'
  else
    command -v "$(user.current-shell)"
  fi
}

# @description
#    Determines the current session shell by looking at the
#    command running under the current PID $$.
#
#    Prints current shell without the path, eg 'bash'
#
user.current-shell() {
  /bin/ps -p $$ -o comm | tail -1 | sed -E 's/-//g'
}

user.login-shell-init-file() {
  declare -a shell_files=($(util.shell-init-files))
  .user.pick-shell-init-file "${shell_files[@]}"
}

user.current-shell-init-file() {
  declare -a shell_files=($(util.shell-init-files "$(user.current-shell)"))
  .user.pick-shell-init-file "${shell_files[@]}"
}

.user.pick-shell-init-file() {
  local init_file
  for file in "$@"; do
    if [[ -s ${file} ]]; then
      init_file="${file}"
      break
    fi
  done
  # if none exist, we'll create one
  [[ -z ${init_file} ]] && init_file="$0"
  touch "${init_file}"
  echo "${init_file}"
}


