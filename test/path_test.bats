#!/usr/bin/env bats

load test_helper

source lib/util.sh
source lib/array.sh
source lib/output.sh
source lib/path.sh
source lib/is.sh
source lib/file.sh
source lib/time.sh
set -e


@test "path.temp" {
  file=$(file.temp) 
  touch ${file}
  [[ -f ${file} ]]
}

@test "path.dirs from STDIN" {
  local p1="/bin:/Users/kig/bin:/usr/bin:/bin:/sbin"
  local p2="/bin:a:b:c"
  local p3="/bin:/usr/local/bin"
  for p in $p1 $p2 $p3; do
    [ "$(echo $p | path.dirs | head -1)" == "/bin" ]
  done
}

@test "path.dirs from ARG" {
  local p1="/bin:/Users/kig/bin:/usr/bin:/bin:/sbin"
  local p2="/bin:a:b:c"
  local p3="/bin:/usr/local/bin"
  for p in $p1 $p2 $p3; do
    [ "$(path.dirs $p | head -1)" == "/bin" ]
  done
}

@test "path.dirs from PATH" {
  path.dirs ${PATH} | grep -q '^/usr/bin$'
}

@test "path.strip-slash" {
  local p1="/Users/kig/"
  local p2="/Users/kig"
  local p3="/Users/kig///"
  for p in $p1 $p2 $p3; do
    [ "$(path.strip-slash $p)" == "/Users/kig" ]
  done
}

@test "path.size" {
  local LONG="/bin:/bin:/usr/local/bin:/usr/bin:/bin"
  [ "$(path.dirs.size "${LONG}")" -eq 5 ]
}

@test "path.dirs.uniq" {
  local LONG="/bin:/bin:/usr/local/bin:/usr/bin:/bin:"
  [ "$(path.dirs.uniq "${LONG}" | wc -l | tr -d ' ')" -eq 3 ]
}

@test "path.mutate.uniq" {
  export OLD_PATH="${PATH}"
  export PATH="/bin:/bin:/usr/local/bin:/usr/bin:/bin:"
  [[ $(path.dirs.size "${PATH}") -eq 5 ]] 
  path.mutate.uniq
  [[ $(path.dirs.size "${PATH}") -eq 3 ]] && {
    export PATH="${OLD_PATH}" || true
  }
}

@test "path.mutate.append" {
  export OLD_PATH="${PATH}"
  export PATH="/bin:/bin:/usr/local/bin:/usr/bin:/bin:"
  export TEST_PATH="${PATH}"
  path.mutate.append /sbin
  [[ "${PATH}" == "${TEST_PATH}:/sbin" ]] && {
    export PATH="${OLD_PATH}" || true
  }
}

@test "path.mutate.delete" {
  export TEST_PATH="/bin:/usr/local/bin:/sbin:/usr/bin:/bin:/Users/kig/bin"
  export TEST_PATH=$(path.dirs.delete "${TEST_PATH}" /Users/kig/bin /sbin)

  [ "${TEST_PATH}" == "/bin:/usr/local/bin:/usr/bin:/bin" ]
}

@test "path.mutate.prepend" {
  set -e
  export OLD_PATH="${PATH}"
  export PATH="/bin:/bin:/usr/local/bin:/usr/bin:/bin:"
  export TEST_PATH="${PATH}"
  path.mutate.prepend /sbin
  [[ "${PATH}" =~ ^/sbin ]] && {
    export PATH="${OLD_PATH}" || true
  }
}
