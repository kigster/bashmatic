#!/usr/bin/env bash
# vim: ft=bash
# @copyright © 2016-2021 Konstantin Gredeskoul, All rights reserved
# @license MIT License.
# 
# @file is.sh
# @description video conversions


# Installs ffmpeg
.ensure.ffmpeg() {

  is.a-command ffmpeg && return 0
  package.is-installed ffmpeg || package.install ffmpeg
  is.a-command ffmpeg && return 0

  error "Can't find ffmpeg after installation."
  return 1
}

# ffmpeg -i input.mkv -vf "scale=iw/2:ih/2" half_the_frame_size.mkv
# ffmpeg -i input.mkv -vf "scale=iw/3:ih/3" a_third_the_frame_size.mkv
# ffmpeg -i input.mkv -vf "scale=iw/4:ih/4" a_fourth_the_frame_size.mkv

.video.convert.compress-11() {
  run "ffmpeg -n -loglevel error -stats -i \"${1}\" -preset faster -c:v libx265 -crf 22 -c:a copy \"${2}\""
}

.video.convert.compress-12() {
  run "ffmpeg -n -loglevel error -stats -i \"${1}\" -preset faster -c:v libx265 -crf 22 -c:a copy -vf 'scale=iw/2:ih/2' \"${2}\""
}

.video.convert.compress-13() {
  run "ffmpeg -n -loglevel error -stats -i \"${1}\" -preset faster -c:v libx265 -crf 22 -c:a copy -vf 'scale=iw/3:ih/3' \"${2}\""
}

.video.convert.compress-21() {
  run "ffmpeg -n -loglevel error -stats -i \"${1}\" -preset faster -vcodec libx264 -crf 28 -tune film \"${2}\""
}

.video.convert.compress-22() {
  run "ffmpeg -n -loglevel error -stats -i \"${1}\" -preset faster -vcodec libx264 -crf 28 -tune film -vf 'scale=iw/2:ih/2' \"${2}\""
}

.video.convert.compress-23() {
  run "ffmpeg -n -loglevel error -stats -i \"${1}\" -preset faster -vcodec libx264 -crf 28 -tune film -vf 'scale=iw/3:ih/3' \"${2}\""
}

.video.convert.compress-3() {
  # https://unix.stackexchange.com/questions/28803/how-can-i-reduce-a-videos-size-with-ffmpeg
  # Here is a 2 pass example. Pretty hard coded but it really puts on the squeeze
  run "ffmpeg -y -i \"$1\" -c:v libvpx-vp9 -pass 1 -deadline best -crf 30 -b:v 664k -c:a libopus -f webm /dev/null && ffmpeg -i \"$1\" -c:v libvpx-vp9 -pass 2 -crf 30 -b:v 664k -c:a libopus -strict -2 \"$2\""
}

video.convert.compress() {
  local file="$1"; shift
  local output=${file/\.*/.mkv}
  local algo="${2:-"1"}"

  [[ "${file}" == "${output}" ]] && output="${output/\.mkv/-smaller-${ratio}.mkv}"
  
  h2 "Starting ffmpeg conversion from ${file} to ${output}, with algorithm #${ratio}" \
     "Source file size is $(file.size.mb ${file})"
  
  run.set-next show-output-on
  local func=".video.convert.compress-${algo}"
  run "${func} \"${file}\" \"${output}\""
  
  local before="$(file.size "${file}")"
  local after="$(file.size "${output}")"
  local reduction=$(( 100 * ( before - after ) / before ))

  success "File ${output} was prodiced with ${reduction}% size savings."  
}


