[[ -z "${BASHMATIC_HOME}" ]] && {
  if [[ -d "${HOME}/.bashmatic" ]]; then
    export BASHMATIC_HOME={${HOME}/.bashmatic}
  else
    export BASHMATIC_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
  fi
}

init="${BASHMATIC_HOME}/init.sh"
[[ -s ${init} ]] && source "${init}" || true
