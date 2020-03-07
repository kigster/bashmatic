#!/usr/bin/env bash

export abort_progress_bar=0

export LibProgress__BarColor__Default="${txtgrn}"
export LibProgress__BarColor="${LibProgress__BarColor__Default}"

export LibProgress__BarChar__Default="▉"
export LibProgress__BarChar="${LibProgress__BarChar__Default}"

.progress.abort() {
  export abort_progress_bar=1
}

.progress.reset() {
  export abort_progress_bar=0
}

.progress.draw-emtpy-bar() {
  local width=${1:-"9"}
  cursor.rewind
  printf "["
  for j in $(seq 0 ${width}); do
    printf ' '
  done
  printf "]"
}

# Usage:
#
#    progress.bar 10 0.3 5
#
# Arguments:
#    1st: number of bar cycles (defaults to 1)
#    2nd: number of seconds it takes to complete the full progress bar
#    3rd: optional full width of the bar (by default, full screen is used)
#
progress.bar() {
  .progress.reset
  .progress.bar "$@"
  code=$?
  if [[ ${code} -ne 0 ]]; then
    .progress.reset
    return 1
  fi
  return 0
}

.progress.bar() {
  local loops=${1:-"1"}
  local full_cycle_seconds=${2:-"10"}
  local width=$3
  [[ -z ${width} ]] && width=$(($(.output.screen-width) - 5))

  local delay_seconds=$(ruby -e "printf('%.3f', ${full_cycle_seconds}.0 / ${width}.0)")

  trap ".progress.abort" INT STOP

  [[ -z "${LibProgress__BarColor}" ]] && LibProgress__BarColor=${LibProgress__BarColor__Default}
  [[ -z "${LibProgress__BarChar}" ]] && LibProgress__BarChar=${LibProgress__BarChar__Default}

  cursor.rewind

  printf "${LibProgress__BarColor}"

  for count in $(seq 1 ${loops}); do
    .progress.draw-emtpy-bar ${width}
    cursor.rewind 2
    for j in $(seq 0 ${width}); do
      sleep ${delay_seconds}
      printf "${LibProgress__BarChar}"
      [[ ${abort_progress_bar} -eq 1 ]] && {
        cursor.rewind
        reset-color:
        .progress.draw-emtpy-bar ${width}
        return 1
      }
    done
    .progress.draw-emtpy-bar ${width}
    cursor.rewind
  done
  reset-color:
  return 0
}
