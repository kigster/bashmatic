#!/usr/bin/env bash
# vim: ft=bash
#
# Bashmatic Utilities
# © 2016-2024 Konstantin Gredeskoul, All rights reserved. MIT License.
# Distributed under the MIT LICENSE.

# IMPORTANT: Overrride this variable if your tests are located in a different folder, eg 'specs'
# shellcheck disable=2046

export BATS_SOURCES_CORE="https://github.com/bats-core/bats-core.git"
# readonly BATS_SOURCES_SUPPORT="https://github.com/bats-core/bats-support"

# shellcheck source=./../../lib/color.sh
source "${BASHMATIC_HOME}/init.sh"

export DEFAULT_MIN_WIDTH=120
export UI_WIDTH=${DEFAULT_MIN_WIDTH}

declare -a test_files
declare -a all_test_files

export UI_WIDTH=${DEFAULT_MIN_WIDTH}
output.constrain-screen-width ${UI_WIDTH}
prefix=" ⏱  "

function test-group() {
  output.constrain-screen-width ${UI_WIDTH}
  h1bg "$(echo "${prefix}$* ")"
}

function test-group-ok() {
  output.constrain-screen-width ${UI_WIDTH}
  h2bg "Tests passed in:" " ⏲  ${1} "
}

function test-group-failed() {
  output.constrain-screen-width ${UI_WIDTH}
  arrow.blk-on-red "Some tests failed in:" "${bakpur}${bldwht}${1} "
}

# @description Initialize specs
function specs.init() {
  dbg "Script Source: ${BASH_SOURCE[0]}"

  export TERM=${TERM:-xterm-256color}
  export MIN_WIDTH=${MIN_WIDTH:-"92"}
  output.constrain-screen-width "${MIN_WIDTH}"

  export ProjectRoot="$(specs.find-project-root)"
  dbg "ProjectRoot is ${ProjectRoot}"

  export BatsRoot="${ProjectRoot}/.bats-sources"
  export BatsSource="${ProjectRoot}/.bats-sources"
  export BatsPrefix="${ProjectRoot}/.bats-prefix"

  ((flag_bats_reinstall)) && run "rm -rf \"${BatsPrefix}\" \"${BatsSource}\" \"${BatsRoot}\""

  dbg "BatsPrefix is ${BatsPrefix}"

  export True=1
  export False=0
  export GrepCommand="$(command -v grep) -E "

  export Bashmatic__Test=${True}

  (mkdir -p "${BatsPrefix}" 2>/dev/null) || true
  (mkdir -p "${BatsPrefix}/bin" 2>/dev/null) || true
  (mkdir -p "${BatsPrefix}/libexec" 2>/dev/null) || true

  export PATH="${ProjectRoot}/bin:${PATH}"
  export PATH="${BatsPrefix}/bin:${BatsPrefix}/libexec:${PATH}"

  export Bashmatic__BatsInstallMethod="sources"
  declare -a Bashmatic__BatsInstallPrefixes
  export Bashmatic__BatsInstallPrefixes=($(util.functions-matching.diff specs.install.bats.))
  export Bashmatic__BatsInstallMethods="$(array.to.csv "${Bashmatic__BatsInstallPrefixes[@]}")"

  unset BashMatic__ColorLoaded
  source "${BASHMATIC_LIB}/color.sh"

  .output.set-indent 1
  type color.enable >/dev/null || {
    color.enable
  }

  return 0
}

function specs.find-project-root() {
  local dir="$(pwd -P)"
  while true; do
    [[ "${dir}" == "/" || -z "${dir}" ]] && break
    [[ -d "${dir}/${TEST_DIR}" ]] && {
      echo "${dir}"
      return 0
    }
    dir="$(dirname "${dir}")"
  done

  error "Can't find project root containing directory '${TEST_DIR}'" \
        "If your tests are located in differently named folder (eg 'specs'), please set" \
        "the environment variable before running specs, eg:" \
        "\$ ${bldylw}\export TEST_DIR=specs; specs" >&2

  return 1
}

