#!/usr/bin/env bash

# Breaks up a file containing a pasted cookie into individual cookies sorted
# by cookie size. To use, either pass a file name as an argument, or have
# the cookie copied into the clipboard.
lib::osx::cookie-dump() {
  local file="$1"
  local tmp

  if [[ ! -s ${file} ]]; then
    tmp=$(mktemp)
    file=${tmp}
    pbpaste > ${file}
    local size=$(file::size ${file})
    if [[ ${size} -lt 4 ]] ; then
      error "Pasted data is too small to be a valid cookie?"
      info "Here is what we got in your clipboard:\n\n$(cat ${file})\n"
      return 1
    fi
  fi

  if [[ -s ${file} ]]; then
    cat "${file}" | \
      tr '; ' '\n' | \
      sed '/^$/d' | \
      awk 'BEGIN{FS="="}{printf( "%10d = %s\n", length($2), $1) }' | \
      sort -n
  else
    info "File ${file} does not exist or is empty. "
    info "Copy the value of the ${bldylw}Set-Cookie:${txtblu} header into the clipboard,"
    info "and rerun this function."
  fi

  [[ -z ${tmp} ]] || rm -f ${tmp}

}

cookie-dump() {
  lib::osx::cookie-dump "$@"
}

lib::osx::display::change-underscan() {
  set +e
  local amount_percentage="$1"
  if [[ -z "${amount_percentage}" ]] ; then
    printf "    usage: $0 <percentage-change> \n"
    printf "       eg: $0 5    # underscan by 5% \n"
    return -1
  fi

  local file="/var/db/.com.apple.iokit.graphics"
  local backup="/tmp/.com.apple.iokit.graphics.bak"

  local amount=$(( 100 * ${amount_percentage} ))

  h1 'This utility allows you to change underscan/overscan' \
     'on monitors that do not offer that option via GUI.'

  lib::run::ask "Continue?"

  info "Great! First we need to identify your monitor."
  hl::yellow "Please make sure that the external monitor is plugged in."
  lib::run::ask "Is it plugged in?"

  info "Making a backup of your current graphics settings..."
  inf "Please enter your password, if asked: "
  set -e
  bash -c 'set -e; sudo ls -1 > /dev/null; set +e'
  ok
  run "sudo rm -f \"${backup}\""
  export LibRun__AbortOnError=${True}
  run "sudo cp -v \"${file}\" \"${backup}\""

  h2  "Now: please change the resolution ${bldylw}on the problem monitor." \
      "NOTE: it's ${italic}not important what resolution you choose," \
      "as long as it's different than what you had previously..." \
      "Finally: exit Display Preferences once you changed resolution."

  run "open /System/Library/PreferencePanes/Displays.prefPane"
  lib::run::ask "Have you changed the resolution and exited Display Prefs? "

  local line=$(sudo diff "${file}" "${backup}" 2>/dev/null | head -1 | /usr/bin/env ruby -ne 'puts $_.to_i')
  [[ -n $DEBUG ]] && info "diff line is at ${line}"
  value=

  if [[ "${line}" -gt 0 ]]; then
    line_pscn_key=$(( $line - 4 ))
    line_pscn_value=$(( $line - 3 ))
    ( awk "NR==${line_pscn_key}{print;exit}" "${file}" | grep -q pscn ) && {
      value=$(awk "NR==${line_pscn_value}{print;exit}" "${file}" | awk 'BEGIN{FS="[<>]"}{print $3}')
      [[ -n $DEBUG ]] && info "current value is ${value}"
    }
  else
    error "It does not appear that anything changed, sorry."
    return -1
  fi

  h2 "Now, please unplug the problem monitor temporarily..."
  lib::run::ask "...and press Enter to continue "

  if [[ -n ${value} ]]; then
    local new_value=$(( $value - ${amount} ))
    export LibRun__AbortOnError=${True}
    run "sudo sed -i.backup \"${line_pscn_value}s/${value}/${new_value}/g\" \"${file}\""
    echo
    h2 "Congratulations!" "Your display underscan value has been changed."
    info "Previous Value  ${bldpur}${value}"
    info "New value:      ${bldgrn}${new_value}"
    hr
    info "${bldylw}IMPORTANT!"
    info "You must restart your computer for the settings to take affect."
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
lib::osx::ramdisk::mount() {
  [[ $(uname -s) != "Darwin" ]] && {
    error "This function only works on OSX"
    return 1
  }
  if [[ -z $(df -h | grep ramdisk) ]]; then
    diskutil erasevolume HFS+ 'ramdisk' `hdiutil attach -nomount ram://8192`
  fi
}


# This function creates a tiny RAM disk on /var/ramdisk where the
# decrypted settings will be stored until a reboot.
lib::osx::ramdisk::unmount() {
  [[ $(uname -s) != "Darwin" ]] && {
    error "This function only works on OSX"
    return 1
  }
  if [[ -n $(df -h | grep ramdisk) ]]; then
    umount /Volumes/ramdisk
  fi
}

# Pass a fully qualified domain name, such as "apollo.mydomain.me"
# This function will set the computer name to "apollo", and HostName to the
# full fqdn.
lib::osx::set-fqdn() {
  local fqdn="$1"
  local domain=$(echo ${fqdn} | sed -E 's/^[^.]*\.//g')
  local host=$(echo ${fqdn} | sed -E 's/\..*//g')

  h1 "Current HostName: ${bldylw}${HOSTNAME}"

  echo

  info "• You provided the following FQDN : ${bldylw}${fqdn}"
  echo
  info "• Hostname will be set to: ${bldgrn}${host}"
  info "• Domain will also change: ${bldgrn}${domain}"

 
  echo

  lib::run::ask "Does that look correct to you?"

  echo

  inf "Now, please provide your SUDO password, if asked: "

  sudo printf '' || {
    not_ok: 
    exit 1
  }

  ok:

  run "sudo scutil --set HostName ${fqdn}"
  run "sudo scutil --set LocalHostName ${host}.local 2>/dev/null|| true"
  run "sudo scutil --set ComputerName ${host}"
  
  run "dscacheutil -flushcache"

  echo

  h2 "Result of the changes:"

  lib::osx::scutil-print HostName
  lib::osx::scutil-print LocalHostName
  lib::osx::scutil-print ComputerName
  lib::osx::env-print HOSTNAME
  echo
  hr
}

lib::osx::scutil-print() {
  local var="$1"
  printf "${bldylw}%20s: ${bldgrn}%s\n" ${var} $(sudo scutil --get ${var} | tr -d '\n')
}

lib::osx::env-print() {
  local var="$1"
  printf "${bldylw}%20s: ${bldgrn}%s\n" ${var} ${!var}
}

bashmatic-set-fqdn() {
  lib::osx::set-fqdn "$@"
}

bashmatic-term-program() {
  if [[ -d /Applications/iTerm.app ]] ; then
    printf '%s' /Applications/iTerm.app
  elif [[ -d /Applications/Utilities/Terminal.app ]]; then
    printf '%s' /Applications/Utilities/Terminal.app
  else
    printf '%s' "echo 'No TERMINAL application found'"
  fi
}

bashmatic-term() {
  open $(bashmatic-term-program)
}
