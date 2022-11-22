# vim: ft=bash
load test_helper

source lib/sedx.sh
source lib/util.sh
source lib/time.sh
source lib/is.sh
source lib/output.sh
source lib/output-repeat-char.sh
source lib/output-utils.sh
source lib/output-boxes.sh
source lib/runtime-config.sh
source lib/runtime.sh
source lib/run.sh

@test "inspect variables with names starting with LibRun" {
  set +e
  output=$(run.inspect-variables-that-are starting-with LibRun)
  code=$?
  set -e
  [[ "${code}" -eq 0 ]]
  [[ "${output}" =~ "LibRun__DryRun" ]]
  [[ "${output}" =~ "LibRun__Verbose" ]]
}

@test "print obfuscated variables without real data" {
  export MOO_NAME="Cow Moo"
  export MOO_SSN="121-344-2244"
  export MOO_EIN="X101343000"
  export MOO_DOB="2020/01/01"

  run.add-obfuscated-var MOO_SSN MOO_EIN

  set +e
  code=0
  output="$(run.inspect-variables-that-are starting-with MOO_)"
  code=$?

  [[ "${code}" -eq 0 ]] &&
  [[ "${output}" =~ "MOO_NAME" ]] &&
  [[ "${output}" =~ "MOO_SSN" ]] &&
  [[ "${output}" =~ "MOO_EIN" ]] &&
  [[ "${output}" =~ "MOO_DOB" ]] &&
  [[ ! "${output}" =~ "${MOO_SSN}" ]] &&
  [[ ! "${output}" =~ "${MOO_EIN}" ]] &&
  [[ "${output}" =~ "OBFUS" ]]
}

@test "run() with a successful command and defaults" {
  set +e
  run.set-next show-output-off
  output=$(run "/bin/ls -al")
  clean_output=$(ascii-clean $(printf "${output}"))
  code=$?
  set -e
  [[ "${code}" -eq 0 ]]
  [[ "${LibRun__LastExitCode}" -eq 0 ]]
  [[ ${clean_output} =~ 'ls -al' ]]
}

@test "run() with an unsuccessful command and defaults" {
  set +e
  run.set-next show-output-on 
  run "zhopa 2>/dev/null"
  code=$?
  [[ "${code}" -eq 120 ]] && [[ "${LibRun__LastExitCode}" -eq 120 ]] || set -e
}

@test "run() with a successful hidden command" {
  set +e
  run.set-next show-output-off show-command-off
  output=$(run "/bin/ls -al")
  clean_output=$(ascii-clean $(printf "${output}"))
  code=$?
  set -e
  [[ "${code}" -eq 0 ]]
  [[ "${LibRun__LastExitCode}" -eq 0 ]]
  [[ ${clean_output/\/bin\/ls/} == "${clean_output}" ]]
}


@test "! set.dry-run.on && is.dry-run.on " {
  set -e
  ! is.dry-run.on
  set.dry-run.on
  is.dry-run.on
}

@test "set.dry-run.on && is.dry-run.on" {
  set -e
  ! is.dry-run.on
  set.dry-run.on
  is.dry-run.on && is.dry-run.on
}

@test "set.dry-run.off && ! is.dry-run.on " {
  set -e
  ! is.dry-run.on
  set.dry-run.off
  is.dry-run.off && is.dry-run.off
}

@test "set.dry-run.off && ! is.dry-run.on" {
  set -e
  ! is.dry-run.on
  set.dry-run.off && ! is.dry-run.on
  set.dry-run.on && ! is.dry-run.off && is.dry-run.on
}

