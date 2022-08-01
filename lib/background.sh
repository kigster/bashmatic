#!/usr/bin/env bash
# vim: ft=bash
# @copyright © 2016-2022 Konstantin Gredeskoul, All rights reserved
# @license MIT License.
#
# @file lib/background.sh
# @description Run a bunch of jobs on the background and wait for their completion

declare -a running_jobs
declare -a completed_jobs

declare background_log=$(mktemp -t "bashmatic.bg-{{index}}.log")

function background.log() {
  local index="${1:-0}"
  printf "${background_log/{{index}}/${index}}"
}

function background.sigchld() {
  for pid in "${!running_jobs[@]}"; do
    if [ ! -d "/proc/$pid" ]; then
      wait "${pid}"
      local code="$?"
      running_jobs["${pid}"]=${code}
    fi
  done
}

function background.run() {
  for command in "$@"; do
    local index=${#running_jobs[@]}
    local log="$(background.log "${index}")"
    (${command} 2>&1 | tee -a "${log}") &
    running_jobs[$!]=-1
  done
}

function background.wait() {
  local timeout
echo Starting background processes with pidS ${!pidS[@]}
echo Starting dd
timeout 15s dd if=/dev/zero of=/dev/null
echo dd terminated

}

trap background.sigchld SIGCHLD

(
  sleep 9
  exit 44
) &
pidS[$!]=1
(
  sleep 7
  exit 43
) &
pidS[$!]=1
(
  sleep 5
  exit 42
) &
pidS[$!]=1
