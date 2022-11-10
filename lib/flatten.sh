#!/usr/bin/env bash
# vim: ft=bash:

# @author:	Konstantin Gredeskoul
# @since: 	07/19/2021

# @description FLATTEN FILE TREE

# @description Given a long path to a file, possibly with spaces in cluded
#     and a desintation as a second argument, generates a flat pathname and
#     copies the first argument there.
# @example
#     ❯ tree -Q "33 Retro Synth/"
#     "33 Retro Synth/"
#     ├── "001 Retro Synth - A Synth Primer.en.srt"
#     ├── "001 Retro Synth - A Synth Primer.mp4"
#     ├── "002 Retro Synth - Oscillator.en.srt"
#     └── "002 Retro Synth - Oscillator.mp4"
#     ❯
#     flatten-file "33 Retro Synth/001 Retro Synth - A Synth Primer.mp4"
# @arg1 -n | --dry-run (optional)
# @arg2 source path
# @arg3 dest paths
function flatten-file() {
  local path="$1"
  local dest="${2}"

  [[ ${dest[-1]} == "/" ]] && dest="${dest:0:-1}"

  errors=()

  [[ -f "${path}" ]] || errors+=("File [${path}] was not found.")
  [[ -d "${dest}" ]] || errors+=("Directory [${dest}] does not exist.")

  [[ ${#errors[@]} -eq 0 ]] || {
    error "${errors[@]}">&2
    return 1
  }

  local target
  local space=" "
  local enclosing="$(dirname "$(dirname "${path}")")"
  target="$(echo "$(dirname "${path}")"—"$(basename "${path}")" | sed -E "s/[${space}_]/-/g;")"
  target="${dest} ${bldred}${target/${enclosing/\/}}"
  
  #  s/\//${space}•${space}/g; s/[_\/]/${space}/g;")"

  if ((flag_verbose)) ; then
    inf "COPY: ${bldgrn}\"${path}\" ➔ [${bldylw}\"${target}${bldgrns}\"]">&2
  else
    printf "${txtblu}">&2
  fi
  
  local command="cp -v \"${path}\" ${bldylw}\"${target}\""
  printf -- "${command}"
  return 0
}

