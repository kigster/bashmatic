#!/usr/bin/env bash
# vim: ft=bash
#———————————————————————————————————————————————————————————————————————————————
# © 2016-2024 Konstantin Gredeskoul, All rights reserved. MIT License
# Ported from the licensed under the MIT license Project Pullulant.
# Changes are © 2016-2024 Konstantin Gredeskoul All rights reserved. MIT License
#———————————————————————————————————————————————————————————————————————————————
#
# @description GPG related utilities

#———————————————————————————————————————————————————————————————————————————————
#  gpg
#———————————————————————————————————————————————————————————————————————————————

function gpg.install-deps() {
  [[ -z ${BASHMATIC_OS} ]] && util.os
  case "${BASHMATIC_OS}" in
  darwin)
    brew.install.packages "coreutils gawk gnu-sed git curl gzip"
    ;;
  linux)
    # Install dependencies and optional dependencies
    run "sudo apt-get install -yqq bash gnupg2 git tar xz-utils coreutils gawk grep sed"
    run "sudo apt-get install -yqq gzip bzip lzip file jq curl"
    ;;
  esac
}

function gpg.install() {
  [[ -z ${BASHMATIC_OS} ]] && util.os
  gpg.install-deps
  case "${BASHMATIC_OS}" in
  darwin)
    brew.install.packages "gnupg"
    ;;
  linux)
    # Install dependencies and optional dependencies
    run "sudo apt-get install gnupg -yyq"
    ;;
  esac
}

function gpg.key-for-github() {
  [[ -z ${BASHMATIC_OS} ]] && util.os
  if ! command -v gpg >/dev/null ; then
    gpg.install
  fi
  # shellcheck disable=SC2034
  local -a info=($(gpg.name-and-email))
  local name="${info[0]}"
  local email="${info[1]}"
  local -a keys=( $(gpg.my-keys) )
  if [[ ${#keys[@]} -gt 0 ]] ; then
    gpg.my-keys
    return 0
  fi
  local key_spec="$(mktemp)"
  echo "\
%echo Generating a basic OpenPGP key
Key-Type: 1
Key-Length: 4096
Name-Real: ${name}
Name-Email: ${email}
Expire-Date: 0
%no-protection
%commit
%echo done
" >"${key_spec}"
  cat "${key_spec}"
  gpg --batch --gen-key "${key_spec}" >/dev/null
}

function gpg.name-and-email() {
  local name="$(git config --global --get user.name)"
  local email="$(git config --global --get user.email)"
  
  [[ -z ${name} ]] && run.ui.ask-user-value name "Your full name:"
  [[ -z ${email} ]] && run.ui.ask-user-value email "Your full Email:"
  echo "${name}" "${email}"
}

function gpg.my-keys() {
  local -a info=($(gpg.name-and-email))
  local name="${info[0]}"
  local email="${info[1]}"
  
  # shellcheck disable=SC2034
  declare -a keys=( $(gpg --list-secret-keys --keyid-format=long | grep -B 3 -E "^uid *\[ultimate\] ${name}.*$" |  grep -E '^sec' | cut -d '/' -f 2 | sed 's/ .*$//g') )
  if [[ ${#keys[@]} -gt 0 ]]; then
    printf "\n${bldylw}Your GPG keys are:${clr}\n" >&2
    echo "${keys[*]}" | tr ' ' "\n"
    local len=${#keys[@]}
    local index
    while true; do 
      if [[ -n ${index} && ${index} -ge 0 && ${index} -lt ${#keys[@]} ]]; then
        local key_id="${keys[${index}]}"
        printf -- "Key ID is ${bldylw}${key_id}\n\n"
        run "git config --global user.signingkey ${key_id}"
        gpg --armor --export "${key_id}" |pbcopy
        gpg --armor --export "${key_id}"
        printf -- "${clr}NOTE: ${bldylw}the key is now in your clipboard${clr}.\n\n"
        printf -- "${clr}NOTE: gpg key for your ~/.gitconfig is ${bldgrn}${key_id}\n\n"
        hr
        return $?
      else
        [[ -n ${index} ]] && printf "${bldred}Invalid answer, expecting a number between 1 and ${len}.${clr}\n"
        run.ui.ask-user-value index "Which key would you like to print [1-${len}]? ${clr}"
        index=$(( index - 1  ))
      fi
    done

  else 
    echo "No gpg keys found matching name ${name}." >&2
    return 1
  fi
  return 0
}
 

