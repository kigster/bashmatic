#!/usr/bin/env bash
#———————————————————————————————————————————————————————————————————————————————
# © 2016 — 2017 Author: Konstantin Gredeskoul
# Ported from the licensed under the MIT license Project Pullulant, at
# https://github.com/kigster/pullulant
#———————————————————————————————————————————————————————————————————————————————
export LibBrew__PackageCacheList="/tmp/.lib_brew_packages.txt"
export LibBrew__CaskCacheList="/tmp/.lib_brew_casks.txt"

lib::brew::cache-reset() {
  rm -f ${LibBrew__PackageCacheList} ${LibBrew__CaskCacheList}
}

lib::brew::upgrade() {
  lib::brew::install

  if [[ -z "$(which brew)" ]]; then
    warn "brew is not installed...."
    return 1
  fi

  run "brew update --force"
  run "brew upgrade"
  run "brew cleanup -s"
}

lib::brew::install() {
  declare -a brew_packages=$@

  local brew=$(which brew 2>/dev/null)

  if [[ -z "${brew}" ]]; then
    info "Installing Homebrew, please wait..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  else
    info "Homebrew is already installed."
    info "Detected Homebrew Version: ${bldylw}$(brew --version 2>/dev/null | head -1)"
  fi

  # Let's install that goddamn brew-cask
  run "brew tap caskroom/cask"
}

lib::brew::setup() {
  lib::brew::upgrade
}

lib::brew::relink() {
  local package=${1}
  local verbose=
  [[ -n ${opts_verbose} ]] && verbose="--verbose"
  run "brew link ${verbose} ${package} --overwrite"
}

lib::brew::package::list() {
  lib::cache-or-command "${LibBrew__PackageCacheList}" 30 "brew ls -1"
}

lib::brew::cask::list() {
  lib::cache-or-command "${LibBrew__CaskCacheList}" 30 "brew cask ls -1"
}

lib::cache-or-command() {
  local file="$1"; shift
  local stale_minutes="$1"; shift
  local command="$*"
  
  lib::file::exists_and_newer_than "${file}" ${stale_minutes} && {
    cat "${file}"
    return 0
  }

  cp /dev/null ${file} > /dev/null
  eval "${command}" | tee -a "${file}"
}

lib::brew::package::is-installed() {
  local package=${1}
  declare -a installed_packages=($(lib::brew::package::list))
  array-contains-element ${package} ${installed_packages[@]}
}


lib::brew::cask::is-installed() {
  local cask=${1}
  declare -a installed_casks=($(lib::brew::cask::list))
  array-contains-element ${cask} ${installed_casks[@]}
}


lib::brew::install::package() {
  local package=$1
  local force=
  local verbose=

  [[ -n ${opts_force} ]] && force="--force"
  [[ -n ${opts_verbose} ]] && verbose="--verbose"

  inf "checking brew package ${bldylw}${package}"
  if [[ $(lib::brew::package::is-installed ${package}) == "true" ]]; then
    ok:
  else
    kind_of_ok:
    run "brew install ${package} ${force} ${verbose}"
    if [[ ${LibRun__LastExitCode} != 0 ]]; then
      not_ok:
      info "${package} failed to install, attempting to reinstall..."
      run "brew unlink ${package} ${force} ${verbose}; true"
      run "brew uninstall ${package}  ${force} ${verbose}; true"
      run "brew install ${package} ${force} ${verbose}"
      run "brew link ${package} --overwrite ${force} ${verbose}"
    fi
  fi
}

lib::brew::install::cask() {
  local cask=$1
  local force=
  local verbose=

  [[ -n ${opts_force} ]] && force="--force"
  [[ -n ${opts_verbose} ]] && verbose="--verbose"

  inf "verifying brew cask ${bldylw}${cask}"
  if [[ -n $(ls -al /Applications/*.app | grep -i ${cask}) && -z ${opts_force} ]]; then
    ok:
  elif [[ $(lib::brew::cask::is-installed ${cask}) == "true" ]]; then
    ok:
    run "brew cask link ${cask} ${force} ${verbose}; true"
  else
    kind_of_ok:
    run "brew cask install ${cask} ${force} ${verbose}"
  fi
}

lib::brew::uninstall::package() {
  local package=$1
  local force=
  local verbose=

  [[ -n ${opts_force} ]] && force="--force"
  [[ -n ${opts_verbose} ]] && verbose="--verbose"

  export LibRun__AbortOnError=${False}
  run "brew unlink ${package} ${force} ${verbose}"

  export LibRun__AbortOnError=${False}
  run "brew uninstall ${package} ${force} ${verbose}"
}

# set $opts_verbose to see more output
# set $opts_force to true to force it

lib::brew::install::packages() {
  local force=
  [[ -n ${opts_force} ]] && force="--force"

  for package in $@; do
    lib::brew::install::package ${package}
  done
}

lib::brew::reinstall::packages() {
  local force=
  [[ -n ${opts_force} ]] && force="--force"

  for package in $@; do
    lib::brew::uninstall::package ${package}
    lib::brew::install::package ${package}
  done
}

lib::brew::uninstall::packages() {
  local force=
  [[ -n ${opts_force} ]] && force="--force"

  for package in $@; do
    lib::brew::uninstall::package ${package}
  done
}
