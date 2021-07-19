#!/usr/bin/env bash
# vim: ft-bash

export ts=$(time.now.db)
export date=${ts:0:10}
export bashmatic_apt_cache="/tmp/.bashmatic/${USER}/apt-list.${date}"
export bashmatic_apt_updated=${bashmatic_apt_updated:-0}

((DEBUG)) && info "apt cache file: [${bashmatic_apt_cache}]"

mkdir -p "$(dirname ${bashmatic_apt_cache})" 2>/dev/null

function apt.has-cache() {
  [[ -f ${bashmatic_apt_cache} ]] && return 0
  return 1
}

function apt.cache.refresh() {
  apt.cache.populate
}

function apt.cache.populate() {
  sudo apt list 2>/dev/null| cut -d '/' -f 1 > "${bashmatic_apt_cache}" 2>/dev/null
}

function apt.cache() {
  local code=0
  apt.has-cache && return 0

  ((bashmatic_apt_updated)) || {
    run "sudo apt update -yqq" >&2 
    export bashmatic_apt_updated=1
  }
  inf "refreshing apt cache ..." >&2
  apt.cache.populate
  code=$? 
  ((code)) || { 
    printf "[OK], got ${bldylw}$(cat "${bashmatic_apt_cache}" | wc -l | tr -d ' ')$(txt-info) packages."; 
    ok: >&2
  }
  ((code)) && not-ok: >&2
  return ${code}
}

function apt.is-cached() {
  local package="$1"
  apt.cache
  grep -q "^${package}$" "${bashmatic_apt_cache}"
}

function package.is-installed() {
  apt.is-cached "$@"
}

function package.are-installed() {
  for p in "$@"; do
    package.is-installed "$p" || return 1
  done
  return 0
}

function package.uninstall() {
  for p in "$@"; do
    package.is-installed "$p" && run "sudo apt remove $p"
  done
  apt.cache.refresh
}

function apt.install() {
  apt.cache
  local installed=0
  for p in "$@"; do
    info "checking if ${p} is installed..."
    apt.is-cached && { printf " - YES"; ok:; continue; }
    ui.closer.kind-of-ok:
    run "sudo apt-get install ${p} -yqq"
    installed=$((installed + 1))
  done
  ((installed)) && apt.cache.refresh
}

function package.install() {
  apt.install "$@"
}