#------------------------------------------------------------------
# Bats Installation
function specs.install.bats.brew() {
  hl.subtle "Verifying Bats is brew-installed"
  run "brew tap kaos/shell"
  brew.install.packages bats-core bats-assert bats-file
}

function specs.install.bats.sources() {
  inf "Checking that Bats is installed from sources..."
  if [[ -x ${BatsPrefix}/bin/bats ]]; then
    printf "${bldgrn}YES ✔"
    ok: 
    info "NOTE: you can clean/reinstall bats framework by passing -r / --reinstall flag."
    return 0
  else
    printf "${bldred}NOPE 𐄂"
    not-ok:
  fi

  run "cd ${ProjectRoot}"

  run.set-next show-output-off abort-on-error

  [[ ! -d "${BatsRoot}" ]] &&
    run "git clone ${BATS_SOURCES_CORE} ${BatsRoot}"

  [[ ! -d "${BatsSource}" ]] &&
    run "cd $(dirname "${BatsSource}") && git clone ${BATS_SOURCES_CORE} $(basename "${BatsSource}")"

  [[ -d "${BatsSource}" && -x "${BatsSource}/install.sh" ]] || {
    error "Can't find Bats source folder: expected ${BatsSource} to contain Bats sources..."
    exit 1
  }

  specs.set-width
  # Let's update Bats if needed, and run its installer.
  run "cd ${BatsSource} && git reset --hard && git pull --rebase 2>/dev/null || true"
  local prefix="$(cd "${BatsPrefix}" && pwd -P)"

  specs.set-width

  run "./install.sh ${prefix}" >/dev/null 2>&1  
  run "cd ${ProjectRoot}"
  run 'hash -r'

  [[ ${PATH} =~ ${ProjectRoot}/bin ]] ||
    export PATH="${ProjectRoot}/bin:${ProjectRoot}/test/bin:${PATH}"
}

function specs.install() {
  local install_type="${1:-"${Bashmatic__BatsInstallMethod}"}"
  local func="specs.install.bats.${install_type}"

  util.is-a-function "${func}" || {
    error "Install method ${install_type} is unsupported." \
      "Currently available: brew and sources."
    return 1
  }

  ${func}
}

function specs.find-bats() {
  command -v bats || which bats || find . -name bats -perm "-u=x" | ${GrepCommand} -v 'fixtures|libexec'
}

function specs.validate-bats() {
  local bats=$(specs.find-bats)
  [[ -z ${bats} ]] && {
    error "Can't find bats executable 😩  even after attemping to install it."
    info
    info "whichan bats:                      ${bldylw}$(which bats)"
    info "commd -v bats:                 ${bldylw}$(command -v bats)"
    info "find ${BatsRoot} -name bats:     ${bldylw}$(find "${BatsRoot}" -name bats)"
    exit 1
  }
}

#------------------------------------------------------------------
# Spec Runner
function specs.run.one-file() {
  local file="$1"

  is.not-blank "${file}" || return 1
  is.a-non-empty-file "${file}" || return 1

  test-group "$(printf "%-80.80s" "${file}")"
  local start=$(millis)
  local bats=$(specs.find-bats)
  export flag_file_count=$((flag_file_count + 1))
  [[ ${flag_bats_args} == "-t" ]] && printf "${txtgrn}"

  ${bats} "${flag_bats_args}" "${file}"
  local exitcode=$?
  local end=$(millis)
  local ms=$(( end - start ))

  if [[ ${exitcode} -eq 0 ]]; then
    test-group-ok "${ms}ms"
    return 0
  else
    test-group-failed  "${ms}ms"
    export flag_file_count_failed=$((flag_file_count_failed + 1))
    return "${exitcode}"
  fi
}

