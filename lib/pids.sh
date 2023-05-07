#!/usr/bin/env bash
#
# pids family of functions
# Author: Konstantin Gredeskoul
#

# Single PID operations

# Check if the process is running
function pid.alive() {
  local pid="$1"
  [[ -z ${pid} ]] && {
    error "usage: pid.alive PID"
    return 1
  }

  is.numeric "${pid}" || {
    error "The argument to pid.alive() must be a numeric Process ID"
    return 1
  }

  [[ -n "${pid}" && -n $(ps -p "${pid}" | grep -v TTY) ]]
}

# Send array of signals
pid.sig() {
  local pid="${1}"
  shift
  local signal="${1}"
  shift

  [[ -z "${pid}" || -z "${signal}" ]] && {
    printf "
USAGE:
  pid.sig pid signal
"
    return 1
  }

  is.numeric "${pid}" || {
    error "First argument to pid.sig must be numeric."
    return 1
  }

  is.numeric "${signal}" || sig.is-valid "${signal}" || {
    error "First argument to pid.sig must be numeric."
    return 1
  }

  if pid.alive "${pid}"; then
    info "sending ${bldred}${signal}$(txt-info) to ${bldylw}${pid}..."
    /bin/kill -s "${signal}" "${pid}" 2>&1 | cat >/dev/null
  else
    warning "pid ${pid} was dead by the time we tried sending ${sig} to it."
    return 1
  fi
}

# Mac OSX Signal Name Table
#  1) SIGHUP       2) SIGINT       3) SIGQUIT      4) SIGILL       5) SIGTRAP
#  6) SIGABRT      7) SIGEMT       8) SIGFPE       9) SIGKILL     10) SIGBUS
# 11) SIGSEGV     12) SIGSYS      13) SIGPIPE     14) SIGALRM     15) SIGTERM
# 16) SIGURG      17) SIGSTOP     18) SIGTSTP     19) SIGCONT     20) SIGCHLD
# 21) SIGTTIN     22) SIGTTOU     23) SIGIO       24) SIGXCPU     25) SIGXFSZ
# 26) SIGVTALRM   27) SIGPROF     28) SIGWINCH    29) SIGINFO     30) SIGUSR1
# 31) SIGUSR2
#
# esoteric function that returns names of all signals one per line with SIG removed.
sig.list() {
  /bin/kill -l | sed -E 's/([ 0-9][0-9]\) SIG)//g; s/\s+/\n/g' | tr 'a-z' 'A-Z' | sort
}

# validate if it's a valid signal name, eg:
# sig.is-valid HUP && echo yes
sig.is-valid() {
  [[ -n $(kill -l "${1}" 2>/dev/null) ]]
}

pid.stop-and-kill() {
  local pid="$1"
  delta=1
  sig=STOP
  while true; do
    pid.alive "$pid" || return 0
    kill -${sig} "${pid}" 2>&1 >/dev/null
    delta=$((delta * 2))
    [[ ${delta} -gt 16 ]] && sig="KILL"
    sleep "0.${delta}"
  done

  pid.alive "$pid" && {
    error "PID ${pid} is miraculously still alive..." >&2
    return 1
  }
}

# Stop a running process by sending it a TERM first then KILL
# Usage:
#    pid.stop <pid> [ seconds-to-wait ]
#
pid.stop() {
  local pid=${1}
  shift
  local delay=${1:-"0.3"}
  shift

  if [[ -z ${pid} ]]; then
    printf "
DESCRIPTION:
  If the given PID is active, first sends kill -TERM, waits a bit,
  then sends kill -9.

USAGE:
  ${bldgrn}pid.stop pid${clr}

EXAMPLES:
  # stop all sidekiqs, waiting half a sec in between
  ${bldgrn}pid.stop sidekiq 0.5${clr}
"
    return 1
  fi

  pid.alive "${pid}" &&
    (pid.sig "${pid}" "TERM" || true) &&
    sleep "${delay}"

  pid.alive "${pid}" &&
    pid.sig "${pid}" "KILL"
}

# Normalize search pattern, by inserting a '[' in the beginning
# This only works with regular strings, not a regexp
pids.normalize.search-string() {
  local pattern="$*"
  # convert a simple pattern, eg. "puma" into eg. "[p]uma"
  [[ "${pattern:0:1}" == '[' ]] || pattern="[${pattern:0:1}]${pattern:1}"
  printf "${pattern}"
}

pids.matching() {
  local pattern="${1}"

  if [[ -z "${pattern}" ]]; then
    printf "
DESCRIPTION:
  Finds process IDs matching a given string.

USAGE:
  ${bldgrn}pids.matching string${clr}

EXAMPLES:
  ${bldgrn}pids.matching sidekiq${clr}
"
    return 0
  fi

  pattern="$(pids.normalize.search-string "${pattern}")"
  pids.matching.regexp "${pattern}"
}

pids.matching.regexp() {
  local pattern="${1}"

  if [[ -z "${pattern}" ]]; then
    printf "
DESCRIPTION:
  Finds process IDs matching a given regexp.

USAGE:
  ${bldgrn}pids.matching regular-expression${clr}

EXAMPLES:
  ${bldgrn}pids.matching '[s]idekiq\s+' ${clr}
"
    return 0
  fi

  ps -ef | ${GrepCommand} "${pattern}" | ${GrepCommand} -v grep | awk '{print $2}' | sort -n
}

