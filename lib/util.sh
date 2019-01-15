#!/usr/bin/env bash
# Note, this function does not actually work as a function, but only with ZSH
# where it always detects "script" and never "sourced" unless you put them
# first line of the as your first line in the script.
#
# Therefore, it is here for the reference.

lib::util::generate-password() {
   local len=${1:-32}
   local val=$(($(date '+%s') - 100000 * $RANDOM))
   [[ ${val:0:1} == "-" ]] && val=${val/-//}
   printf $(echo ${val} | shasum -a 512 | awk '{print $1}' | base64 | head -c ${len})
 }

# This returns true if the argument is numeric
lib::util::is-numeric() {
  [[ -z $(echo ${1} | sed -E 's/^[0-9]+$//g') ]]
}

lib::util::ver-to-i() {
  version=${1}
  echo ${version} | awk 'BEGIN{FS="."}{ printf "1%02d%03.3d%03.3d", $1, $2, $3}'
}

# Convert a result of __lib::ver-to-i() back to a regular version.
lib::util::i-to-ver() {
  version=${1}
  /usr/bin/env ruby -e "ver='${version}'; printf %Q{%d.%d.%d}, ver[1..2].to_i, ver[3..5].to_i, ver[6..8].to_i"
}

# Returns name of the current shell, eg 'bash'
lib::util::shell-name() {
  echo $(basename $(printf $SHELL))
}

lib::util::arch() {
  echo -n "${AppCurrentOS}-$(uname -m)-$(uname -p)" | tr 'A-Z' 'a-z'
}

lib::util::shell-init-files() {
  shell_name=$(lib::util::shell-name)
  if [[ ${shell_name} == "bash" ]]; then
    echo ".bash_${USER} .bash_profile .bashrc .profile"
  elif [[ ${shell_name} == "zsh" ]]; then
    echo ".zsh_${USER} .zshrc .profile"
  fi
}

lib::util::append-to-init-files() {
  local string="$1"       # what to append
  local search="${2:-$1}" # what to grep for

  is_installed=

  declare -a shell_files=($(lib::util::shell-init-files))
  for init_file in ${shell_files[@]}; do
    file=${HOME}/${init_file}
    [[ -f ${file} && -n $(grep "${search}" ${file}) ]] && {
      is_installed=${file}
      break
    }
  done

  if [[ -z "${is_installed}" ]]; then
    for init_file in ${shell_files[@]}; do
      file=${HOME}/${init_file}
      [[ -f ${file} ]] && {
        echo "${string}" >> ${file}
        is_installed="${file}"
        break
      }
    done
  fi

  printf "${is_installed}"
}

# Description:
#   This function checks BASH init files one by one for a given string.
#   It then removes all lines matching that string from those files.
#
# Usage:
#   lib::util::remove-froj-init-files direnv
#
# Will remove all lines matching direnv from all Bash init files.
#
lib::util::remove-from-init-files() {
  local search="${1}" # lines matching this will be deleted
  local backup_extension="${2}"

  [[ -z ${backup_extension} ]] && backup_extension="$(epoch).backup"

  [[ -z ${search} ]] && return

  declare -a shell_files=($(lib::util::shell-init-files))
  local temp_holder=$(mktemp)
  for init_file in ${shell_files[@]}; do
    is_detail && inf "verifying file ${init_file}..."
    file=${HOME}/${init_file}
    if [[ -f ${file} && -n $(grep "${search}" ${file}) ]] ; then
      is_detail && ok:
      local matches=$(grep -c "${search}" ${file})
      is_detail && info "file ${init_file} matches with ${bldylw}${matches} matches"

      run "grep -v \"${search}\" ${file} > ${temp_holder}"
      if [[ -n "${backup_extension}" ]]; then
        local backup="${file}.${backup_extension}"

        is_detail && info "backup file will created in ${bldylw}${backup}"
        [[ -n "${do_backup_changes}" ]] && "mv ${file} ${backup}"
      fi
      run "cp -v ${temp_holder} ${file}"
    else
      is_detail && not_ok:
    fi
  done
  return ${LibRun__LastExitStatus}
}

lib::util::whats-installed() {
  declare -a hb_aliases=($(alias | grep -E 'hb\..*=' | hbsed 's/alias//g; s/=.*$//g'))
  h2 "Installed app aliases:" ' ' "${hb_aliases[@]}"

  h2 "Installed DB Functions:"
  info "hb.db  [ ms | r1 | r2 | c ]"
  info "hb.ssh <server-name-substring>, eg hb.ssh web"
}

lib::util::lines-in-folder() {
  local folder=${1:-'.'}
  find ${folder} -type f -exec wc -l {} \;| awk 'BEGIN{a=0}{a+=$1}END{print a}'
}

lib::util::functions-matching() {
  local prefix=${1}
  local extra_command=${2:-"cat"}
  set | egrep "^${prefix}" | sed -E 's/.*:://g; s/[\(\)]//g;' | ${extra_command} | tr '\n ' ' '
}

lib::util::checksum::files() {
  cat $* | shasum | awk '{print $1}'
}

lib::util::install-direnv() {
  [[ -n $(which direnv) ]] || lib::brew::install::package direnv

  local init_file=
  local init_file=$(lib::util::append-to-init-files 'eval "$(direnv hook bash)"; export DIRENV_LOG_FORMAT=' 'direnv hook')
  if [[ -f ${init_file} ]] ; then
    info: "direnv init has been appended to ${bldylw}${init_file}..."
  else
    error: "direnv init could not be appended"
  fi

  eval "$(direnv hook bash)"
}
