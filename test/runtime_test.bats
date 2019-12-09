load test_helper

source lib/output.sh
source lib/runtime.sh

@test "run() with a successful command and defaults" {
  set +e
  run::set-next show-output-off
  output=$(lib::run "/bin/ls -al")
  clean_output=$(ascii-clean $(printf "${output}"))
  code=$?
  set -e
  [[ "${code}" -eq 0 ]]
  [[ "${LibRun__LastExitCode}" -eq 0 ]]
  [[ ${clean_output} =~ 'ls -al' ]]
}

@test "run() with a successful hidden command" {
  set +e
  run::set-next show-output-off show-command-off
  output=$(lib::run "/bin/ls -al")
  clean_output=$(ascii-clean $(printf "${output}"))
  code=$?
  set -e
  [[ "${code}" -eq 0 ]]
  [[ "${LibRun__LastExitCode}" -eq 0 ]]
  [[ -z ${clean_output} ]]
}

@test "run() with an unsuccessful command and defaults" {
  set +e
  lib::run lssdf
  code=$?
  set -e
  [[ "${code}" -eq 127 ]]
}

@test "inspect variables with names starting with LibRun" {
  set +e
  output=$(lib::run::inspect-variables-that-are starting-with LibRun)
  code=$?
  set -e
  [[ "${code}" -eq 0 ]]
  [[ "${output}" =~ "LibRun__DryRun" ]]
  [[ "${output}" =~ "LibRun__Verbose" ]]
}
