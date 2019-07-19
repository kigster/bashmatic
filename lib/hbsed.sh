export LibSed__latestVersion=

hbsed() { 
  local current=$(which sed)
  local latest=${LibSed__latestVersion:-'/usr/local/bin/gsed'}
  local os=$(uname -s)

  if [[ ! -x "${latest}" ]]; then
    if [[ "${os}" == "Darwin" ]] ; then
      [[ -n $(which brew) ]] || return 1
      brew install gnu-sed 1>/dev/null 2>&1
      [[ -x "${latest}" ]] || latest="${current}"
    elif [[ "${os}" == "Linux" ]] ; then
      latest="${current}"
    fi
  fi

  latest=${latest:-${current}}

  ${latest} -E "$@"
}
