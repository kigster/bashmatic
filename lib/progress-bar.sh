#!/usr/bin/env bash

export abort_progress_bar=0

export LibProgress__BarColor__Default="${bldblu}"
export LibProgress__BarColor="${LibProgress__BarColor__Default}"
export LibProgress__BarChar__Default="▉"
export LibProgress__BarChar="${LibProgress__BarChar__Default}"

#——————————————————————————————————————————————————————————————————————————————————
# PRIVATE
#——————————————————————————————————————————————————————————————————————————————————

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
  for j in $(seq 0 "${width}"); do
    printf ' '
  done
  printf "]"
}

.progress.bar() {
  local full_cycle_seconds=${1:-"10"}; shift
  local loops=${1:-"1"}; shift
  local width=$1

  is.integer "${width}" && shift
  is.integer "${width}" || width=$(($(.output.screen-width) - 2))

  local delay_seconds=$(ruby -e "printf('%.6f', ${full_cycle_seconds}.to_f / ${width}.to_f)")

  trap ".progress.abort" INT STOP

  [[ -z "${LibProgress__BarColor}" ]] && LibProgress__BarColor=${LibProgress__BarColor__Default}
  [[ -z "${LibProgress__BarChar}" ]] && LibProgress__BarChar=${LibProgress__BarChar__Default}

  cursor.rewind

  printf "${LibProgress__BarColor}"

  for count in $(seq 1 "${loops}"); do
    .progress.draw-emtpy-bar ${width}
    cursor.rewind 2
    for j in $(seq 0 ${width}); do
      sleep "${delay_seconds}"
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

#——————————————————————————————————————————————————————————————————————————————————
# PUBLIC
#——————————————————————————————————————————————————————————————————————————————————

# USAGE:
# progress.bar 10 0.3 5
#
# Arguments:
#    1nd: number of seconds it takes to complete the full progress bar
#    2st: number of bar cycles (defaults to 1)
#    3rd: optional full width of the bar (by default, full screen is used)
#
progress.bar.auto-run() {
  .progress.reset
  .progress.bar "$@"
  code=$?
  if [[ ${code} -ne 0 ]]; then
    .progress.reset
    return 1
  fi
  return 0
}

.progress.bar.check-pid-alive() {
  kill -0 "$1" >/dev/null 2>&1
}

progress.bar.launch-and-wait() {
  local command="$*"

  run.print-command "${command}\n" 

  ${command} 1>/dev/null 2>&1 &
  local pid=$!

  info "Waiting for background process to finish; PID=${bldylw}${pid}"

  set -e
  while .progress.bar.check-pid-alive $pid; do
    progress.bar.auto-run 0.5 10
  done
  set +e
  return 0
}

# Usage: 
# To render a red progress bar using the '❯' character:
#
# $ progress.bar.config BarColor=${bldred} BarChar="❯"
#
progress.bar.config() {
  while true; do
    local setting="$1"; shift
    [[ -z ${setting} ]] && break

    local key=${setting/=*/}
    local value=${setting/*=/}

    #eval "echo LibProgress__${key}=${value}"
    eval "export LibProgress__${key}=\"${value}\""
  done
}

progress.bar.configure.color-green() {
  progress.bar.config BarColor="${bldgrn}"
}

progress.bar.configure.color-red() {
  progress.bar.config BarColor="${bldred}"
}

progress.bar.configure.color-yellow() {
  progress.bar.config BarColor="${bldylw}"
}
  
progress.bar.configure.symbol-block() {
  progress.bar.config BarChar="${LibProgress__BarChar__Default}"
}  
  
progress.bar.configure.symbol-arrow() {
  progress.bar.config BarChar="❯"
}  

progress.bar.configure.symbol-square() {
  progress.bar.config BarChar="◼︎"
}

progress.bar.configure.symbol-bar() {
  progress.bar.config BarChar="█"
}



