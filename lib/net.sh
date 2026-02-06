#!/usr/bin/env bash

net.local-net() {
  ifconfig -a | grep inet | grep broadcast | awk '{print $2}' | awk 'BEGIN{FS="."}{printf "%d.%d.%d.%s", $1, $2, $3, "0/24"}'
}

net.local-subnet() {
  local subnet="$(ifconfig -a |
    grep inet | grep broadcast |
    grep -v 'inet 169' |
    grep -v 'inet 127' |
    awk '{print $2}' |
    cut -d '.' -f 1,2,3 |
    sort |
    uniq |
    head -1).0/24"
  printf '%s' "${subnet}"
}

net.fast-scan() {
  local subnet="${1:-"$(net.local-subnet)"}"
  local out=$(mktemp)
  run.set-next show-output-on
  local colored=/tmp/colored.$$
  run "sudo nmap --min-parallelism 15 -O --host-timeout 5 -F ${subnet} > ${out}"
  run "echo 'printf \"' > ${colored}"
  cat "${out}" | sed -E "s/Nmap scan report for (.*)$/\n\${bldylw}Nmap scan report for \1\${clr}\n/g" >>${colored}
  run "echo '\"' >> ${colored}"
  bash ${colored}
  #rm -f ${colored}
}

# @description Uses pingless connection to check if a remote port is open
#              Requires sudo for UDP
# @arg1 host
# @arg2 port
# @arg3 [optional] protocol (defaults to "tcp", supports also "udp")
#
# @return 0 if connection is successful, 1 otherwise
function net.is-host-port-protocol-open() {
  local host="$1"
  local port="$2"
  local protocol="${3:-"tcp"}"

  local command="nmap"
  [[ ${protocol} =~ udp ]] && command="sudo nmap -sU"

  command -v nmap >/dev/null || brew.install.package nmap >&2
  ${command} -Pn -p "${port}" "${host}" 2>&1 | ascii-pipe | grep -q -E "${port}/${protocol} open "
}

# @description Resolves the IP address of a host and returns a single IP. If 
# the host has multiple IP addresses, it returns the last one, sorted numerically.
function net.host.ip() {
  local host="${1:-$(hostname)}"
  local ip=$(nslookup "${host}" 2>/dev/null | tail +4 |  grep -E 'Address:\s+\d'  | awk '{print $2}' | sort -n | tail -1)
  [[ -n ${ip} && ${ip} =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && printf '%s' "${ip}" || return 1
}

# @description Resolves the IP addresses of a host and returns them as a space-separated list suitable
# for insertion into a shell array.
function net.host.ips() {
  local host="${1:-$(hostname)}"
  nslookup "${host}" 2>/dev/null | tail +4 |  grep -E 'Address:\s+\d'  | awk '{print $2}' | sort -n | tr '\n' ' ' | sed -E 's/ +$//g'
}

# @description Resolves the IP addresses of a list of hosts and returns them as a space-separated list suitable
# for insertion into a shell array.
function net.hosts.ips() {
  local host ip
  while true; do
    host="${1:-$(hostname)}"; shift
    [[ -z ${host} ]] && break
    ip=$(net.host.ips "${host}" | sed -E 's/ +/, /g')
    if [[ -n ${ip} ]]; then
      printf "%30.30s → %s\n" "${host}" "${ip}"
    else
      printf "%30.30s → %s\n" "${host}" "not found"
    fi
  done | sed 's/\n\n/\n/g'
}

function net.localhost.ipv4s() {
  ifconfig -a | grep inet | awk '{print $2}' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
}

function net.localhost.ipv6s() {
  ifconfig -a | grep inet6 | awk '{print $2}'
}
