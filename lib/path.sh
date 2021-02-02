#!/usr/bin/env bash
# vim: ft=bash
# @file path.sh
# @description Utilities for managing the $PATH variable
# @example
#     $ source ${BASHMATIC_HOME}/init.sh
#     $ path.mutate.append ~/workspace/bin /usr/local/opt/bin
#     $ path.mutate.prepend ~/bin 

# 1. Functional methods, no mutations of global variables:
#

# @description Removes a trailing slash from an argument path
function path.strip-slash() {
    local path="$(echo "$1" | sed -E 's#\/+$##g')"
    printf -- "%s" "${path}"
}

# @description Prints a new-line separated list of paths in PATH
# @arg1 A path to split, defaults to $PATH
function path.dirs() {
   local path="${1:-${PATH}}"
   echo "${path//:/$'\n'}" | /usr/bin/tr -d "'" | sedx '/^$/d; s/://g'
}

# @description Prints the tatal number of paths in the path argument, 
#              which defaults to $PATH
function path.dirs.size() {
    path.dirs "$@" | /usr/bin/wc -l | /usr/bin/tr -d ' '
}

# @description 
#     Prints all folders in $PATH, one per line, removing any duplicates,
#     Does not mutate the $PATH
function path.dirs.uniq() {
    local -a paths=($(path.dirs "$@"))
    for path in $(array.uniq "${paths[@]}"); do echo "${path}"; done
}

# @description 
#     Removes duplicates from the $PATH (or argument) and prints the 
#     results in the PATH format (column-joined). DOES NOT mutate the actual $PATH
function path.uniq() {  
    # shellcheck disable=2046
    array.join ':' $(path.dirs.uniq "$@")
}

# @description 
#    Appends a new directory to the $PATH and prints the result to STDOUT,
#    Does NOT mutate the actual $PATH
function path.append() {
    local new_path="${PATH}"
    for __path in "$@"; do
        is.a-directory "${__path}" || {
            error "Argument ${__path} is not a valid directory, abort." >&2
            return 1
        }
        path.dirs.uniq | grep -q -E "^${__path}$" && continue
        new_path="${new_path}:${__path}"
    done
    echo "${new_path}"
}

# @description 
#   Prepends a new directory to the $PATH and prints to STDOUT,
#   If one of the arguments already in the PATH its moved to the front.
#    DOES NOT mutate the actual $PATH
function path.prepend() {
    local new_path="${PATH}"
    for __path in "$@"; do
        is.a-directory "${__path}" || {
            error "Argument ${__path} is not a valid directory, abort.">&2
            return 1
        }
        local p="$(path.dirs.uniq | grep -v -E "^${__path}$" | tr '\n' ':')"
        new_path="${__path}:${p}"
    done
    echo "${new_path}"
}

#
# The following methods do change the $PATH variable, but if they are
# executed in a subshell, the will not modify the PATH of the outer shell
#

# @description 
#     Removes any duplicates from $PATH and exports it.
function path.mutate.uniq() {
    export PATH="$(path.uniq "$@")"
}

# @description 
#     Appends valid directories to those in the PATH, and
#     exports the new value of the PATH
function path.mutate.append() {
    export PATH="$(path.append "$@")"
}

# @description 
#     Prepends valid directories to those in the PATH, and
#     exports the new value of the PATH
function path.mutate.prepend() {
    export PATH="$(path.prepend "$@")"
}

# @description 
#     This function exists within direnv, but since we
#     are sourcing in .envrc we need to have this defined
#     to avoid errors.
function PATH_add() {
    path.mutate.append "$@"
}
