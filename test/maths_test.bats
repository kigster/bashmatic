#!/usr/bin/env bats
load test_helper
source lib/maths.sh

@test "maths.eval pi" {
  local result="$(maths.eval 'π')"
  [[ "${result}" == "3.14159" ]]
}

@test "maths.eval square root of PI" {
  local result="$(maths.eval '(π)' 10)"
  [[ "${result}" == "3.14159" ]]
}

@test "maths.eval √(57)*⅓×(sin(π÷(1.3)))I" {
  local result="$(maths.eval '√(57)*⅓×(sin(π÷(1.3)))')"
  [[ "${result}" == "1.66882" ]]
}

@test "maths.eval square root of PI" {
  local result="$(maths.eval '5!×(ｅ)')"
  [[ "${result}" == "326.19382" ]]
}