function specs.run.many-files() {
  local result=0
  time.with-duration.start specs

  for file in "${test_files[@]}"; do
    specs.run.one-file "${file}"
    local code=$?

    ((code)) && {
      result="${code}"
      error "File ${file} had failing test(s)!"
      ((flag_keep_going_on_error)) && continue
      info "To run all test files regardless of error status, pass -c | --continue flag.\n"
      exit "${code}"
    }
  done

  duration="$(time.with-duration.end specs "in " | sedx 's/\s+/ /g')"

  if [[ ${flag_file_count_failed} -gt 0 ]]; then
    error "Total of ${flag_file_count_failed} out of ${flag_file_count} Test Suites had errors in ${bldylw}${duration}."
  else
    h2bg "All ${flag_file_count} Test Suites had passed ${bldylw}${duration}."
  fi

  return "${result}"
}

function specs.utils.cpu-cores() {
   command -v nproc >/dev/null || {
     printf "%d" 4
     return 
   }

   nproc --all | tr -d '\n'
}

function specs.install-parallel.linux() {
  run "sudo apt-get update -yqq && sudo apt-get install parallel -yqq"
}

function specs.install-parallel.darwin() {
  brew.install.package parallel
}

function specs.run.all-in-parallel() {
  local func="specs.install-parallel.${BASHMATIC_OS}"

  command -v parallel >/dev/null || ${func}
  command -v parallel >/dev/null || {
    warning "Can't find command [parallel] even after an attempted install."
    info "Switching to serial test mode."
    
    dbgf specs.run.many-files "${test_files[@]}"
    return $?
  }

  local cpu_cores=$(specs.utils.cpu-cores)
  h2bg "Running Bats with ${cpu_cores} parallel processes..."
  .bats-prefix/bin/bats --pretty -T -j "${cpu_cores}" "${test_files[@]}"
}

#------------------------------------------------------------------
# Auxiliary
function specs.add-all-files() {
  if [[ -z ${all_test_files[*]} ]]; then
    echo find "${TEST_DIR}" -maxdepth 1 -name '*test*.bats'
    all_test_files=($(find "${TEST_DIR}" -maxdepth 1 -name '*test*.bats' | sort))
    [[ -d "${TEST_DIR}/${BASHMATIC_OS}" ]] && all_test_files=(${all_test_files[@]} $(find "${TEST_DIR}/${BASHMATIC_OS}" -maxdepth 1 -name '*test*.bats' | sort))
  fi
}

# @description Based on a shortname attempt to determine the actual test file names
function specs.utils.get-filename() {
  local file="$1"
  local -a candidates
  candidates=("test/${file}" "test/${file}.bats" "test/${file}_test.bats")
  [[ ${file} =~ / ]] && candidates+=("${file}")

  for test_file in "${candidates[@]}" ; do
    is.a-non-empty-file "${test_file}" && {
      printf "%s" "${test_file}"
      return 0
    }
  done
  return 1
}

export flag_file_count=0
export flag_file_count_failed=0
export flag_keep_going_on_error=0
export flag_bats_args="-p"
export flag_bats_reinstall=0
export flag_parallel_tests=0

function specs.parse-opts() {
  trap 'printf "\n\n\n${bldred}Ctrl-C detected, aborting tests.${clr}\n\n"; exit 1' SIGINT

  # Parse additional flags
  while :; do
    case $1 in
    -h | -\? | --help)
      shift
      specs.usage
      exit 0
      ;;
    -c | --continue)
      shift
      export flag_keep_going_on_error=1
      ;;
    -r | --reinstall)
      shift
      export flag_bats_reinstall=1
      ;;
    -p | --parallel)
      shift
      export flag_parallel_tests=1
      ;;
    -t | --taps)
      shift
      export flag_bats_args="-t"
      ;;
    -i | --install)
      shift
      local method="$1"
      shift
      is.blank "${method}" && {
        error "--install requires an argument"
        exit 1
      }
      local func="specs.install.bats.${method}"
      is.a-function "${func}" || {
        # shellcheck disable=SC2086
        error "Invalid installation method — ${method}. Supported methods: " "${Bashmatic__BatsInstallMethods}"
        exit 1
      }
      export Bashmatic__BatsInstallMethod="${method}"
      ;;
    --) # End of all options; anything after will be passed to the action function
      shift
      break
      ;;
    -?*)
      printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
      exit 127
      shift
      ;;
    *) # Default case: If no more options then break out of the loop.
      is.blank "$1" && break
      local file="$(specs.utils.get-filename "$1")"
      unless "${file}" is.a-non-empty-file && {
        error "Can't determine proper test path for argument $1, got file ${file}"
        exit 2
      }
      test_files+=("${file}")
      shift
      ;;
    esac
  done
}

