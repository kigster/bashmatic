export LibSed__TargetVersion=

hbsed() {
  local target=${LibSed__TargetVersion:-'/usr/local/bin/gsed'}
  local os=$(uname -s)
  [[ ! -x ${target} && ${os} == "Darwin" ]] && ( brew install gnu-sed --force --fast ) 2>&1 | cat > /dev/null
  [[ ! -x ${target} && ${os} == "Linux" ]] && target=$(which sed)

  [[ -x ${target} ]] || return 1

  ${target} -E "$@"
}
