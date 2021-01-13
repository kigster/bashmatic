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

video.convert.compress() {
  local file="$1"; shift
  local output=${file/\.*/.mkv}
  local ratio="${2:-"1"}"

  [[ "${file}" == "${output}" ]] && output="${output/\.mkv/-smaller-${ratio}.mkv}"
  
  h2 "Starting ffmpeg conversion from ${file} to ${output}" \
     "Source file size is $(file.size.mb ${file})"
  
  run.set-next show-output-on
  run "ffmpeg -stats -y -i ${file} -preset:v veryfast -loglevel error -c:v libx265 -crf 22 -c:a copy -vf 'scale=iw/3:ih/3' ${output}"
  
  local before=$(file.size ${file})
  local after=$(file.size ${output})
  local reduction=$(( 100 * ( before - after ) / before ))

  success "File ${output} was prodiced with ${reduction}% size savings."  
}
