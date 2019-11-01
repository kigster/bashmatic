#!/usr/bin/env bash

lib::audio::wav-to-mp3() {
  local file="$1"
  [[ -z "${file}" ]] && { 
    hl::subtle "USAGE: wav2mp3 <file.wav>"
    return
  }
     
  [[ -n "$(which lame)" ]] || lib::brew::package::install lame

  nfile=$(echo "${file}" | sed -E 's/\.wav$/\.mp3/ig')

  info "Converting file ${bllldylw}}$(basename "${file}")$(txt-info) to ${bldylw}${nfile}..." 
  run::set-next show-output-on
  lame --disptime 1 -m s -r -q 0 -b 320 --cbr "${file}" "${nfile}"
}


wave2mp3() {
  lib::audio::wav-to-mp3 "$@"
}
