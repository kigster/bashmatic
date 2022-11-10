#!/usr/bin/env bash

# @description Installs YARN via npm if not found; then runs yarn install
#    Note that yarn install is skipped if package.json and yarn.lock haven't
#    changed since the last run of yarn install.
function yarn_install() {
  command -v yarn>/dev/null || npm install -g yarn
  if [[ ! -f .yarn.sha  || "$(cat .yarn.sha)" != "$(yarn_sha)" ]]; then
    set -x
    yarn install
    set +x
    yarn_sha > .yarn.sha
  fi
}

# @description Prints to STDOUT the SHA based on package.json and yarn.lock
function yarn_sha() {
  [[ -f package.json && -f yarn.lock ]] && cat package.json yarn.lock | sha
}


