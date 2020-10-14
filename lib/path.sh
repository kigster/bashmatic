#!/usr/bin/env bash
# vim: ft=bash

# shellcheck disable=2120
function path.dirs() {
   local path="${1:-${PATH}}"
   echo "${path//:/$'\n'}" | /usr/bin/tr -d "'" | sedx '/^$/d'
}

function path.size() {
    path.dirs "$@" | /usr/bin/wc -l | /usr/bin/tr -d ' '
}

function path.uniq() {
    local -a paths
    for dir in $(path.dirs "$@"); do
        array.includes "${dir}" "${paths[@]}" || paths+=("${dir}")
    done
    echo "${paths[@]}" | /usr/bin/tr ' ' '\n'
}

function path.uniqify() {
    path.uniq "$@" | /usr/bin/tr '\n' ':' | sedx 's/[$%]//g'
}

function path.uniqify-and-export() {
    export PATH=$(path.uniqify "$@")
}

# @description Adds valid directories to those in the PATH and prints
#              to the output. DOES NOT MODIFY $PATH
function path.add() {
    local new_path="${PATH}"
    for path in "$@"; do
        is.a-directory "${path}" || {
            error "Argument ${path} is not a valid directory, abort."
            return 1
        }
        [[ ":${PATH}:" =~ :${path}: ]] && continue
        export new_path="${new_path}:${path}"
        export new_path="${new_path/::/:}"
    done
    echo "${new_path}"
}

# @description Appends valid directories to those in the PATH, and 
#              exports the new value of the PATH
function path.append() {
    export PATH="$(path.add "$@")"
}

# @description This function exists within direnv, but since we
#              are sourcing in .envrc we need to have this defined
#              to avoid errors.
function PATH_add() {
    path.add "$@"
}


