#!/usr/bin/env bats
load test_helper

if [[ ${CI} != true ]]; then

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
    assert_equal "${ip}" "100.21.133.254"
  }

  @test "net.host.ips()" {
    source lib/net.sh
    set -e
    assert_equal "$(net.host.ips one.one.one.one)" "1.0.0.1 1.1.1.1"
  }
fi

@test "net.localhost.ipv4s()" {
  source lib/net.sh
  set -e
  local -a ips=($(ifconfig -a | grep inet | awk '{print $2}' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | sort -n))
  local -a local_ips=($(net.localhost.ipv4s | sort -n))

  local len=${#ips[@]}
  
  for i in $(seq "${len}"); do
    local j=$((i - 1))
    assert_equal "${ips[${j}]}" "${local_ips[${j}]}"
  done
}

@test "net.localhost.ipv6s()" {
  source lib/net.sh
  set -e
  local -a ips=($(ifconfig -a | grep inet6 | awk '{print $2}' | sort -n))
  local -a local_ips=($(net.localhost.ipv6s | sort -n))

  local len=${#ips[@]}
  
  for i in $(seq "${len}"); do
    local j=$((i - 1))
    assert_equal "${ips[${j}]}" "${local_ips[${j}]}"
  done
}