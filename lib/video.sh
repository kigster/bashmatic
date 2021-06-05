#!/usr/bin/env bash
# vim: ft=bash
# @copyright © 2016-2021 Konstantin Gredeskoul, All rights reserved
# @license MIT License.
# 
# @file lib/video.sh
# @description Video conversions routines.


# @description Installs ffmpeg
.ensure.ffmpeg() {

  is.a-command ffmpeg && return 0
  package.is-installed ffmpeg || { 
    warning "ffmpeg was not found, installing it..."
    package.install ffmpeg
  }

  is.a-command ffmpeg && return 0
  error "Can't find ffmpeg after installation."
  return 1
}

# ffmpeg -i input.mkv -vf "scale=iw/2:ih/2" half_the_frame_size.mkv
# ffmpeg -i input.mkv -vf "scale=iw/3:ih/3" a_third_the_frame_size.mkv
# ffmpeg -i input.mkv -vf "scale=iw/4:ih/4" a_fourth_the_frame_size.mkv

# @description Given two arguments (from), (to), performs a video recompression
.video.convert.compress-11() {
  run "ffmpeg -n -loglevel error -stats -i \"${1}\" -preset faster -c:v libx265 -crf 22 -c:a copy \"${2}\""
}

# @description Given two arguments (from), (to), performs a video recompression
.video.convert.compress-12() {
  run "ffmpeg -n -loglevel error -stats -i \"${1}\" -preset faster -c:v libx265 -crf 22 -c:a copy -vf 'scale=iw/2:ih/2' \"${2}\""
}

# @description Given two arguments (from), (to), performs a video recompression
.video.convert.compress-13() {
  run "ffmpeg -n -loglevel error -stats -i \"${1}\" -preset faster -c:v libx265 -crf 22 -c:a copy -vf 'scale=iw/3:ih/3' \"${2}\""
}

# @description Given two arguments (from), (to), performs a video recompression
.video.convert.compress-21() {
  run "ffmpeg -n -loglevel error -stats -i \"${1}\" -preset faster -vcodec libx264 -crf 28 -tune film \"${2}\""
}

# @description Given two arguments (from), (to), performs a video recompression
.video.convert.compress-22() {
  run "ffmpeg -n -loglevel error -stats -i \"${1}\" -preset faster -vcodec libx264 -crf 28 -tune film -vf 'scale=iw/2:ih/2' \"${2}\""
}

# @description Given two arguments (from), (to), performs a video recompression
.video.convert.compress-23() {
  run "ffmpeg -n -loglevel error -stats -i \"${1}\" -preset faster -vcodec libx264 -crf 28 -tune film -vf 'scale=iw/3:ih/3' \"${2}\""
}

# @description Given two arguments (from), (to), performs a video recompression
.video.convert.compress-3() {
  # https://unix.stackexchange.com/questions/28803/how-can-i-reduce-a-videos-size-with-ffmpeg
  # Here is a 2 pass example. Pretty hard coded but it really puts on the squeeze
  run "ffmpeg -y -i \"$1\" -c:v libvpx-vp9 -pass 1 -deadline best -crf 30 -b:v 664k -c:a libopus -f webm /dev/null && ffmpeg -i \"$1\" -c:v libvpx-vp9 -pass 2 -crf 30 -b:v 664k -c:a libopus -strict -2 \"$2\""
}

# @description Given two arguments (from), (to), performs a video recompression
#              according to the algorithm in the second argument.
#
# @example Use function ".video.convert.compress-13" to do the compression:
#              video.convert.compress bigfile.mov 13
video.convert.compress() {
  local file="$1"; shift
  local output=${file/\.*/.mkv}
  local algo="${1:-"11"}"

  [[ "${file}" == "${output}" ]] && output="${output/\.*/-converted-${ratio}.mkv}"

  is.an-existing-file "${output}" && { 
    info "File ${output} already exists, making a backup..."
    local t="$(time.now.db | tr -d ' ')"
    # shellcheck disable=SC2001
    local backup_output="$(echo "${output}" | sed "s/\.\(.*\)$/-${t}.\1/g")"
    info "Backing up a name clashing file to ${backup_output}..."
    run "mv \"${output}\" \"${backup_output}\""
  }

  h2 "Starting ffmpeg conversion, source file size is ${bldred}$(file.size.mb "${file}")" \
     " • Source:      [${file}]" \
     " • Destination: [${output}]" \
     " • Algorithm:   [#${algo}]" 

  .ensure.ffmpeg
  
  local func=".video.convert.compress-${algo}"

  is.a-function "${func}" || {
    error "${func} is not a valid function name."
    return 1
  }

  arrow.blk-on-ylw "Conversion Function: ${func}"

  local token=$(echo "${file}" | shasum.sha | cut -f 1 -d ' ')
  time.with-duration.start "${token}"

  arrow.wht-on-blu "Please wait while we compress this file... (set DEBUG=1 to see the output)"
  echo

  ((DEBUG)) && run.set-next show-output-on
  run "${func} \"${file}\" \"${output}\""
  
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


