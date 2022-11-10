#!/usr/bin/env bash
# @file osx.sh
# @description OSX Specific Helpers and Utilities

# @description
#   Checks if a given parameter matches any of the installed applications
#   under /Applications and ~/Applications
#
#   By the default prints the matched application. Pass `-q` as a second
#   argument to disable output.
#
# @example
#    ❯ osx.app.is-installed safari
#    Safari.app
#    ❯ osx.app.is-installed safari -q && echo installed
#    installed
#    ❯ osx.app.is-installed microsoft -c
#    6
#
# @arg $1 a string value to match (case insentively) for an app name
# @arg $2.. additional arguments to the last invocation of `grep`
#
# @exitcode 0 if match was found
# @exitcode 1 if not
function osx.app.is-installed() {
  local app="$1"
  shift

  /bin/ls -1 /Applications ~/Applications |
    grep -E '\.app$' |
    sort -u |
    grep "$@" -E -i "${app}|${app/*-/}"
}

function osx.dropbox.exclude() {
  local dir="$1"
  if [[ -d "${dir}" ]]; then
    xattr -w com.dropbox.ignored 1 "$1"
  else
    error "Folder '${dir}' does not exist or is blank."
    return 1
  fi
}

function osx.dropbox.exclude-pwd() {
  xattr -w com.dropbox.ignored 1 "${PWD}"
}

# Breaks up a file containing a pasted cookie into individual cookies sorted
# by cookie size. To use, either pass a file name as an argument, or have
# the cookie copied into the clipboard.
function osx.cookie-dump() {
  local file="$1"
  local tmp

  if [[ ! -s ${file} ]]; then
    tmp=$(mktemp)
    file=${tmp}
    pbpaste >"${file}"
    local size=$(file.size "${file}")
    if [[ ${size} -lt 4 ]]; then
      error "Pasted data is too small to be a valid cookie?"
      info "Here is what we got in your clipboard:\n\n$(cat "${file}")\n"
      return 1
    fi
  fi

  if [[ -s ${file} ]]; then
    cat "${file}" |
      tr '; ' '\n' |
      sed '/^$/d' |
      awk 'BEGIN{FS="="}{printf( "%10d = %s\n", length($2), $1) }' |
      sort -n
  else
    info "File ${file} does not exist or is empty. "
    info "Copy the value of the ${bldylw}Set-Cookie:${txtblu} header into the clipboard,"
    info "and rerun this function."
  fi

  [[ -z ${tmp} ]] || rm -f "${tmp}"

}

cookie-dump() {
  osx.cookie-dump "$@"
}

change-underscan() {
  set +
  local amount_percentage="$1"
  if [[ -z "${amount_percentage}" ]]; then
    printf "%s\n\n" "USAGE: change-underscan percent"
    printf "%s\n" "   eg: change-underscan   5  # underscan by 5%"
    printf "%s\n" "   eg: change-underscan -10  # overscan by 10%"
    return -1
  fi

  local file="/var/db/.com.apple.iokit.graphics"
  local backup="/var/db/.com.apple.iokit.graphics.bak.$(date '+%F.%X')"

  # Compute new value as a percentage of 10000
  local new_value=$(ruby - "puts (10000.0 + 10000.0 * ${amount_percentage}.to_f / 100.0).to_i")

  h1 'This utility allows you to change underscan/overscan' \
    'on monitors that do not offer that option via GUI.'

  run.ui.ask "Continue?"

  info "Great! First we need to identify your monitor."
  hl.yellow "Please make sure that the external monitor is plugged in."
  run.ui.ask "Is it plugged in?"

  info "Making a backup of your current graphics settings..."
  inf "Please enter your password, if asked: "
  set -
  bash -c 'set -  ; sudo ls -1 > /dev/null; set +  '
  ok
  run "sudo rm -f \"${backup}\""
  export LibRun__AbortOnError=${True}
  run "sudo cp -v \"${file}\" \"${backup}\""

  h2 "Now: please change the resolution ${bldylw}on the problem monitor." \
    "NOTE: it's ${italic}not important what resolution you choose," \
    "as long as it's different than what you had previously..." \
    "Finally: exit Display Preferences once you changed resolution."

  run "open /System/Library/PreferencePanes/Displays.prefPane"
  run.ui.ask "Have you changed the resolution and exited Display Prefs? "

  local line=$(sudo diff "${file}" "${backup}" 2>/dev/null | head -1 | /usr/bin/env ruby -ne 'puts $_.to_i')
  [[ -n ${BASHMATIC_DEBUG} ]] && info "diff line is at ${line}"
  value=

  if [[ "${line}" -gt 0 ]]; then
    line_pscn_key=$(($line - 4))
    line_pscn_value=$(($line - 3))
    (awk "NR==${line_pscn_key}{print;exit}" "${file}" | grep -q pscn) && {
      value=$(awk "NR==${line_pscn_value}{print;exit}" "${file}" | awk 'BEGIN{FS="[<>]"}{print $3}')
      [[ -n ${BASHMATIC_DEBUG} ]] && info "current value is ${value}"
    }
  else
    error "It does not appear that anything changed, sorry."
    return -1
  fi

  h2 "Now, please unplug the problem monitor temporarily..."
  run.ui.ask "...and press Enter to continue "

  if [[ -n ${value} && ${value} -ne ${new_value} ]]; then
    export LibRun__AbortOnError=${True}
    run "sudo sed -i.backup \"${line_pscn_value}s/${value}/${new_value}/g\" \"${file}\""
    echo
    h2 "Congratulations!" "Your display underscan value has been changed."
    info "Previous Value — ${bldpur}${value}"
    info "New value:     — ${bldgrn}${new_value}"
    hr
    info "${bldylw}IMPORTANT!"
    info "You must restart your computer for the settings to take affect."
    echo
    run.ui.ask "Should I reboot your computer now? "
    info "Very well, rebooting!"
    run "sudo reboot"
  else
    warning "Unable to find the display scan value to change. "
    info "Could it be that you haven't restarted since your last run?"
    echo
    info "Feel free to edit file directly, using:"
    info "eg: ${bldylw}vim ${file} +${line_pscn_value}"
  fi
}

