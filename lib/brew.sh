#!/usr/bin/env bash
# vim: ft=bash
#
# © 2016-2021 Konstantin Gredeskoul, All rights reserved. MIT License.
# Ported from the licensed under the MIT license Project Pullulant, at
# shellcheck disable=SC1134
#
LibBrew__PackageCacheList="${BASHMATIC_TEMP}/brew-package-cache.txt"
export LibBrew__PackageCacheList

LibBrew__CaskCacheList="${BASHMATIC_TEMP}/brew-cask-cache.txt"
export LibBrew__CaskCacheList

# This returns the sorted list of versions that are specified
# for a given package in Brew using @<version>, for instance: "mysql@5.5" or
# postgres@9.4 etc.

function brew.package.available-versions() {
  local package="$1"
  [[ -z "$1" ]] && return 1
  
  brew search "${package}@" | tr -d 'a-z@A-Z =>-+' | sed '/^$/d' | sort -nr | tr '\n' ' '
}

function brew.cache-reset() {
  if [[ "$1" == "cask" ]]; then
    rm -f "${LibBrew__CaskCacheList}"
  elif [[ "$2" == "package" ]]; then
    rm -f "${LibBrew__PackageCacheList}"
  else
    rm -f "${LibBrew__PackageCacheList}" "${LibBrew__CaskCacheList}"
  fi
}

function brew.cache-reset.delayed() {
  ((BASH_IN_SUBSHELL)) || brew.cache-reset both
}

function brew.upgrade.packages() {
  [[ -z "$(which brew)" ]] || brew.install
  [[ -z $1 ]] && {
    error "usage: brew.upgrade.packages package1 package2 ..."
    return 1
  }

  run "brew upgrade $*"
}

function brew.upgrade() {
  brew.install
  if [[ -z "$(which brew)" ]]; then
    warn "brew is not installed...."
    return 1
  fi
  run "brew update --force"
  run "brew upgrade"
  run "brew cleanup -s"
}

function brew.install() {
  inf "Checking if a local brew command exists already ..." >&2
  local brew=$(command -v brew >/dev/null)
  if [[ -z "${brew}" ]]; then
    not-ok:

    info "Brew wasn't found — installing Homebrew, ${bldgrn}please wait..."
    run "/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)""
  else
    ok:
    info "Excellent: an existing Homebrew Version: ${bldylw}$(brew --version 2>/dev/null | head -1) exists"
    run "brew update"
  fi
}

function brew.uninstall() {
  echo y | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh)"
}

function brew.setup() {
  brew.upgrade
}

function brew.package.link() {
  local package="${1}"
  shift
  [[ -n "${opts_verbose}" ]] && verbose="--verbose"
  run "brew link --force --overwrite ${verbose} ${package} $*"
}

function brew.relink() {
  local package"${1}"
  local verbose=
  [[ -n "${opts_verbose}" ]] && verbose="--verbose"
  run "brew unlink --quiet ${package}"
  run "brew link --force --overwrite ${verbose} ${package}"
}

function brew.package.list() {
  cache-or-command "${LibBrew__PackageCacheList}" 10 --formula -1
}

function brew.cask.list() {
  cache-or-command "${LibBrew__CaskCacheList}" 10 --cask -1
}

function brew.cask.tap() {
  run "brew tap homebrew/cask-cask"
}

function cache-or-command() {
  local file="$1"
  shift
  local stale_minutes="$1"
  shift

  if file.exists-and-newer-than "${file}" "${stale_minutes}"; then
    if [[ -s "${file}" ]]; then
      cat "${file}"
      return 0
    fi
  fi

  is-dbg && info "REFRESHING CACHE with command: ${bldylw}brew list ${*} >${file}"
  brew list "$@" >"${file}"
  cat "${file}"
}

# @description For each passed argument checks if it's installed.
# @return 0 when all packages in the list are instealled, 1 otherwise
function package.is-installed() {
  [[ "$(brew.package.is-installed "$@")" == "true" ]]
}

function brew.package.is-installed() {
  if brew.package.all-installed "$@"; then
    echo "true"
  else
    echo "false"
  fi
}

function brew.cask.is-installed() {
  if brew.cask.all-installed "$@"; then
    echo "true"
  else
    echo "false"
  fi
}

function brew.package.all-installed() {
  local -a installed_packages=($(brew.package.list))
  for item in "$@"; do
    array.includes "${item}" "${installed_packages[@]}" || return 1
  done
  return 0
}

