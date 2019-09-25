

__load() {
  local len="${#BASH_SOURCE[@]}"
  local last_index=$(( len - 1 ))
  local script="${BASH_SOURCE[${last_index}]}"
  local dir=$(cd $(dirname ${script}); pwd -P)
  local init=$(dirname ${dir})/init.sh
 
  [[ -f "${init}" ]] && source "${init}"
}

__load
