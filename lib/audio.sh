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
  local nfile="$2"
  shift

  [[ -n "$(command -V lame)" ]] || brew.package.install lame

  local default_options=" -m s -r -h -b 320 --cbr "

  [[ -z "${file}" ]] && {
    usage-box "audio.wav-to-mp3 [ file.wav | file.aif | file.aiff ] [ file.mp3 ] © Convert a RAW PCM Audio to highest quality MP3" \
      "You can pass additional flags to ${bldylw}lame" "" \
      "Just run ${bldylw}lame --longhelp for more info." "" \
      "Default Flags: ${default_options}" ""
    return
  }

  [[ -z ${nfile} ]] && nfile="$(echo "${file}" | sedx 's/\.(wav|aiff?)$/\.mp3/g')"

  khz=$(audio.file.frequency "${file}")

  [[ -n ${khz} ]] && khz=" -s ${khz} "

  h2 "'$(basename "${file}")' —❯ ${bldylw}${nfile}${txtgrn}, sample rate: ${khz:-'Unknown'}kHz" \
    "lame ${default_options} ${khz} $* '${file}' '${nfile}'"

  run.set-next show-output-on abort-on-error
  run "lame ${default_options} ${khz} $* '${file}' '${nfile}'"
  hr
  success "MP3 file ${nfile} is $(file.size.mb "${nfile}")Mb"
}

audio.file.mp3-to-wav() {
  local from="${1/.\//}"
  local destination="$2"

  if [[ -z ${destination} ]]; then
    destination="$(dirname "${from}")"
  else
    destination="${destination}/$(dirname "${from}")"
  fi

  local to="${destination}/$(basename "${from/.mp3/.wav}")"

  if [[ ${from} =~ ".mp3" ]]; then
    h.blue "Source:      ${from}"
    cursor.up 1
    h.green "Destination: ${to}"
    [[ -f "${to}" ]] && {
      info: "File already converted."
      return 0
    }
    run "mkdir -p \"${destination}\""
    run.set-next show-output-on
    run "lame --decode \"${from}\" \"${to}\""
  else
    error "File ${from} is not an MP3 file."
    return 1
  fi
}

# Usage: assume a folder with a bunch of MP3s in subfolders
# audio.dir.mp3-to-wav "MP3" "/Volumes/SDCARD"
#
# This will process all MP3 files and decode them into the
# same folder structure but under /Volumes/SDCARD.
#
audio.dir.mp3-to-wav() {
  local from="$1"
  local to="$2"

  run "cd \"${from}\""

  trap "return 1" INT

  while read -d '' filename; do
    audio.file.mp3-to-wav "${filename}" "${to}" </dev/null
  done < <(find . -type f -name "*.mp3" -print0)

  run "cd -"
}

æ.mp3() {
  audio.make.mp3 "$@"
}
