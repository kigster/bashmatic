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

  command -v nmap>/dev/null || brew.install.package nmap >&2
  ${command} -Pn -p "${port}" "${host}" 2>&1 | ascii-pipe | grep -q -E "${port}/${protocol} open "
}



