#!/usr/bin/env bash

audio.wav-to-mp3() {
  local file="$1"
  shift
  [[ -z "${file}" ]] && {
    h2 "USAGE: wav2mp3 <file.wav>" \
      "NOTE: wave file sampling rate will be auto-detected."
    return
  }

  [[ -n "$(which lame)" ]] || brew.package.install lame

  nfile=$(echo "${file}" | sed -E 's/\.wav$/\.mp3/ig')

  khz=$(audio.wave-file-frequency "${file}")

  info "${bldgrn}Source: ${bldylw}$(basename "${file}")"
  info "${bldpur}Output: ${bldylw}${nfile}$(txt-info) | (sampling rate: ${bldgrn}${khz:-'Unknown'}kHz)"

  [[ -n ${khz} ]] && khz=" -s ${khz} "
  run.set-next show-output-on

  hr
  run "lame --disptime 1 -m s -r -q 0 -b 320 ${khz} --cbr $* ${file} ${nfile}"
  hr
}

audio.wave-file-frequency() {
  local file="$1"

  [[ -z $(which mdls) ]] && return 1

  local frequency=$(mdls ${file} | grep kMDItemAudioSampleRate | sed 's/.*= //g')
  local kHz=$((${frequency} / 1000))
  printf ${kHz}
}

æ-wav2mp3() {
  audio.wav-to-mp3 "$@"
}

æ-wavfreq() {
  [[ -f ${1} ]] || {
    error "File ${1} does not exist."
    return 1
  }

  audio.wave-file-frequency "$@"
  echo " kHz"
}
