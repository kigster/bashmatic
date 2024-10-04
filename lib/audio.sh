#!/usr/bin/env bash
# vim: ft=bash
# @copyright © 2016-2024 Konstantin Gredeskoul, All rights reserved
# @license MIT License.
#
# @file lib/audio.sh
# @description Audio conversions routines.

function audio.m4a.to.mp3() {
  local file="$1"
  [[ -z "${file}" ]] && return 0
  [[ -f "${file}" ]] || { 
    error "File does not exist: ${file}"
    return 1
  }
  local output="${file/\.m4a/.mp3}"
  [[ -s ${output} ]] && {
    info "${file} has already been converted... Skipping."
    return 0
  }

  h1 "From: ${bldylw}${file} " "To:   ${bldblu}${output}"
  command -v ffmpeg >/dev/null || video.install.dependencies
  local cmd="ffmpeg -i \"${file}\" -codec:a libmp3lame -qscale:a 1 \"${output}\""
  h2 "${cmd}"
  run "${cmd}"
}


function audio.m4as.to.mp3s() {
  folder="${1:-"."}"
  info "Converting the following files:"
  find "${folder}" -name '*.m4a'  
  hr; echo
  info "Ctrl-C to abort."
  echo
  find "${folder}" -name '*.m4a' -exec bash -c 'source ~/.bashmatic/init.sh; audio.m4a.to.mp3 "{}"' \;
}

# @description Given a music audio file, determine its frequency.
audio.file.frequency() {
  local file="$1"
  [[ -z $(command -V mdls) ]] && return 1
  local frequency=$(mdls "${file}" | grep kMDItemAudioSampleRate | sed 's/.*= //g')
  [[ -z ${frequency} ]] && frequency=48000
  local kHz=$(maths.eval "${frequency} / 1000.0" 0)
  printf "${kHz}"
}

audio.make.mp3.usage() {
  usage-box "audio.wav-to-mp3 [ file.wav | file.aif | file.aiff ] [ file.mp3 ] © Convert a RAW PCM Audio to highest quality MP3" \
    "You can pass additional flags to ${txtylw}lame" "" \
    "Just run ${txtylw}lame --longhelp for more info." "" \
    "Default Flags: ${default_options}" ""
}

_term() {
  info "Interrupt received, aborting..."
  if [[ -n ${child_pid} ]]; then
    kill -INT "$child_pid" 2>/dev/null
    kill -TERM "$child_pid" 2>/dev/null
  fi
}

export child_pid=

# @description Given a folder of MP3 files, and an optional KHz specification, 
#              perform a sequential conversion from AIF/WAV format to MP3.
# @example 
#              audio.wav-to-mp3 [ file.wav | file.aif | file.aiff ] [ file.mp3 ]
audio.make.mp3s() {
  local dir="${1:-"."}"
  local kHz="${2:-"48"}"

  local first="$(find "${dir}" -type f -a \( -name "*.aif*" -o -name "*.wav" \) -print | head -1)"

  h3 "Converting WAV and AIF files to MP3 in ${txtylw}${dir}."

  if [[ -z ${first} ]]; then
    error "No AIFF or WAV files in the folder ${bldgrn}${dir}"
    return 1
  fi

  inf "Determining audio sampling rate (will apply the same rate to all files)... "
  kHz=$(audio.file.frequency "${first}")
  printf "${bldgrn} — ${kHz}kHz"
  ok:

  SAVEIFS=$IFS

  run.set-all show-command-on show-output-off abort-on-error

  find "${dir}" -type f -a \( -name "*.aif*" -o -name "*.wav" \) -print0 | while read -d $'\0' file; do
    local fn=$(ascii-clean "${file}")
    mp3=$(echo "${file}" | sedx 's/\.(wav|aiff?)$/.mp3/g')

    inf "checking ${txtylw}${file} $(txt-info) ... "

    if [[ -f "${mp3}" && -z "${FORCE}" ]]; then
      printf "${bldgrn} OK, already converted. Use FORCE=1 to overwrite. ${clr}"
      ok:
      continue
    fi

    printf "${txtcyn} Transcoding...${clr}"
    ui.closer.kind-of-ok:

    inf "❯ ${txtylw}lame --silent -m s -b 320  \"${file}\""

    trap _term SIGINT
    lame --silent -m s -b 320 "${fn}" &
    child_pid=$!
    wait "$child_pid"

    code=$?
    if [[ ${code} -ne 0 ]]; then
      ui.closer.not-ok:
      info "${bakred}${bldwht}  ERROR: lame exited with an error code ${code}. Aborting!  "
      [[ -f "${mp3}" ]] && {
        info "NOTE: removing unfinished MP3 file ${mp3}."
        rm -f "${mp3}" 1>&2 >/dev/null
      }
      break
    else
      ok:
    fi
  done

  success 'All done.'
}

