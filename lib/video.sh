#!/usr/bin/env bash
# vim: ft=bash
# @copyright © 2016-2021 Konstantin Gredeskoul, All rights reserved
# @license MIT License.
# 
# @file lib/video.sh
# @description Video conversions routines.

declare -a required_packages
export required_packages=(node@14 ffmpeg)
export ffmpeg_binary="ffmpeg"

# @description Installs ffmpeg
.video.install-deps() {
  for package in "${required_packages[@]}"; do
    package.install "${package}" || return 1
  done

  [[ -z $(which ffmpeg-bar) ]] && run "npm install --global ffmpeg-progressbar-cli"

  if (command -v ffmpeg-bar >/dev/null); then
    export ffmpeg_binary="ffmpeg-bar "
  else
    export ffmpeg_binary="ffmpeg-y -loglevel error -stats "
  fi

  return 0
}

.video.ffmpeg-run() {
  local cmd="${ffmpeg_binary} $*"
  ((DEBUG)) && h1 "Executing Command:" "${cmd}"
  eval "${cmd}"
}

# @description Named after the author of a similar tool that does this:
# @url https://coderunner.io/shrink-videos-with-ffmpeg-and-preserve-metadata/
.video.convert.compress-shrinkwrap() {
  .video.ffmpeg-run -i "${1}" \
     -preset fast -copy_unknown -map_metadata 0 -map 0 \
     -codec copy -codec:v libx265 -pix_fmt yuv420p -crf 23 \
     -codec:a copy -vbr 4 "${2}"
}

# \"${ffmpeg_binary}\" -i input.mkv -vf "scale=iw/2:ih/2" half_the_frame_size.mkv
# \"${ffmpeg_binary}\" -i input.mkv -vf "scale=iw/3:ih/3" a_third_the_frame_size.mkv
# \"${ffmpeg_binary}\" -i input.mkv -vf "scale=iw/4:ih/4" a_fourth_the_frame_size.mkv

# @description Given two arguments (from), (to), performs a video recompression
.video.convert.compress-11() {
  local file="$1"; shift
  .video.ffmpeg-run -y -i "${file}" -preset faster -c:v libx265 -crf 22 -c:a copy "$@"
}

# @description Given two arguments (from), (to), performs a video recompression
.video.convert.compress-12() {
  .video.ffmpeg-run -y -i "${1}" -preset faster -c:v libx265 -crf 22 -c:a copy -vf 'scale=iw/2:ih/2' "${2}"
}

# @description Given two arguments (from), (to), performs a video recompression
.video.convert.compress-13() {
  .video.ffmpeg-run -y -i "${1}" -preset faster -c:v libx265 -crf 22 -c:a copy -vf 'scale=iw/3:ih/3' "${2}"
}

# @description Given two arguments (from), (to), performs a video recompression
.video.convert.compress-21() {
  .video.ffmpeg-run -y -i "${1}" -preset faster -vcodec libx264 -crf 28 -tune film "${2}"
}

# @description Given two arguments (from), (to), performs a video recompression
.video.convert.compress-22() {
  .video.ffmpeg-run -y -i "${1}" -preset faster -vcodec libx264 -crf 28 -tune film -vf 'scale=iw/2:ih/2' "${2}"
}

# @description Given two arguments (from), (to), performs a video recompression
.video.convert.compress-23() {
  .video.ffmpeg-run -y -i "${1}" -preset faster -vcodec libx264 -crf 28 -tune film -vf 'scale=iw/3:ih/3' "${2}"
}

# @description Given two arguments (from), (to), performs a video recompression
.video.convert.compress-3() {
  # https://unix.stackexchange.com/questions/28803/how-can-i-reduce-a-videos-size-with-ffmpeg
  # Here is a 2 pass example. Pretty hard coded but it really puts on the squeeze
  .video.ffmpeg-run -y -i "$1" -c:v libvpx-vp9 -pass 1 -deadline best -crf 30 -b:v 664k -c:a libopus -f webm /dev/null && \
    .video.ffmpeg-run -y -i "$1" -c:v libvpx-vp9 -pass 2 -crf 30 -b:v 664k -c:a libopus -strict -2 "$2"
}

