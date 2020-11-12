[[ -z "${BASHMATIC_HOME}" ]] && {
  if [[ -d "${BASHMATIC_HOME}" ]]; then
    export BASHMATIC_HOME={${BASHMATIC_HOME}}
  else
    export BASHMATIC_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
  fi
}

init="${BASHMATIC_HOME}/init.sh"
[[ -s ${init} ]] && source "${init}" || true