# This function creates a tiny RAM disk on /var/ramdisk where the
# decrypted settings will be stored until a reboot.
#
# usage: osx.ramdisk.mount N
# where N is number of Mb allocated
osx.ramdisk.mount() {
  local size="${1:-"8"}"
  local diskname="${2:-"ramdisk"}"

  local total=$((size * 2 * 1024))
  util.os
  [[ ${BASHMATIC_OS} != "darwin" ]] && {
    error "This function only works on OSX"
    return 1
  }

  if [[ "${diskname}" =~ ' ' ]]; then
    error "Disk name can not contain spaces."
    return 1
  fi

  local path="/Volumes/${diskname}"

  if (mount | ${GrepCommand} -q "/[V]olumes/${diskname}"); then
    info "Looks like RAM disk already exists at ${path}..."
    return 1
  else
    run.ui.ask "Creating RAM disk sized ${size}Mb at ${path}"
    run.set-next show-output-on
    run "diskutil erasevolume HFS+ '${diskname}' $(hdiutil attach -nomount ram://${total})"
  fi
}

# This function creates a tiny RAM disk on /var/ramdisk where the
# decrypted settings will be stored until a reboot.
osx.ramdisk.unmount() {
  local diskname="${2:-"ramdisk"}"

  [[ $(os.util) != "darwin" ]] && {
    error "This function only works on OSX"
    return 1
  }

  local path="/Volumes/${diskname}"

  if (mount | ${GrepCommand} -q "/[V]olumes/${diskname}"); then
    run.ui.ask "Unmount RAM disk at ${path}? "
    run "umount ${path}"
  else
    info "Couldn't find volume ${bldylw}${path}. Does the RAM disk exist?"
    return 1
  fi
}

# Pass a fully qualified domain name, such as "apollo.mydomain.me"
# This function will set the computer name to "apollo", and HostName to the
# full fqdn.
osx.set-fqdn() {
  local fqdn="$1"
  local domain=$(echo "${fqdn}" | sed -E 's/^[^.]*\.//g')
  local host=$(echo "${fqdn}" | sed -E 's/\..*//g')

  h1 "Current HostName: ${bldylw}${HOSTNAME}"

  echo

  info "• You provided the following FQDN : ${bldylw}${fqdn}"
  echo
  info "• Hostname will be set to: ${bldgrn}${host}"
  info "• Domain will also change: ${bldgrn}${domain}"

  echo

  run.ui.ask "Does that look correct to you?"

  echo

  inf "Now, please provide your SUDO password, if asked: "

  sudo printf '' || {
    ui.closer.not-ok:
    exit 1
  }

  ui.closer.ok:

  run "sudo scutil --set HostName ${fqdn}"
  run "sudo scutil --set LocalHostName ${host}.local 2>/dev/null|| true"
  run "sudo scutil --set ComputerName ${host}"

  run "dscacheutil -flushcache"

  echo

  h2 "Result of the changes:"

  osx.scutil-print HostName
  osx.scutil-print LocalHostName
  osx.scutil-print ComputerName
  osx.env-print HOSTNAME
  echo
  hr
}

osx.scutil-print() {
  local var="$1"
  printf "${bldylw}%20s: ${bldgrn}%s\n" "${var}" $(sudo scutil --get "${var}" | tr -d '\n')
}

osx.env-print() {
  local var="$1"
  printf "${bldylw}%20s: ${bldgrn}%s\n" "${var}" "${!var}"
}

bashmatic-set-fqdn() {
  osx.set-fqdn "$@"
}

bashmatic-term-program() {
  if [[ -d /Applications/iTerm.app ]]; then
    printf '%s' /Applications/iTerm.app
  elif [[ -d /Applications/Utilities/Terminal.app ]]; then
    printf '%s' /Applications/Utilities/Terminal.app
  else
    printf '%s' "echo 'No TERMINAL application found'"
  fi
}

bashmatic-term() {
  open "$(bashmatic-term-program)"
}

osx.local-servers() {
  local protocol="${1:-"ssh"}"
  run.set-next show-output-on
  run "timeout 20 dns-sd -B _${protocol}._tcp ."
}

ssh.servers() { osx.local-servers ssh; }
afp.servers() { osx.local-servers afp; }
http.servers() { osx.local-servers http; }
https.servers() { osx.local-servers https; }

# @description This function checks the architecture of the CPU, but
#       also is able to detect when M1 system is running under Rosetta.
# @return an array of two items:  [ intel | m1 ] [ native | rosetta 
# @example
#     local -a ostype=( $(osx.detect-cpu) )
#     local cpu=${ostype[0]}
#     local emulation="${ostype[1]}"
function osx.detect-cpu() {
  local arch_name="$(uname -m)"

  if [[ "${arch_name}" = "x86_64" ]]; then
    if [[ "$(sysctl -in sysctl.proc_translated)" = "1" ]]; then
      echo m1 rosetta
    else
      echo intel native
    fi
  elif [ "${arch_name}" = "arm64" ]; then
    echo m1 native
  else
    echo unknown unknown 
  fi
}


