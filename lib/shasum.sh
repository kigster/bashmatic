#!/usr/bin/env bash
# @brief SHA Functions
# @description SHASUM related functions, that compute SHA for a single file,  
#   collection of files, or entire directories.
# @file shasum.sh
export __default_bashmatic__sha_command="/usr/bin/env shasum"

source "${BASHMATIC_HOME}/lib/is.sh"

# @description 
#   Override the default SHA command and alogirthm
#   Default is shasum -a 256
shasum.set-command() {
  export __bashmatic__sha_command="$*"
}

# @description Override the default SHA algorithm
# @example
#     $ shasum.set-algo 256
#
shasum.set-algo() {
  local algo="${1:-1}"  
  export __bashmatic__sha_command="${__default_bashmatic__sha_command} -a ${algo}"
}

shasum.set-algo 1

.sha() {
  eval "${__bashmatic__sha_command} $*"
}

.sha-only() {
  .sha "$@" | cut -d' ' -f 1
}

# @description Compute SHA for all given files, ignore STDERR
#              NOTE: first few arguments will be passed to the
#              shasum command, or whatever you set via shasum.set-command.
shasum.sha() {
  .sha "$@" 2>/dev/null
}

# @description Print SHA ONLY removing the file components
shasum.sha-only() {
  .sha-only "$@" 2>/dev/null
}

# @description Print SHA ONLY removing the file components
shasum.sha-only-stdin() {
  echo "$*" | eval "${__bashmatic__sha_command}"  | cut -d' ' -f 1
}

is.a-function bashmatic.bash.version-four-or-later || source "${BASHMATIC_HOME}"/lib/bashmatic.sh

if bashmatic.bash.version-four-or-later; then

# @description This function populates a pre-declare associative array with
#              filenames mapped to their SHAs, but only in the current directory
#              Call `dbg-on` to enable additional debugging info.
# @example
#     $ declare -A file_shas
#     $ shasum.to-hash file_shas $(find . -type f -maxdepth 2)
#     $ echo "Total of ${#file_shas[@]} files in the hash"
# 
function shasum.to-hash() {
  local hash_name="$1"
  shift
  local index=0
  local last_sha
  for file in $(shasum.sha "$@"); do
    index=$((index + 1))
    if [[ $((index % 2)) == 0 ]]; then
      is-dbg && info "${last_sha} <- ${bldpur}${file}"
      eval "${hash_name}['${file}']=${last_sha}"
    else
      last_sha="${file}"
    fi
  done

  is-dbg && {
    local count=$((index / 2))
    eval "local size=\${#${hash_name}[@]}"
    h.yellow "Total ${count} files, ${size} hash entries in a Hash Variable '${hash_name}'"
  }
  return
}

fi

# @description For a given array of files, sort them, take a SHA of each file,
#    and return a single SHA finger-printing this set of files. #
#    NOTE: the files are sorted prior to hashing, so the return SHA
#    should ONLY change when files are either changed, or added/removed.
#    Only computes SHA of the files provided, does not recurse into folders
# @example 
#    $ shasum.all-files *.cpp
shasum.all-files() {
  shasum.sha "$@" | awk '{print $2 " " $1}' | sort | .sha-only
}

# @description For a given directory and an optional file pattern, 
#              use `find` to grab every single file (that matches optional pattern)
#              and return a single SHA
# @example 
#       $ shasum.all-files-in-dir . '*.pdf'
#       cc35aad389e61942c75e111f1eddbe634d74b4b1
shasum.all-files-in-dir() {
  local dir="$1"; shift
  local name_pattern="$1"; shift
  [[ -n ${name_pattern} ]] && name_pattern=" -name \"${name_pattern}\""
  # shellcheck disable=2046
  shasum.sha $(eval "find \"${dir}\" -type f ${name_pattern}" ) | awk '{print $2 " " $1}' | sort | .sha-only
}

# @description sha256 
function sha() {
  if output.has-stdin; then
    shasum -a 256 "$@" | cut -d ' ' -f 1
  else
    shasum -a 256 "$@" | cut -d ' ' -f 1
  fi
}



