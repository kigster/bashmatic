# vim: ft=bash
#
# @description This file is responsible for gatheriong infomration about the current
# system such OS, CPU model, emulation (eg. Rosetta) to ultimately s
# determine the proper location for Homebrew.
#
# The API of this is as follows:
#    1. source the file
#    2. Invoke 'os.determine-system-type'
#    3. Fetch the object attribute you care about using os.value-for(attribute)
#    4. Available attributes can be fetched via os.attrs()

# NOTE: we would like to keep this file independent of any other library files,
# hence some duplication of functions.

export os_preinstall_ran=${os_preinstall_ran:-false}
export current_bash_version="${BASH_VERSINFO[0]}"

function bash.version-four-or-later() {
  [[ "${current_bash_version}" -gt 4 ]]
}

if [[ -z ${project_root} ]]; then
  export project_root=$(
    cd "$(dirname "${BASH_SOURCE[0]}")/../../../" || exit 1
    pwd -P
  )
fi

# @description Returns array of attributes that are avilablr after the fowpods
function os.attrs() {
  printf "os
  arch
  cpu_vendor
  cpu_count
  cpu_model
  threads_per_core
  emulation
  bash_version
  bash_path
  ram_physical
  ram_free
  ram_used
  load_average\n" | sed 's/^  //g'
}

function array.index-of() {
  local value="$1"
  shift
  local index=0
  for v in "$@"; do
    if [[ "${v}" == "${value}" ]]; then
      printf "${index}"
      return 0
    fi
    index=$((index + 1))
  done
  return 1
}

function os.darwin.pre-install() {
  verb "Ensuring OS-X Dev Tools are up to date and installed..."
  if [[ -f dev/bashmatic/init.sh ]]; then
    source dev/bashmatic/init.sh
    run.set-all continue-on-error show-output-off
  fi
  # Install Command Line Tools
  verb "running: xcode-select --install 2>/dev/null"
  xcode-select --install 2>/dev/null

  # Enable command line tools
  local current_path="$(xcode-select -p)"
  local expected_path="/Library/Developer/CommandLineTools"
  if [[ -d "${expected_path}" && "${current_path}" != "${expected_path}" ]]; then
    if [[ -n $(type run 2>/dev/null) ]]; then
      run "sudo xcode-select --switch /Library/Developer/CommandLineTools"
    else
      set -x
      sudo xcode-select --switch /Library/Developer/CommandLineTools
      set +x
    fi
  fi
  # Alternatively, one could accept the license of XCode
  # run "sudo xcodebuild -license accept"
}

# Instead of using an Associative array we opted to use two parallel flat arrays
# that are compatible with bash version 3

export -a system_info_keys=()
export -a system_info_values=()

# @description Returns the value of a given key in the system hash
# @example
#      os.value-for "os"        => "darwin"
#      os.value-for "emulation" => "native"
function os.value-for() {
  local key="$1"
  shift
  local i=$(array.index-of "${key}" "${system_info_keys[@]}")
  [[ -z $i ]] && return 1
  printf "${system_info_values[$i]}"
}

# @description This function displays current configuration and is
#              very useful in debugging.
function os.print-system-type() {
  local pfx="    "
  [[ -z $(os.value-for cpu_model) ]] && os.determine-system-type
  printf "${pfx}┌──────────────────────────────────────────────────────────────┐\n"
  printf "${pfx}│${color_black}${bg_salmon}        System Hardware Detected                              ${clr}│\n"
  printf "${pfx}├──────────────────────────────────────────────────────────────┤\n"
  local value
  local color_metrics
  for key in "${system_info_keys[@]}"; do
    color_metrics="${bldylw}"
    value=$(os.value-for "${key}")
    if [[ "${key}" =~ ram ]]; then
      value=$(memory.bytes-to-units "${value}" "%10.1f" "B")
      color_metrics="${bldcyn}"
    elif [[ "${key}" =~ average ]]; then
      color_metrics="${bldred}"
    fi
    printf "${pfx}│        ${txtgrn}$(printf "%-15.15s" "${key}")${clr} = $(printf "${color_metrics}%25.25s" "${value}")${clr}           │\n"
  done
  printf "${pfx}└──────────────────────────────────────────────────────────────┘\n\n"
}

# @description This function displays current configuration and is
#              very useful in debugging.
function os.print-system-yaml() {
  printf -- "---\nsystem:\n  hostname: \"$(hostname)\"\n  user: \"$(whoami)\"\n"
  [[ -z $(os.value-for cpu_model) ]] && os.determine-system-type
  local value
  for key in "${system_info_keys[@]}"; do
    value=$(os.value-for "${key}")
    if [[ "${key}" =~ ram ]]; then
      value=$(memory.bytes-to-units "${value}" "%.1f" "B")
    fi
    printf "  ${key}: \"${value}\"\n"
  done
}

