#!/usr/bin/env bats
load test_helper

@test "net.hosts.ips()" {
  source lib/net.sh
  local hosts=(makeabox.io reinvent.one)
  local ips=(100.21.133.254 100.21.133.254)
  local index=0
  set -e
  for host in "${hosts[@]}"; do
    local ip="$(net.host.ip "${host}")"
	if [[ ! ${ip} == "${ips[${index}]}" ]]; then 
        printf "%30.30s → %s | result: %s\n" "${host}" "${ip}" "[invalid]" >&2 
        return 1
    fi
    index=$((index + 1))
  done
}

@test "net.host.ip()" {
  source lib/net.sh
  set -e
  local ip=$(net.host.ip makeabox.io)
  [[ ${ip} == "100.21.133.254" ]] # makeabox.io
}

@test "net.host.ips()" {
  source lib/net.sh
  set -e
  [[ $(net.host.ips one.one.one.one) == "1.0.0.1 1.1.1.1" ]]
}