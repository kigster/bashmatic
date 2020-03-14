user.gitconfig.email() {
  if [[ -s ${HOME}/.gitconfig ]]; then
    grep email ${HOME}/.gitconfig | sedx 's/.*=\s?//g'
  fi
}

user.gitconfig.name() {
  if [[ -s ${HOME}/.gitconfig ]]; then
    grep name ${HOME}/.gitconfig | sedx 's/.*=\s?//g'
  fi
}

user.finger.name() {
  [[ -n $(which finge) ]] && finger ${USER} | head -1 | sedx 's/.*Name: //g'
}

user.username() {
  echo ${USER:-$(whoami)}
}

user() {
  local user
  user=$(user.finger.name)
  [[ -z "${user}" ]] && user="$(user.gitconfig.name)"
  [[ -z "${user}" ]] && user="$(user.gitconfig.email)"
  [[ -z "${user}" ]] && user="$(user.username)"
  echo "${user}"
}

user.first() {
  user | tr '\n' ' ' | ruby -ne 'puts $_.split(/ /).first.capitalize'
}

user.my.ip() {
  dig +short myip.opendns.com @resolver1.opendns.com
}

user.my.reverse-ip() {
  nslookup $(user.my.ip) | grep 'name =' | sedx 's/.*name = //g'
}

user.host() {
  local host=
  host=$(user.my.reverse-ip)
  [[ -z ${host} ]] && host=$(user.my.ip)
  printf "${host}"
}