function brew.cask.all-installed() {
  local -a installed_casks=($(brew.cask.list))
  for item in "$@"; do
    array.includes "${item}" "${installed_casks[@]}" || return 1
  done
  return 0
}

function brew.reinstall.package() {
  local package="${1}"
  local force=
  local verbose=
  [[ -n "${opts_force}" ]] && force="--force"
  [[ -n "${opts_verbose}" ]] && verbose="--verbose"

  run "brew unlink --quiet ${package}"
  run "brew uninstall ${force} ${verbose} ${package}"

  # brew.cache-reset.delayed

  brew.install.package "${package}"
}

function package.uninstall() {
  brew.uninstall.packages "$@"    
}

function package.install() {
  brew.install.packages "$@"    
  hash -r 2>/dev/null
}

function brew.install.package() {
  local package="$1"
  local force=
  local verbose=
  local code

  [[ -n "${opts_force}" ]] && force="--force"
  [[ -n "${opts_verbose}" ]] && verbose="--verbose"
  [[ -z "${opt_terse}" ]] && inf "checking for 🍻 ${bldylw}${package}..."

  if brew.package.all-installed "${package}"; then
    [[ -z "${opt_terse}" ]] && ok:
    [[ -z "${opt_terse}" ]] || printf "${bldgrn}○ "
    export LibRun__LastExitCode=0
  else
    if [[ -z "${opt_terse}" ]]; then
      ui.closer.kind-of-ok:
      run "brew install ${force} ${verbose} ${package}"
      code="${LibRun__LastExitCode}"
    else
      brew install ${force} ${verbose} ${package} 1>/dev/null 2>&1
      code=$?
    fi

    brew.cache-reset package
    brew.package.all-installed "${package}" && code=0

    [[ -n ${force} ]] && {
      run.set-next continue-on-error
      run "brew link --force --overwrite ${verbose} ${package}"
    }

    hash -r >/dev/null

    ((code)) && {
      warning "Reinstalling ${package} as I couldn't find it after instal..."
      brew.reinstall.package "${package}"
    }

    # brew.cache-reset.delayed
    export LibRun__LastExitCode=0

    if [[ "$(brew.package.is-installed "${package}")" == "true" ]]; then
      [[ -n "${opt_terse}" ]] && printf "\n 🟢 "
    else
      [[ -n "${opt_terse}" ]] && printf "\n 🔴 "
      export LibRun__LastExitCode=1
    fi
  fi

  return ${LibRun__LastExitCode}
}

function brew.install.cask() {
  local cask=$1
  local force=
  local verbose=

  [[ -n "${opts_force}" ]] && force="--force"
  [[ -n "${opts_verbose}" ]] && verbose="--verbose"

  local installed_app="$(osx.app.is-installed "${cask}")"

  inf "checking if cask is installed: ${bldylw}${cask}"

  brew.cask.all-installed "${cask}" && {
    ok:
    return 0
  }

  if [[ -n "${installed_app}" && -z "${opts_force}" ]]; then
    ui.closer.ok:
    return 0
  else
    ui.closer.kind-of-ok:
    run "brew install --cask ${cask} ${force} ${verbose}"
    brew.cache-reset cask
  fi
}

function brew.uninstall.package() {
  local package=$1
  local force=
  local verbose=

  [[ -n "${opts_force}" ]] && force="--force"
  [[ -n "${opts_verbose}" ]] && verbose="--verbose"

  run.set-next continue-on-error
  run "brew unlink ${package} ${force} ${verbose}"

  run.set-next continue-on-error
  run "brew uninstall ${package} ${force} ${verbose}"

  brew.cache-reset.delayed
}

# set $opts_verbose to see more output
# set $opts_force to true to force it

function brew.install.packages() {
  local force=
  [[ -n "${opts_force}" ]] && force="--force"

  for package in "$@"; do
    brew.install.package "${package}"
  done
}

function brew.reinstall.packages() {
  local force=
  local result=0

  [[ -n "${opts_force}" ]] && force="--force"

  for package in "$@"; do
    brew.uninstall.package "${package}"
    brew.install.package "${package}"
    local result=$?
  done

  return ${result}
}

function brew.uninstall.packages() {
  local force=
  [[ -n "${opts_force}" ]] && force="--force"

  for package in "$@"; do
    brew.uninstall.package "${package}"
  done
}

function brew.service.up() {
  local svc="$1"
  run "brew services start ${svc}"
}

function brew.service.down() {
  local svc="$1"
  run "brew services stop ${svc}"
}

function brew.service.restart() {
  local svc="$1"
  run "brew services restart ${svc}"
}