function specs.header() {
  echo
  printf "      \e[0;0;4m                                                       ${clr}\n"
  printf "      \e[42;24;1m                                                       ${clr}\n"
  printf "      \e[42;30;5m    Bashmatic® Test Runner                             ${clr}\n"
  printf "      \e[42;30;2m    Version $(bashmatic.version)                                      ${clr}\n"
  printf "      \e[42;24;1m                                                       ${clr}\n"
  printf "      \e[43;30;3m    %s  ${clr}\n" "                                                 "
  printf "      \e[43;30;3m    %s  ${clr}\n" "© 2016-$(date '+%Y') Konstantin Gredeskoul, (MIT License)."
  printf "      \e[43;14;4m    %43.43s        ${clr}\n" " "
  echo
}

function specs.usage() {
  printf "${bldylw}USAGE\n    ${bldgrn}bin/specs [ options ] [ test1 test2 ... ]${clr}\n\n"
  printf "    ${txtcyn}where test1 can be a full filename, or a partial, eg. ${txtcyn}'test/util_tests.bats'\n"
  printf "    or just 'util'. Multiple arguments are also allowed.\n\n"

  printf "${bldylw}DESCRIPTION\n    ${txtcyn}This script should be run from the project's root.\n"
  printf "    It installs any dependencies it relies on (such as the Bats Testing Framework)\n"
  printf "    seamlessly, and then runs the tests, typically in the test folder.\n"
  printf "    \n"
  printf "    NOTE: this script can be run not just inside Bashmatic Repo. It works\n"
  printf "          very well when invoked from another project, as long as the bin directory\n"
  printf "          is in the PATH. So make sure to set somewhere:\n" 
  printf "          ${bldylw}export PATH=\${BASHMATIC_HOME}/bin:\${PATH}\n\n"
  hr
  echo
  printf "${bldylw}OPTIONS\n${txtpur}"
  printf "    -p | --parallel         Runs all tests sequentially instead of ${bldylw}serially${txtpur}.\n"
  printf "    -i | --install METHOD   Install Bats using the provided method.\n"
  printf "                            Supported methods: ${bldylw}${Bashmatic__BatsInstallMethods}${txtpur}\n\n"
  printf "    -r | --reinstall        Reinstall Bats framework before running\n"
  printf "    -c | --continue         Continue after a failing test file.\n"
  printf "    -t | --taps             Use taps bats formatter, instead of pretty.\n"
  printf "    -h | --help             Show help message\n\n"

  exit 0
}

function specs.set-width() {
  local w="${1:-100}"
  if [[ -n $CI ]] ; then
    output.set-min-width "${w}"
    output.set-max-width "${w}"
    output.constrain-screen-width "${w}"
  else
    output.unconstrain-screen-width
  fi
}

function specs.run() {
  local width=$(( $(output.screen-width.actual) - 20))

  [[ -z ${width} || ${width} -lt 80 ]] && width=109

  specs.set-width "${width}"
  specs.header

  export test_files=()
  export all_test_files=()

  dbgf specs.init "$@"
  dbgf specs.parse-opts "$@"

  dbgf specs.install "${Bashmatic__BatsInstallMethod}"
  dbgf specs.validate-bats
  dbgf specs.add-all-files # Populates all_test_files[@] if not already populated

  [[ -z "${test_files[*]}" ]] && test_files=( ${all_test_files[@]} )

  [[ ${#test_files[@]} -gt 0 ]] && h4bg "Begin Automated Testing -> Testing ${#test_files[@]} File(s)"

  if [[ ${flag_parallel_tests} -eq 0 ]] ;  then
    specs.run.many-files "${test_files[@]}"
  else
    specs.run.all-in-parallel "${test_files[@]}"
  fi
}