# prints PIDs with other information such as CPU, MEM, etc.
# If the first argument is either
pids-with-args() {
  local -a permitted=("%cpu" "%mem" acflag acflg args blocked caught comm command cpu cputime etime f
    flags gid group ignored inblk inblock jobc ktrace ktracep lim login logname
    lstart majflt minflt msgrcv msgsnd ni nice nivcsw nsignals nsigs nswap nvcsw
    nwchan oublk oublock p_ru paddr pagein pcpu pending pgid pid pmem ppid pri
    pstime putime re rgid rgroup rss ruid ruser sess sig sigmask sl start stat
    state stime svgid svuid tdev time tpgid tsess tsiz tt tty
    ucomm uid upr user usrpri utime vsize vsz wchan wq wqb wql wqr xstat)

  local -a additional=()
  local -a matching=()
  for arg in $@; do
    array.includes "${arg}" "${permitted[@]}" && additional=(${additional[@]} $arg) && continue
    matching=("${matching[@]}" "${arg}")
  done

  local columns="pid,ppid,user,%cpu,%mem,command"
  if [[ ${#additional[@]} -gt 0 ]]; then
    columns="${columns},$(array.join ',' "${additional[@]}")"
  fi

  pids.matching.regexp "${matching[*]}" | xargs /bin/ps -www -o"${columns}" -p
}

pids.all() {
  if [[ -z "${1}" ]]; then
    printf "
DESCRIPTION:
  prints processes matching a given pattern

USAGE:
  ${bldgrn}pids.all pattern${clr}

EXAMPLES:
  ${bldgrn}pids.all puma${clr}
"
    return 0
  fi

  local pattern="$(pids.normalize.search-string "$1")"
  shift
  ps -ef | ${GrepCommand} "${pattern}" | ${GrepCommand} -v grep
}

#
# Usage:   pids.for-each <pattern> function
#    eg:   pids.for-each puma pid.stop
#
pids.for-each() {
  if [[ -z "${1}" || -z "${2}" ]]; then
    printf "
DESCRIPTION:
  loops over matching PIDs and calls a named BASH function

USAGE:
  ${bldgrn}pids.for-each pattern function${clr}

EXAMPLES:
  ${bldgrn}pids.for-each puma echo
  function hup() { kill -HUP \$1; }; pids.for-each sidekiq hup${clr}
"
    return 0
  fi

  local pattern="$(pids.normalize.search-string "$1")"
  shift
  local func=${1:-"echo"}

  if [[ -z $(which "${func}") && -z $(type "${func}" 2>/dev/null) ]]; then
    errror "Function ${func} does not exist."
    return 1
  fi

  while true; do
    local -a pids=($(pids.matching "${pattern}"))

    [[ ${#pids[@]} == 0 ]] && break

    eval "${func} ${pids[0]}"
    sleep 0.1
  done
}

# @description Finds any PID listening on one of the provided ports and stop thems.
# @example 
#     pids.stop-by-listen-tcp-ports 4232 9578 "${PORT}"
#
pids.stop-by-listen-tcp-ports() {
  for port in "$@"; do
    pid.stop-if-listening-on-port "${port}"
  done
}

# @description Finds any PID listening the one port and an optional protocol (tcp/udp)
# @example 
#     pid.stop-if-listening-on-port 3000 tcp
#     pid.stop-if-listening-on-port 8126 udp
#
pid.stop-if-listening-on-port() {
  local port="$1"
  local protocol="${2:-"tcp"}"

  local -a pids
  pids=($(lsof -i "${protocol}":"${port}" | grep -v PID | awk '{print $2}'))
  local pids_string="${pids[*]}" 
  if [[ ${#pids[@]} -eq 0 ]] ; then
    return 0
  else
    info "Found ${#pids[@]} processes attached to port ${port}/${protocol}."
    info "Process IDs attached to ${bldcyn}${port}/${protocol}: ${bldylw}${pids_string/ /, }"
  fi

  pids.stop "${pids[@]}"
}

#
# Usage: pids.stop <pattern>
#
pids.stop() {
  if [[ -z "${1}" ]]; then
    printf "
DESCRIPTION:
  finds and stops IDs matching a given pattern

USAGE:
  ${bldgrn}pids.stop <pattern>${clr}
  ${bldgrn}pids.stop pid pid ... >${clr}

EXAMPLES:
  ${bldgrn}pids.stop puma${clr}
"
    return 0
  fi

  for pid in $@; do
    if is.numeric "${pid}"; then
      pid.stop "${pid}"
    else
      pids.for-each "${pid}" "pid.stop"
    fi
  done
}

# An Alias
pstop() {
  pids.stop "$@"
}

pall() {
  pids.all "$@"
}

# @description walks the process tree up the chain until it finds the top
# process, whose parent PID is 1. Returns that process's arg list.
function top-most-program() {
  pid=$$
  while true; do
    declare -a output=($(ps -o ppid,pid,args -p $pid | grep -v PPID))
    if [[ ${output[0]} -eq 1 ]] ; then
      echo ${output[2]}
      break
    elif [[ ${output[0]} -gt 0 ]] ; then
      pid=${output[0]}
    elif [[ -z ${output} ]] ; then
      return 1
    fi
  done
}