is.a-function() {
  if [[ -n $1 ]] && typeset -f "$1" >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

# @description This function populates an array of information about the current
#              system. If the current BASH version is 4+, an associative array
#              is populated called ${system_info}. Whether BASH is v3 or later,
#              two regular arrays are populated in tandem: ${system_info_keys} and
#              ${system_info_values}.
#
#              In fact this file is BASH-3 compatible.
# @example
#     os.determine-system-type
#     local cpu_model=$(os.value-for cpu_model)
#     local emulation=$(os.value-for emulation)
#     # etc...
# shellcheck disable=SC2034,SC2207
function os.determine-system-type() {
  os=$(uname -s | tr '[:upper:]' '[:lower:]')
  arch="$(uname -m)"
  local code
  case ${os} in
  darwin)
    cpu_model=$(/usr/sbin/sysctl -n machdep.cpu.brand_string | tr '[:upper:]' '[:lower:]' | tr ' ' '.' | sed 's/^apple\.//g')
    cpu_count=$(/usr/sbin/sysctl -n machdep.cpu.core_count)
    cpu_vendor=$(/usr/sbin/sysctl -n machdep.cpu.brand_string | tr '[:upper:]' '[:lower:]' | awk '{print $1}')
    thread_count=$(/usr/sbin/sysctl -n machdep.cpu.thread_count)
    threads_per_core=$((thread_count / cpu_count))

    ## @description RAM numbers
    ## These are all going to be in pure bytes.  Use the following function to convert: 
    ##    memory.bytes-to-units( very-large-number )
    ## to a human-readable format.
    ram_physical=$(memory.size-to-bytes "$(system_profiler SPHardwareDataType | grep Memory: | awk '{printf "%d %s", $2, $3}')" )
    ram_used=$(memory.size-to-bytes "$(top -n 0 -l 1 | grep PhysMem | awk '{printf("%s\n", $2) }')")
    ram_free=$(memory.size-to-bytes "$(top -n 0 -l 1 | grep PhysMem | awk '{printf("%s\n", $8) }')")

    ;;
  linux)
    # On most Linux we can run lscpu, but on Heroku, of course, we can't.
    bash -c 'set +x; lscpu 1>/dev/null 2>&1'
    code=$?
    if [[ ${code} -eq 0 ]]; then
      # eg "arm"
      cpu_vendor=$(lscpu | grep 'Vendor ID' | sed -E 's/.*:\s+//g; s/Genuine//g' | tr '[:upper:]' '[:lower:]')
      # eg "Neoverse-N1"
      cpu_model=$(lscpu | grep 'Model name' | sed -E 's/.*:\s+//g')
      # eg 1
      threads_per_core=$(lscpu | grep Thread | sed -E 's/.*:\s+//g')
    else
      # Heroku, I hope you are happy.
      cpu_vendor=$(grep 'model name' /proc/cpuinfo | cut -d ':' -f 2 | sed 's/^ *//g' | uniq)
      cpu_model=$(grep 'model name' /proc/cpuinfo | cut -d ':' -f 2 | sed 's/^ *//g' | uniq | sed 's/ CPU.*$//g' | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
      threads_per_core=$(grep 'cpu cores' /proc/cpuinfo | cut -d ':' -f 2 | sed 's/^ *//g' | uniq)
    fi
    cpu_count=$(grep -c '^processor' /proc/cpuinfo)

    ram_physical=$(free -b | grep Mem: | awk '{print $2}')
    ram_used=$(free -b | grep Mem: | awk '{print $3}')
    ram_free=$(free -b | grep Mem: | awk '{print $7}')

    ;;
  *)
    printf "${color_red} ERROR: Operating system is not support: ${os}\n"
    exit 1
    ;;
  esac

  case "${arch}" in
  x86_64)
    if [[ ${os} == "darwin" ]]; then
      if [[ "$(/usr/sbin/sysctl -in sysctl.proc_translated)" -eq 1 ]]; then
        emulation="rosetta"
      else
        emulation="native"
      fi
    fi
    ;;
  arm64 | aarch64)
    emulation="native"
    ;;
  *)
    printf "${color_red} ERROR: Invalid architecture for os ${os}: ${arch}\n"
    exit 1
    ;;
  esac

  bash_version="${current_bash_version}"
  bash_path="${SHELL}"
  # This seems to work on both linux and OS-X
  load_average=$( uptime | sed -E 's/.*averages?: //g' )
  system_info_keys=($(os.attrs))

  for key in "${system_info_keys[@]}"; do
    system_info_values+=("${!key}")
  done

  export os_detected=true

  local func="os.$(os.value-for os).pre-install"
  is.a-function "${func}" && [[ "${os_preinstall_ran}" == "false" ]] && {
    eval "${func}"
    export os_preinstall_ran=true
  }

  return 0
}

${os_detected} || {
  os.determine-system-type && os.print-system-type
  export os_detected=true
}
