#!/usr/bin/env bash
# vim: ft=sh
#
# Bashmatic Utilities
# © 2016-2021 Konstantin Gredeskoul, All rights reserved. MIT License.
# Distributed under the MIT LICENSE.

# IMPORTANT: Overrride this variable if your tests are located in a different folder, eg 'specs'
# shellcheck disable=2046

readonly BATS_SOURCES_CORE="https://github.com/bats-core/bats-core.git"
# readonly BATS_SOURCES_SUPPORT="https://github.com/bats-core/bats-support"

export DEFALT_MIN_WIDTH=92
export UI_WIDTH=${UI_WIDTH:-${DEFALT_MIN_WIDTH}}

output.constrain-screen-width "${UI_WIDTH}"

if [[ -n $CI ]] ; then
  prefix="⮀ "

  function test-group() {
    echo "${prefix}📦  $*"
    hr; echo
  }
  function test-group-ok() {
    echo "${prefix}✅  Tests passed in ${1}"
    hr; echo
  }
  function test-group-failed() {
    echo "${prefix}❌  Some tests failed in ${1}"
    hr; echo
  }

else

  function test-group() {
    arrow.blk-on-ylw "$@"
    echo
  }
  function test-group-ok() {
    status.ok "Tests passed in ${1}"
    echo
  }
  function test-group-failed() {
    status.failed "Some tests failed in ${1}"
    echo
  }
fi

# @description Initialize specs
function specs.init() {
  dbg "Script Source: ${BASH_SOURCE[0]}"

  export TERM=${TERM:-xterm-256color}
  export MIN_WIDTH=${MIN_WIDTH:-"92"}
  output.constrain-screen-width "${MIN_WIDTH}"

  export ProjectRoot="$(specs.find-project-root)"
  dbg "ProjectRoot is ${ProjectRoot}"

  # shellcheck disable=SC2064
  [[ ! -f "${ProjectRoot}/Gemfile.lock" ]] && trap "rm -f ${ProjectRoot}/Gemfile.lock" EXIT

  export BatsRoot="${ProjectRoot}/.bats-sources"
  export BatsSource="${ProjectRoot}/.bats-sources"
  export BatsPrefix="${ProjectRoot}/.bats-prefix"

  dbg "BatsPrefix is ${BatsPrefix}"

  export True=1
  export False=0
  export GrepCommand="$(which grep) -E -e "

  export Bashmatic__Test=${True}

  (mkdir -p "${BatsPrefix}" 2>/dev/null) || true
  (mkdir -p "${BatsPrefix}"/bin 2>/dev/null) || true
  (mkdir -p "${BatsPrefix}"/libexec 2>/dev/null) || true

  export PATH="${ProjectRoot}/bin:/usr/bin:/usr/local/bin:/bin:/sbin:/opt/bin:/opt/local/bin:/opt/sbin"
  export PATH="${BatsPrefix}/bin:${BatsPrefix}/libexec:${PATH}"

  export Bashmatic__BatsInstallMethod="sources"
  declare -a Bashmatic__BatsInstallPrefixes
  export Bashmatic__BatsInstallPrefixes=($(util.functions-matching.diff specs.install.bats.))
  export Bashmatic__BatsInstallMethods="$(array.to.csv "${Bashmatic__BatsInstallPrefixes[@]}")"

  .output.set-indent 1
  color.enable

  return 0
}

function specs.find-project-root() {
  local dir="${PWD}"
  while true; do
    [[ "${dir}" == "/" || -z "${dir}" ]] && break
    [[ -d "${dir}/${TEST_DIR}" ]] && {
      echo "${dir}"
      return 0
    }
    dir="$(dirname "${dir}")"
  done

  error "Can't find project root containing directory '${TEST_DIR}'" \
    "If your tests are located in differently named folder (eg 'specs'), please set"
  "the environment variable before running specs, eg:" \
    "\$ ${bldylw}export TEST_DIR=specs; specs" >&2

  return 1
}

#------------------------------------------------------------------
# Bats Installation
function specs.install.bats.brew() {
  run "brew tap kaos/shell"
  brew.install.packages bats-core bats-assert bats-file
}

function specs.install.bats.sources() {
  [[ -x ${BatsPrefix}/bin/bats ]] && return 0

  run.set-next show-output-off abort-on-error

  [[ ! -d "${BatsRoot}" ]] &&
    run "git clone ${BATS_SOURCES_CORE} ${BatsRoot}"

  [[ ! -d "${BatsSource}" ]] &&
    run "cd $(dirname "${BatsSource}") && git clone ${BATS_SOURCES_CORE} $(basename "${BatsSource}")"

  [[ -d "${BatsSource}" && -x "${BatsSource}/install.sh" ]] || {
    error "Can't find Bats source folder: expected ${BatsSource} to contain Bats sources..."
    exit 1
  }

  # Let's update Bats if needed, and run its installer.
  run "cd ${BatsSource} && git reset --hard && git pull --rebase 2>/dev/null || true"
  local prefix="$(cd "${BatsPrefix}" && pwd -P)"
  run "./install.sh ${prefix}"
  run "cd ${ProjectRoot}"
  run 'hash -r'

  [[ ${PATH} =~ ${ProjectRoot}/bin ]] ||
    export PATH="${ProjectRoot}/bin:${ProjectRoot}/test/bin:${PATH}"
}

