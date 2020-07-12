# Note, this function does not actually work as a function, but only with ZSH
# where it always detects "script" and never "sourced" unless you put them
# first line of the as your first line in the script.
#
# Therefore, it is here for the reference.

util.is-variable-defined() {
  local var_name="$1"
  [[ ${!var_name+x} ]]
}

util.random-number() {
  local limit="${1:-"1000000"}" # maxinum number
  printf $(((RANDOM % ${limit})))
}

util.generate-password() {
  local len=${1:-32}
  local val=$(($(date '+%s') - 100000 * $RANDOM))
  [[ ${val:0:1} == "-" ]] && val=${val/-//}
  printf "$(echo ${val} | shasum -a 512 | awk '{print $1}' | base64 | head -c ${len})"
}

# This returns true if the argument is numeric
util.is-numeric() {
  [[ -z $(echo ${1} | sed -E 's/^[0-9]+$//g') ]]
}

util.ver-to-i() {
  version=${1}
  echo ${version} | awk 'BEGIN{FS="."}{ printf "1%02d%03.3d%03.3d", $1, $2, $3}'
}

# Convert a result of .ver-to-i() back to a regular version.
util.i-to-ver() {
  version=${1}
  /usr/bin/env ruby -e "ver='${version}'; printf %Q{%d.%d.%d}, ver[1..2].to_i, ver[3..5].to_i, ver[6..8].to_i"
}

# Returns name of the current shell, eg 'bash'
util.shell-name() {
  echo $(basename $(printf $SHELL))
}

util.arch() {
  echo -n "${AppCurrentOS}-$(uname -m)-$(uname -p)" | tr 'A-Z' 'a-z'
}

util.shell-init-files() {
  shell_name=$(util.shell-name)
  if [[ ${shell_name} == "bash" ]]; then
    echo ".bash_${USER} .bash_profile .bashrc .profile"
  elif [[ ${shell_name} == "zsh" ]]; then
    echo ".zsh_${USER} .zshrc .profile"
  fi
}

util.append-to-init-files() {
  local string="$1"       # what to append
  local search="${2:-$1}" # what to grep for

  is_installed=

  declare -a shell_files=($(util.shell-init-files))
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
        echo "${string}" >>${file}
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
#   util.remove-froj-init-files direnv
#
# Will remove all lines matching direnv from all Bash init files.
#
util.remove-from-init-files() {
  local search="${1}" # lines matching this will be deleted
  local backup_extension="${2}"

  [[ -z ${backup_extension} ]] && backup_extension="$(epoch).backup"

  [[ -z ${search} ]] && return

  declare -a shell_files=($(util.shell-init-files))
  local temp_holder=$(mktemp)
  for init_file in ${shell_files[@]}; do
    run.config.detail-is-enabled && inf "verifying file ${init_file}..."
    file=${HOME}/${init_file}
    if [[ -f ${file} && -n $(grep "${search}" ${file}) ]]; then
      run.config.detail-is-enabled && ui.closer.ok:
      local matches=$(grep -c "${search}" ${file})
      run.config.detail-is-enabled && info "file ${init_file} matches with ${bldylw}${matches} matches"

      run "grep -v \"${search}\" ${file} > ${temp_holder}"
      if [[ -n "${backup_extension}" ]]; then
        local backup="${file}.${backup_extension}"

        run.config.detail-is-enabled && info "backup file will created in ${bldylw}${backup}"
        [[ -n "${do_backup_changes}" ]] && "mv ${file} ${backup}"
      fi
      run "cp -v ${temp_holder} ${file}"
    else
      run.config.detail-is-enabled && ui.closer.not-ok:
    fi
  done
  return ${LibRun__LastExitCode}
}

util.whats-installed() {
  declare -a hb_aliases=($(alias | ${GrepCommand} 'hb\..*=' | sedx 's/alias//g; s/=.*$//g'))
  h2 "Installed app aliases:" ' ' "${hb_aliases[@]}"

  h2 "Installed DB Functions:"
  info "hb.db  [ ms | r1 | r2 | c ]"
  info "hb.ssh <server-name-substring>, eg hb.ssh web"
}

util.is-a-function() {
  type "$1" 2>/dev/null | head -1 | grep -q 'is a function'
}

is-func() {
  util.is-a-function "$@"
}

util.call-if-function() {
  local func="$1"
  shift
  util.is-a-function "${func}" && {
    ${func} "$@"
  }
}

util.lines-in-folder() {
  local folder=${1:-'.'}
  find ${folder} -type f -exec wc -l {} \; | awk 'BEGIN{a=0}{a+=$1}END{print a}'
}

util.functions-starting-with() {
  local prefix="${1}"
  local extra_command=${2:-"cat"}
  set | ${GrepCommand} '()' | ${GrepCommand} "^${prefix}" | sedx 's/[\(\)]//g;' | ${extra_command} | tr '\n ' ' '
}

util.functions-matching() {
  local prefix="${1}"
  local extra_command=${2:-"cat"}
  set | ${GrepCommand} "^${prefix}" | sedx 's/[\(\)]//g;' | tr -d ' ' | tr '\n' ' '
}

util.functions-matching.diff() {
  for e in $(util.functions-matching "${1}"); do
    echo ${e/${1}/}
  done
}

util.checksum.files() {
  cat $* | shasum | awk '{print $1}'
}

util.checksum.stdin() {
  shasum | awk '{print $1}'
}

util.install-direnv() {
  [[ -n $(which direnv) ]] || brew.install.package direnv

  local init_file=
  local init_file=$(util.append-to-init-files 'eval "$(direnv hook bash)"; export DIRENV_LOG_FORMAT=' 'direnv hook')
  if [[ -f ${init_file} ]]; then
    info: "direnv init has been appended to ${bldylw}${init_file}..."
  else
    error: "direnv init could not be appended"
  fi

  eval "$(direnv hook bash)"
}

export BASHMATIC_UTIL_SED_COMMAND=

# This function ensures we have GNU sed installed, and if not,
# uses Brew on a Mac to install it.
#
# It is used by sedx() function
#———————————————————————————————————————————————————————
sedx.cache-command() {

  if [[ -z "${BASHMATIC_UTIL_SED_COMMAND}" ]]; then
    local sed_path
    local sed_command
    local os

    sed_path="$(which sed)"
    os="$(uname -s)"

    if [[ "${os}" == "Darwin" ]]; then
      local gsed_path
      gsed_path="$(which gsed)"

      if [[ -z "${gsed_path}" ]]; then
        [[ -n $(which brew) ]] || {
          error "Brew is needed to install GNU sed on OS-X"
          return 1
        }
        brew install gnu-sed 1>/dev/null 2>&1
        brew link gnu-sed --force 1>/dev/null 2>&1
        gsed_path="$(which gsed)"
      fi

      [[ -z "${gsed_path}" ]] && {
        error "Can't find GNU sed even after installation."
        return 2
      }

      sed_path="${gsed_path}"
    fi

    sed_command="${sed_path}"
  else
    sed_command="${BASHMATIC_UTIL_SED_COMMAND}"
  fi

  sed_command="${sed_command} -r -e "
  printf "%s" "${sed_command}"

  [[ -z ${BASHMATIC_UTIL_SED_COMMAND} ]] && \
    export BASHMATIC_UTIL_SED_COMMAND="${sed_command}"
}

sedx() {
  [[ -z ${BASHMATIC_UTIL_SED_COMMAND} ]] && \
    export BASHMATIC_UTIL_SED_COMMAND="$(sedx.cache-command)"

  ${BASHMATIC_UTIL_SED_COMMAND} "$*"
}

export LibUtil__WatchRefreshSeconds="0.5"

watch.set-refresh() {
  export LibUtil__WatchRefreshSeconds="${1:-"0.5"}"
}

watch.ls-al() {
  while true; do
    ls -al
    sleep ${LibUtil__WatchRefreshSeconds}
    clear
  done
}

watch.command() {
  [[ -z "$1" ]] && return 1
  trap "return 1" SIGINT
  while true; do
    clear
    hr.colored "${txtblu}"
    printf " ❯ Command: ${bldgrn}$*${clr}  •  ${txtblu}$(date)${clr}  •  Refresh: ${bldcyn}${LibUtil__WatchRefreshSeconds}${clr}\n"
    hr.colored "${txtblu}"
    eval "$*"
    hr.colored "${txtblu}"
    printf "To change refresh rate run ${bldylw}watch.set-refresh <seconds>${clr}\n\n\n"
    sleep "${LibUtil__WatchRefreshSeconds}"
  done
}

util.dev-setup.update() {
  run "rm -f ~/.bashmatic/bin/.dev-setup"
  run "dev-setup -N -h > /tmp/a"
  run "mv /tmp/a ~/.bashmatic/bin/.dev-setup"
  run "cd ~/.bashmatic && git add bin/.dev-setup"
  run "cd -"
}

pause() { sleep "${1:-1}"; }
pause.medium() { sleep "${1:-0.3}"; }
pause.short() { sleep "${1:-0.1}"; }
pause.long() { sleep "${1:-10}"; }
