#!/usr/bin/env bash
# vim ft: bash
util.ensure-gnu-sed() {
  local sed_path
  local gsed_path

  util.os
  case "${BASHMATIC_OS}" in
  darwin)
    gsed_path="$(command -v gsed 2>/dev/null)"
    if [[ -z "${gsed_path}" ]]; then
      echo
      h3 "Please wait while we install gnu-sed using Brew..." \
         "It's a required dependency for many key features." 1>&2

      ( brew install gnu-sed --force --quiet && brew unlink gnu-sed ; brew link gnu-sed --overwrite) 1>&2 >/dev/null

      hash -r 2>/dev/null
      gsed_path="$(command -v gsed 2>/dev/null)"
      [[ -z ${gsed_path} && -x /usr/local/bin/gsed ]] && gsed_path="/usr/local/bin/gsed"
    fi

    [[ -n "${gsed_path}" && -x "${gsed_path}" ]] || {
      error "Can't find GNU sed even after installation." >&2
    }

    sed_path="${gsed_path}"
    ;;
  *)
    sed_path="$(command -v sed)"
    ;;
  esac

  echo -n "${sed_path}"
}

export bashmatic__sed_command

# This function ensures we have GNU sed installed, and if not,
# uses Brew on a Mac to install it.
#
# It is used by sedx() function
#———————————————————————————————————————————————————————
function sedx.cache-command() {
  local sed_path="$(util.ensure-gnu-sed)"
  [[ -x "${sed_path}" ]] || sed_path="$(command -v gsed || command -v sed)"
  export bashmatic__sed_command="${sed_path}"
}

function sedx() {
  [[ -z ${bashmatic__sed_command} ]] && sedx.cache-command
  [[ -z ${bashmatic__sed_command} ]] && {
    warning "Can't determine determine advanced sed location, using regular sed." >&2
    export bashmatic__sed_command="/usr/bin/sed"
  }
  ${bashmatic__sed_command} -E "$@"
}



