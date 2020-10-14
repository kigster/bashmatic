#!/usr/bin/env bats

load test_helper

source lib/util.sh
source lib/array.sh
source lib/path.sh
source lib/is.sh
set -e

@test "path.size" {
  local LONG="/bin:/bin:/usr/local/bin:/usr/bin:/bin"
  [ "$(path.size "${LONG}")" -eq 5 ]
}

@test "path.uniqify" {
  local LONG="/bin:/bin:/usr/local/bin:/usr/bin:/bin:"
  [ "$(path.uniqify "${LONG}")" == "/bin:/usr/local/bin:/usr/bin:" ]
}

@test "path.add" {
  OLD_PATH="${PATH}"
  export PATH="/bin:/bin:/usr/local/bin:/usr/bin:/bin:"
  result=$(path.add /sbin)
  export PATH="${OLD_PATH}"
  [ "${result}" == "/bin:/bin:/usr/local/bin:/usr/bin:/bin:/sbin" ]
  #[ "${PATH}" == "/bin:/usr/local/bin:/usr/bin:/sbin:" ]
}

@test "path.append" {
  local dir="/tmp/executables.$$"
  local bin="${dir}/binary"
  mkdir -p "${dir}"   
  echo "#!/bin/bash\necho it works" >"${bin}"
  chmod 755 ${bin}

  local program=$(basename "${bin}")

  [[ -z $(command -v "${program}" 2>/dev/null) ]]

  path.append "${dir}"

  [[ -n $(command -v "${program}" 2>/dev/null) ]]

  run -f "${dir}"
}

