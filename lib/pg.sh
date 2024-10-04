#!/usr/bin/env bash
# vim: ft=bash
#
# © 2016-2024 Konstantin Gredeskoul
# MIT License
#
# Collection of PostgreSQL helper functions for locally running instances.

# @description Returns true if PostgreSQL is running locally
pg.is-running() {
  [[ $(/bin/ps -ef | grep -c '[p]ostgres:') -gt 4 ]]
}

# @description if one or more PostgreSQL instances is running locally,
#              prints each server's binary +postgres+ file path
pg.running.server-binaries() {
  ps -eo 'args' | $(which grep) '[p]ostgres.*-D' | awk '{print $1}' | sort
}

# @description For each running server prints the data directory
pg.running.data-dirs() {
   ps -eo 'args' | $(which grep) '[p]ostgres.*-D' | awk 'BEGIN{FS="-D"}{print $2}' | awk '{print $1}' | sort
}

# @description Grab the version from `postgres` binary in the PATH and remove fractional sub-version
pg.server-in-path.version() {
  is.command postgres || return 1
  $(which postgres) -V | sed -E 's/[^0-9.]//g;s/\..*$//g'
}


