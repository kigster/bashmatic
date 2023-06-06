#!/usr/bin/env bash
# vim: ft=bash
# @file Performance Testing Routines

# @description Executes the given expression in a loop, measuring its duration
# @arg $1 string Expression to be executed
# @arg $2 int Number of times to execute the expression
# @arg $3 int Timeout in seconds for each expression execution (optional) if not provided, no timeout is set.
# @example performance-test-expression 'echo "Hello World"' 1000
# @output Total time for the number of iteractions
# @exitcode 0 If successful
function performance.test.expression() {
  local expr="$1"
  local times="${2:-1000}"
  local t_timeout="${3:-0}"
  local t_start="$(epoch)"
  local t_start_float="$(epoch.float)"

  info "Testing Expression: ${bldylw}${expr} " >&2

  local _i
  for _i in $(seq 1 "${times}"); do
    if [[ $t_timeout -gt 0 ]] && (( _i % 10 )); then
      if [[ $(( $(epoch) - t_start)) -gt ${t_timeout} ]]; then
        error "Command timeout of ${t_timeout} sec exceeded. Aborting." >&2
        return 1
      fi
    fi
    ${expr} 2>/dev/null >/dev/null
  done

  local dur_float
  dur_float=$(ruby -e "print ($(epoch.float) - ${t_start_float}).round(3)")
  echo "${dur_float}"
}

function time-test() {
  performance.test.expression "$@"
}