function specs.install() {
  local install_type="${1:-"${Bashmatic__BatsIntallMethod}"}"
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
    info "which bats:                      ${bldylw}$(which bats)"
    info "command -v bats:                 ${bldylw}$(command -v bats)"
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

  test-group "${file}"
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
    success "All ${flag_file_count} Test Suites had passed ${bldylw}${duration}."
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

function specs.run.all-in-parallel() {
  specs.init
  command -v parallel >/dev/null || package.install parallel
  command -v parallel >/dev/null || {
    warning "Can't find command [parallel] even after an attempted install."
    info "Swithcing to serial test mode."
    
    dbgf specs.run.many-files "${test_files[@]}"
    return $?
  }

  local cpu_cores=$(specs.utils.cpu-cores)
  h5bg "Running Bats with ${cpu_cores} parallel processes..."
  .bats-prefix/bin/bats --pretty -T -j "${cpu_cores}" "${test_files[@]}"
}

#------------------------------------------------------------------
# Auxillary
function specs.add-all-files() {
  export AppCurrentOS="$(uname -s | tr '[:upper:]' '[:lower:]')"
  if [[ -z ${all_test_files[*]} ]]; then
    all_test_files=($(find "${TEST_DIR}" -maxdepth 1 -name '*test*.bats' | sort))
    [[ -d "${TEST_DIR}/${AppCurrentOS}" ]] && all_test_files=(${all_test_files[@]} $(find "${TEST_DIR}/${AppCurrentOS}" -maxdepth 1 -name '*test*.bats' | sort))
  fi
}

# @description Based on a shortname attempt to determine the actual test file names
function specs.utils.get-filename() {
  local file="$1"
  for test_file in "${file}" "test/${file}" "test/${file}.bats" "test/${file}_test.bats"; do
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
      ${func}
      exit $?
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
  hr
  echo
  printf "\e[48;5;11m\e[48;30;209m                                                                                          ${clr}\n"
  printf "\e[48;5;11m\e[48;30;209m  BASHMATIC TEST RUNNER, VERSION ${black}$(bashmatic.version)                                                   ${clr}\n"
  printf "\e[48;5;11m\e[48;30;209m  © 2016-2021 Konstantin Gredeskoul, All Rights Reserved,  MIT License.                   ${clr}\n"
  printf "\e[48;5;11m\e[48;30;209m                                                                                          ${clr}\n"
  echo
}

function specs.usage() {
  specs.header

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
  printf "          ${bldgrn}export PATH=\${BASHMATIC_HOME}/bin:\${PATH}\n\n"
  hr
  echo
  printf "${bldylw}OPTIONS\n${txtpur}"
  printf "    -p | --parallel         Runs all tests in parallel using ${bldylw}parallel${txtpur} dependency.\n"
  printf "                            This may speed up your test suite by 2-3x\n\n"
  printf "    -i | --install METHOD   Install Bats using the provided methjod.\n"
  printf "                            Supported methods: ${bldylw}${Bashmatic__BatsInstallMethods}${txtpur}\n\n"
  printf "    -c | --continue         Continue after a failing test file.\n"
  printf "    -t | --taps             Use taps bats formatter, instead of pretty.\n"
  printf "    -h | --help             Show help message\n\n"

  exit 0
}

function specs.run() {
  declare -a test_files
  declare -a all_test_files

  export test_files=()
  export all_test_files=()

  dbgf specs.init "$@"
  dbgf specs.parse-opts "$@"

  dbgf specs.install sources
  dbgf specs.validate-bats
  dbgf specs.add-all-files # Populates all_test_files[@] if not already populated

  [[ -z ${test_files[*]} ]] && test_files=("${all_test_files[@]}")

  output.constrain-screen-width "${UI_WIDTH}"

  specs.header
  [[ ${#test_files} -gt 0 ]] && h4bg "Begin Automated Testing -> Testing ${#test_files[@]} File(s)"

  if [[ ${flag_parallel_tests}0 -eq 0 ]] ;  then 
    dbgf specs.run.many-files "${test_files[@]}"
  else
    dbgf specs.run.all-in-parallel "${test_files[@]}"
  fi
}

