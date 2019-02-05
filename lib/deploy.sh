#!/usr/bin/env bash
#
# © 2018-2019 Konstantin Gredeskoul, MIT License.
#
# Set me to a URL pointing to the VPN setup instructions
export LibDeploy__VpnInfoUrl=${LibDeploy__VpnInfoUrl:-''}

# Set me to the egrep regular expression to filter `netstat -rn` with.
# successful grep means VPN is connected, no match - disconnected.
# Defaults to 10/16, but change it to whatever suits you.
export LibDeploy__VpnSubnet=${LibDeploy__VpnSubnet:-"^10/16"}

# Set me to something like https://hooks.slack.com/services/XXXXX/YYYYY/AAAAA
export LibDeploy__SlackHookUrl=${LibDeploy__SlackHookUrl:-''}

export LibDeploy__NoSlack=false

################################################################################
# VPN Commands
################################################################################

__lib::deploy::check-vpn() {
  netstat -rn | egrep "${LibDeploy__VpnSubnet}" >/dev/null
}

__lib::deploy::vpn-error() {
  local env=${1:-"appropriate"}

  error "No VPN connection detected matching ${LibDeploy__VpnSubnet}! " \
    "Please make sure you are connected to the ${env} VPN Connection."

  if  [[ -n "${LibDeploy__VpnInfoUrl}" ]]; then
    h1 "For instructions on how to configure VPN, pl0ease ⌘ -click below: " \
       "${undblu}${LibDeploy__VpnInfoUrl}${clr}"
  fi

  if [[ -n "$(netstat -rn | grep utun)" ]]; then
    info "Your current VPN routes are as follows:\n"
    printf "${bldylw}"
    netstat -rn | egrep '^[0-9].*tun'
    printf "${clr}\n"
  fi

  exit 1
}

lib::deploy::validate-vpn() {
  __lib::deploy::check-vpn "$@" || __lib::deploy::vpn-error "$@"
}

################################################################################
# Slack Commands
################################################################################

lib::deploy::slack() {
  local original_text="$*"
  [[ -z ${LibDeploy__SlackHookUrl} ]] && return 1

  local text=$(echo "${original_text}" | sed -E 's/"/\"/g' | sed -E "s/'/\'/g")
  local json="{\"text\": \"$text\"}"
  local slack_url="${LibDeploy__SlackHookUrl}"

  [[ ${LibRun__DryRun} -eq ${False} ]] && {
    if ${LibDeploy__NoSlack}; then
      hl::green "${original_text}"
    else
      curl -s -d "payload=$json" "${slack_url}" 1>/dev/null
      if [[ $? -eq 0 ]]; then
        info: "sent to Slack: [${text}]"
      else
        warning: "error sending to Slack, is your SLACK_URL set?"
      fi
    fi
  }
  [[ ${LibRun__DryRun} -eq ${True} ]] && run "send to slack [${text}]"
}

lib::deploy::slack-ding() {
  lib::deploy::slack "<!here> $@"
}

################################################################################