# @description Given two arguments (from), (to), performs a video recompression
#              according to the algorithm in the second argument.
#
# @example Use function ".video.convert.compress-13" to do the compression:
#              video.convert.compress bigfile.mov 13
video.convert.compress() {
  local file="$1"; shift
  local algo="${1:-"11"}"; shift
  local output="${1:-"${file/\.*/.mkv}"}"; shift

  [[ "${file}" == "${output}" ]] && output="${output/\.*/-converted-${ratio}.mkv}"

  is.an-existing-file "${output}" && { 
    info "File ${output} already exists, making a backup..."
    local t="$(time.now.db | tr -d ' ')"
    # shellcheck disable=SC2001
    local backup_output="$(echo "${output}" | sed "s/\.\(.*\)$/-${t}.\1/g")"
    info "Backing up a name clashing file to ${backup_output}..."
    run "mv \"${output}\" \"${backup_output}\""
  }

  h2 "Starting \"${ffmpeg_binary}\" conversion, source file size is ${bldred}$(file.size.mb "${file}")" \
     " • Source:      [${file}]" \
     " • Destination: [${output}]" \
     " • Algorithm:   [${algo}]" 

  .video.install-deps
  
  local func=".video.convert.compress-${algo}"

  is.a-function "${func}" || {
    error "${func} is not a valid function name."
    return 1
  }

  arrow.blk-on-ylw "Conversion Function: ${func}"
  arrow.blk-on-blu "Source File:         \"${file}\""
  arrow.blk-on-grn "Destination File:    \"${output}\""

  local token=$(echo "${file}" | shasum.sha | cut -f 1 -d ' ')
  time.with-duration.start "${token}"

  info "Please wait while we compress this file... (set DEBUG=1 to see the output)"
  echo

  run.set-all show-output-on abort-on-error
  ${func} "${file}" "${output}"
  run.set-all show-output-off
  
  local before="$(file.size "${file}")"
  local after="$(file.size "${output}")"
  local reduction=
  local duration=$(time.with-duration.end "${token}")
  if [[ ${before} -lt ${after} ]] ; then
    reduction=$(( 100 * ( after - before ) / before ))
    warning "${output} was generated with ${reduction}%% increase in file size" \
            "from ${before} to ${after}" \
            "and took ${duration}"
  else
    reduction=$(( 100 * ( before - after ) / before ))
    success "${output} was generated with ${reduction}%% reduction in file size" \
            "from ${before} to ${after}" \
            "and took ${duration}"
  fi

  return 0
}


video-squeeze() {
  [[ -z "$*" ]] && {
    printf --  "${bldgrn}USAGE:\n    ${bldylw}[ DEBUG=1 ] video-squeeze *.mp4 *.m4v${clr}\n"
    return 0
  }

  for file in "$@"; do
    [[ -s "${file}" ]] || { 
      warning "Skipping ${file}..."
      continue
    }

    arrow.blk-on-blu "Compressing \"${file}\""
    video.convert.compress "${file}" 
  done
} 


.destination-file-name() {
  local source="$1"
  local dest
  if [[ "${source}" =~ " " ]]; then
    dest="$(echo "${source}" | sed -E 's/\.(.*)$/ (Compressed).\1/g')"
  else
    dest="$(echo "${source}" | sed -E 's/\.(.*)$/-compressed.\1/g')"
  fi
  printf -- "%s" "${dest}"
}

video-shrink() {
  [[ -z "$*" ]] && {
    printf --  "${bldgrn}USAGE:\n    ${bldylw}[ DEBUG=1 ] video-shrink *.mp4${clr}\n"
    return 0
  }

  for file in "$@"; do
    [[ -s "${file}" ]] || { 
      warning "Skipping ${file}..."
      continue
    }
    dest="$(.destination-file-name "${file}")"
    h1 "Compressing \"${file}\"" "To \"${dest}\""
    video.convert.compress "${file}" "shrinkwrap" "${dest}" 
  done
} 



