#!/usr/bin/env bash

audio.file.frequency() {
  local file="$1"
  [[ -z $(command -V mdls) ]] && return 1
  local frequency=$(mdls "${file}" | grep kMDItemAudioSampleRate | sed 's/.*= //g')
  [[ -z ${frequency} ]] && frequency=48000
  local kHz=$(maths.eval "${frequency} / 1000.0" 0)
  printf ${kHz}
}

audio.make.mp3() {
  local file="$1"
  shift

  [[ -n "$(command -V lame)" ]] || brew.package.install lame

  local default_options=" -m s -r -h -b 320 --cbr "

  [[ -z "${file}" ]] && {
    usage-box "audio.wav-to-mp3 [ file.wav | file.aif | file.aiff ] © Convert a RAW PCM Audio to highest quality MP3" \
      "You can pass additional flags to ${bldylw}lame" "" \
      "Just run ${bldylw}lame --longhelp for more info." "" \
      "Default Flags: ${default_options}" ""
    return
  }

  nfile=$(echo "${file}" | sed -E 's/\.(wav|aiff?)$/\.mp3/ig')

  khz=$(audio.file.frequency "${file}")
  [[ -n ${khz} ]] && khz=" -s ${khz} "

  h2 "'$(basename "${file}")' ——→ '${nfile}', sample rate: ${khz:-'Unknown'}kHz" \
    "lame ${default_options} ${khz} $* '${file}' '${nfile}'"

  run.set-next show-output-on
  run "lame ${default_options} ${khz} $* '${file}' '${nfile}'"
  hr
}

æ.mp3() {
  audio.make.mp3 "$@"
}
