#!/usr/bin/env bash

net.local-subnet() {
  local subnet="$(ifconfig -a |
    grep 'inet ' |
    ${GrepCommand} -v 'inet 169|inet 127' |
    awk '{print $2}' |
    cut -d '.' -f 1,2,3 |
    sort |
    uniq |
    head -1).0/24"
  printf '%s' ${subnet}
}

net.fast-scan() {
  local subnet="${1:-"$(...net.local-subnet)"}"
  local out=$(mktemp)
  run.set-next show-output-on
  local colored=/tmp/colored.$$
  run "sudo nmap --min-parallelism 15 -O --host-timeout 5 -F ${subnet} > ${out}"
  run "echo 'printf \"' > ${colored}"
  cat ${out} | sed -E "s/Nmap scan report for (.*)$/\n\${bldylw}Nmap scan report for \1\${clr}\n/g" >>${colored}
  run "echo '\"' >> ${colored}"
  bash ${colored}
  #rm -f ${colored}
}
