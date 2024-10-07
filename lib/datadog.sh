#!/usr/bin/env bash
# vim: ft=bash
# @copyright © 2016-2024 Konstantin Gredeskoul, All rights reserved
# @license MIT License.
#
# @file lib/datadog.sh
# @description Datadog Agent Functions
#

# @description This function starts datadog agent, if it's not already running.
function dd-start() {
  local log_dir="/opt/datadog-agent/logs"

  command -V datadog-agent 2>/dev/null || {
    error "Datadog Agent does not appear to be in your \$PATH"
    return 1
  }

  [[ -d ${log_dir} ]] || mkdir -p "${log_dir}"

  /bin/ps -ef | grep -iq [d]atadog && {
    h1 'Stopping Datadog Agent...'

    run "datadog-agent stop || sleep 5"
    run "datadog-agent stop; ps -ef | grep [d]atadog | awk '{print \$2}'; sleep 1"

    local still_running=$(mktemp)
    /bin/ps -ef | grep -iq -E [d]atadog > ${still_running} && {
      warning "Some Datadog Agent processes either stayed running, or auto-restarted."
      cat ${still_running}
    }
  }

  /bin/ps -ef | grep -iq [d]atadog && {
    h1 'Starting Datadog Agent...'
    run.set-next show-output-on
    run "nohup datadog-agent start 1>>${log_dir}/stdout.log 2>>${log_dir}/stderr.log &"
    hr
    ps -ef | grep -i datadog
    hr
  }

  # Return success if datadog is running, some other exit code if grep doesn't find anything
  /bin/ps -ef | grep -iq [d]atadog
}