# @description Converts one AIF/WAV file to high-rez 320 Kbps MP3
audio.make.mp3() {
  local file="$1"
  shift
  local nfile="$2"
  shift

  set +e

  [[ -n "$(command -V lame)" ]] || brew.package.install lame

  local default_options=" -m s -b 320 "

  [[ -n "${file}" ]] || {
    audio.make.mp3.usage && return 1
  }

  [[ -s "${file}" ]] || {
    error "File '${file}' does not exist."
    audio.make.mp3.usage && return 2
  }

  [[ -z ${nfile} ]] && nfile="$(echo "${file}" | sedx 's/\.(wav|aiff?)$/\.mp3/g')"

  local khz=$(audio.file.frequency "${file}")
  h2 "'$(basename "${file}")' —❯ ${txtylw}${nfile}${txtgrn}, sample rate: ${khz:-'Unknown'}kHz"
  info "lame ${default_options} $* '${file}' '${nfile}'"
  run.set-next show-output-on abort-on-error
  run "lame ${default_options}  $* '${file}' '${nfile}'"
  hr

  success "MP3 file ${nfile} is $(file.size.mb "${nfile}")Mb"
}

# @description Converts one AIF/WAV file to high-rez 320 Kbps MP3
æ.mp3() {
  audio.make.mp3 "$@"
}

# @description Decodes a folder with MP3 files back into WAV
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

# @description assume a folder with a bunch of MP3s in subfolders
#
# @example This will process all MP3 files and decode them into the
#          same folder structure but under /Volumes/SDCARD.
#
#          audio.dir.mp3-to-wav "MP3" "/Volumes/SDCARD"
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


# @description Rename function for one filename to another.
#              This particular function deals with files of this format:
#              Downloaded from karaoke-version.com:
# @example
#              .audio.karaoke.format "Michael_Jackson_Billie_Jean(Drum_Backing_Track_(Drum_only))_248921.wav"
#              => michael_jackson_billie_jean——drum_backing_track-drum_only.wav
.audio.karaoke.format() {
  echo "$*" | sedx 's/([a-zA-Z_]*)([^a-zA-Z_])(.*)$/\1——\3/g; s/_([0-9]*)[^_]\.wav/\.wav/g' | sedx 's/\)?\(([a-zA-Z_]*)\)\)/--\1/g' | sedx 's/(\(|\)|_-|_—)//g' | tr '[:upper:]' '[:lower:]'
}

# @description This function receives a format specification, and an optional
#              directory as a second argument. Format specification is meant to 
#              map to a function .audio.<format>.format that's used as follows:
#              .audio.<format>.format "file-name" => "new file name" 
# @example 
#              audio.dir.rename-wavs karaoke ~/Karaoke
audio.dir.rename-wavs() {
  local format="$1"; shift
  local func=".audio.${format}.format"

  is.a-function "${func}" || { 
    error "Format not recognized: ${format}" \
    "usage: audio.dir.rename-wavs <renaming-scheme> [ optional-dir ]"
    return 1
  }

  local dir="$1"
  local pwd="$(pwd -P)"
  if [[ -n "${dir}" ]]; then
    [[ ! -d "${dir}" ]] && {
    error "First argument is either blank (current directory)" \
      "or the folder where *.wav files to be renamed are."
      return 1
    }
    cd "${dir}" || exit
  fi

  local nfile
  for file in $(ls -1 '*.wav'); do
     n="$(.audio.karaoke.format "${file}" | sed 's/—/_/g')"
     h1 "${file}" "${n}"
     run "mv -vn \"${file}\" \"${n}\"";  
  done

  run "cd \"${pwd}\""
}

# @description Renames wav files in the current folder (or the folder 
#              passed as an argument, based on the naming scheme downloaded
#              from karaoke-version.com
# @example 
#              audio.dir.rename-karaoke-wavs "~/Karaoke"
#
audio.dir.rename-karaoke-wavs() {
  audio.dir.rename-wavs karaoke "$@"
}



