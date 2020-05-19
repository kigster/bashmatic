#!/usr/bin/env bash
#———————————————————————————————————————————————————————————————————————————————
# © 2016-2020 Konstantin Gredeskoul, All rights reserved. MIT License.
# Ported from the licensed under the MIT license Project Pullulant, at
# https://github.com/kigster/pullulant
#———————————————————————————————————————————————————————————————————————————————
export LibBrew__PackageCacheList="/tmp/.lib_brew_packages.txt"
export LibBrew__CaskCacheList="/tmp/.lib_brew_casks.txt"

# This function returns the sorted list of versions that are specified
# for a given package in Brew using @<version>, for instance: "mysql@5.5" or
# postgres@9.4 etc.
brew.package.available-versions() {
  local package="$1"
  brew search "${package}@" | tr -d 'a-z@A-Z =>-+' | sed '/^$/d' | sort -nr | tr '\n' ' '
}

brew.cache-reset() {
  rm -f ${LibBrew__PackageCacheList} ${LibBrew__CaskCacheList}
}

brew.cache-reset.delayed() {
  ((${BASH_IN_SUBSHELL})) || brew.cache-reset
  ((${BASH_IN_SUBSHELL})) && trap "rm -f ${LibBrew__PackageCacheList} ${LibBrew__CaskCacheList}" EXIT
}

brew.upgrade.packages() {
  [[ -z "$(which brew)" ]] || brew.install
  [[ -z  $1 ]] && { 
    error "usage: brew.upgrade.packages package1 package2 ..."
    return 1
  }

  run "brew upgrade $@"
}

brew.upgrade() {
  brew.install
  if [[ -z "$(which brew)" ]]; then
    warn "brew is not installed...."
    return 1
  fi
  run "brew update --force"
  run "brew upgrade"
  run "brew cleanup -s"
}

brew.install() {
  local brew=$(which brew 2>/dev/null)
  if [[ -z "${brew}" ]]; then
    info "Installing Homebrew, please wait..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  else
    info "Detected Homebrew Version: ${bldylw}$(brew --version 2>/dev/null | head -1)"
  fi
}

brew.setup() {
  brew.upgrade
}

brew.package.link() {
  local package="${1}"
  shift
  [[ -n ${opts_verbose} ]] && verbose="--verbose"
  run "brew link ${verbose} ${package} $*"
}

brew.relink() {
  local package=${1}
  local verbose=
  [[ -n ${opts_verbose} ]] && verbose="--verbose"
  run "brew link ${verbose} ${package} --overwrite"
}

brew.package.list() {
  cache-or-command "${LibBrew__PackageCacheList}" 30 "brew ls -1"
}

brew.cask.list() {
  cache-or-command "${LibBrew__CaskCacheList}" 30 "brew cask ls -1"
}

brew.cask.tap() {
  run "brew tap homebrew/cask-cask"
}

cache-or-command() {
  local file="$1"
  shift
  local stale_minutes="$1"
  shift
  local command="$*"

  file.exists-and-newer-than "${file}" ${stale_minutes} && {
    cat "${file}"
    return 0
  }

  cp /dev/null ${file} >/dev/null
  eval "${command}" | tee -a "${file}"
}

brew.package.is-installed() {
  local package="${1}"
  local -a installed_packages=($(brew.package.list))
  array.has-element $(basename "${package}") "${installed_packages[@]}"
}

brew.cask.is-installed() {
  local cask="${1}"
  local -a installed_casks=($(brew.cask.list))
  array.has-element $(basename "${cask}") "${installed_casks[@]}"
}

brew.reinstall.package() {
  local package="${1}"
  local force=
  local verbose=
  [[ -n ${opts_force} ]] && force="--force"
  [[ -n ${opts_verbose} ]] && verbose="--verbose"

  run "brew unlink ${package} ${force} ${verbose}; true"
  run "brew uninstall ${package}  ${force} ${verbose}; true"
  run "brew install ${package} ${force} ${verbose}"
  run "brew link ${package} --overwrite ${force} ${verbose}"
  brew.cache-reset.delayed
}

brew.install.package() {
  local package=$1
  local force=
  local verbose=
  [[ -n ${opts_force} ]] && force="--force"
  [[ -n ${opts_verbose} ]] && verbose="--verbose"

  [[ -z ${opt_terse} ]] && inf "checking for 🍻  ${bldylw}${package}..."

  if [[ $(brew.package.is-installed ${package}) == "true" ]]; then
    [[ -z ${opt_terse} ]] && ok:
    [[ -z ${opt_terse} ]] || printf "${bldgrn}○ "
    export LibRun__LastExitCode=0
  else
    if [[ -z ${opt_terse} ]]; then
      printf " ${bldpur}${package}${txtylw} must pour.\n${clr}"
      run "brew install ${package} ${force} ${verbose}"
    else
      (brew install ${package} ${force} ${verbose}) 2>&1 | cat >/dev/null
      local code=$?
    fi

    [[ ${code} -eq 0 || ${LibRun__LastExitCode} -eq 0 ]] || {
      brew.reinstall.package "${package}"
    }

    brew.cache-reset.delayed
    export LibRun__LastExitCode=0

    if [[ $(brew.package.is-installed ${package}) == "true" ]]; then
      [[ -n ${opt_terse} ]] && printf "\n🟢 "
    else
      [[ -n ${opt_terse} ]] && printf "\n🔴 "
      export LibRun__LastExitCode=1
    fi
  fi

  return ${LibRun__LastExitCode}
}

brew.install.cask() {
  local cask=$1
  local force=
  local verbose=

  [[ -n ${opts_force} ]] && force="--force"
  [[ -n ${opts_verbose} ]] && verbose="--verbose"

  inf "verifying brew cask ${bldylw}${cask}"
  if [[ -n $(ls -al /Applications/*.app | grep -i ${cask}) && -z ${opts_force} ]]; then
    ui.closer.ok:
  elif [[ $(brew.cask.is-installed ${cask}) == "true" ]]; then
    ui.closer.ok:
    return 0
  else
    ui.closer.kind-of-ok:
    run "brew cask install ${cask} ${force} ${verbose}"
  fi

  brew.cache-reset.delayed
}

brew.uninstall.package() {
  local package=$1
  local force=
  local verbose=

  [[ -n ${opts_force} ]] && force="--force"
  [[ -n ${opts_verbose} ]] && verbose="--verbose"

  export LibRun__AbortOnError=${False}
  run "brew unlink ${package} ${force} ${verbose}"

  export LibRun__AbortOnError=${False}
  run "brew uninstall ${package} ${force} ${verbose}"

  brew.cache-reset.delayed
}

# set $opts_verbose to see more output
# set $opts_force to true to force it

brew.install.packages() {
  local force=
  [[ -n ${opts_force} ]] && force="--force"

  for package in "$@"; do
    brew.install.package "${package}"
  done
}

brew.reinstall.packages() {
  local force=
  [[ -n ${opts_force} ]] && force="--force"

  for package in "$@"; do
    brew.uninstall.package "${package}"
    brew.install.package "${package}"
  done
}

brew.uninstall.packages() {
  local force=
  [[ -n ${opts_force} ]] && force="--force"

  for package in $@; do
    brew.uninstall.package ${package}
  done
}

brew.service.up() {
  local svc="$1"
  run "brew services start ${svc}"
}

brew.service.down() {
  local svc="$1"
  run "brew services stop ${svc}"
}

brew.service.restart() {
  local svc="$1"
  run "brew services restart ${svc}"
}
