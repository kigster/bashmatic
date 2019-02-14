lib::user::gitconfig::email() {
  if [[ -s ${HOME}/.gitconfig ]]; then
    grep email ${HOME}/.gitconfig | hbsed 's/.*=\s?//g'
  fi
}

lib::user::gitconfig::name() {
  if [[ -s ${HOME}/.gitconfig ]]; then
    grep name ${HOME}/.gitconfig | hbsed 's/.*=\s?//g'
  fi
}

lib::user::finger::name() {
  [[ -n $(which finge) ]] && finger ${USER} | head -1 | hbsed 's/.*Name: //g'
}

lib::user::username() {
  echo ${USER:-$(whoami)}
}

lib::user() {
  local user
  user=$(lib::user::finger::name)
  [[ -z "${user}" ]] && user="$(lib::user::gitconfig::name)"
  [[ -z "${user}" ]] && user="$(lib::user::gitconfig::email)"
  [[ -z "${user}" ]] && user="$(lib::user::username)"
  echo "${user}"
}

lib::user::first() {
  lib::user | tr '\n' ' ' | ruby -ne 'puts $_.split(/ /).first.capitalize'
}

lib::user::my::ip() {
  dig +short myip.opendns.com @resolver1.opendns.com
}

lib::user::my::reverse-ip() {
  nslookup $(lib::user::my::ip) | grep 'name =' | hbsed 's/.*name = //g'
}

lib::user::host() {
  local host=
  host=$(lib::user::my::reverse-ip)
  [[ -z ${host} ]] && host=$(lib::user::my::ip)
  printf "${host}"
}
