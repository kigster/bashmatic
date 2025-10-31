#! /usr/bin/env bash
# vim: ft=bash

# © 2025 Fractional.ai

export project_root="$(dirname "$(dirname "$(realpath "$0")")")"

function print() {
    local message="$1" && shift
    local level="$1" && shift
    local color="$1" && shift

    level=${level:-"info"}
    level="$(printf "%-10s" "${level}")"
    color=${color:-"32"}
    local message_color
    message_color=${color}
    color=$((color + 10))
    time="$(date "+%H:%M:%S%p")"
    printf "\e[1;${color}m%s | \e[1;${color}m%s \e[0m — \e[1;${message_color}m%s\e[0m\n" "${time}" "${level}" "${message}"
}

function print.warning() {
    print "$1" "warning" "33" "$@"
}

function print.info() {
    print "$1" "info" "34" "$@"
}

function print.success() {
    print "$1" "success" "32" "$@"
}

function print.failure() {
    print "$1" "failure" "31" "$@"
}
