#!/usr/bin/env bash
# © 2016-2020 Konstantin Gredeskoul, All rights reserved. MIT License.
# Ported from the licensed under the MIT license Project Pullulant, at
# https://github.com/kigster/pullulant
#
# Any modifications, © 2016-2020 Konstantin Gredeskoul, All rights reserved. MIT License.

reset-color() {
  echo -en "${clr}"
}

color.enable() {
  if [[ -z "${AppColorsLoaded}" ]]; then

    export txtblk='\e[0;30m' # Black - Regular
    export txtred='\e[0;31m' # Red
    export txtgrn='\e[0;32m' # Green
    export txtylw='\e[0;33m' # Yellow
    export txtblu='\e[0;34m' # Blue
    export txtpur='\e[0;35m' # Purple
    export txtcyn='\e[0;36m' # Cyan
    export txtwht='\e[0;37m' # White

    export bldblk='\e[1;30m' # Black - Bold
    export bldred='\e[1;31m' # Red
    export bldgrn='\e[1;32m' # Green
    export bldylw='\e[1;33m' # Yellow
    export bldblu='\e[1;34m' # Blue
    export bldpur='\e[1;35m' # Purple
    export bldcyn='\e[1;36m' # Cyan
    export bldwht='\e[1;37m' # White

    export unkblk='\e[4;30m' # Black - Underline
    export undred='\e[4;31m' # Red
    export undgrn='\e[4;32m' # Green
    export undylw='\e[4;33m' # Yellow
    export undblu='\e[4;34m' # Blue
    export undpur='\e[4;35m' # Purple
    export undcyn='\e[4;36m' # Cyan
    export undwht='\e[4;37m' # White

    export bakblk='\e[40m' # Black - Background
    export bakred='\e[41m' # Red
    export bakgrn='\e[42m' # Green
    export bakylw='\e[43m' # Yellow
    export bakblu='\e[44m' # Blue
    export bakpur='\e[45m' # Purple
    export bakcyn='\e[46m' # Cyan
    export bakwht='\e[47m' # White

    export txtrst='\e[0m' # Text Reset
    export rst='\e[0m'    # Text Reset
    export clr='\e[0m'    # Text Reset

    export bold='\e[1m'
    export italic='\e[3m'
    export underlined='\e[4m'
    export strikethrough='\e[9m'

    export white_on_orange="\e[48;5;208m"
    export white_on_yellow="\e[48;5;214m"
    export white_on_red="\e[48;5;9m"
    export white_on_pink="\e[48;5;199m"
    export white_on_salmon="\e[48;5;196m"
    export yellow_on_gray="\e[38;5;220m\e[48;5;242m"

    export AppColorsLoaded=1
  else
    [[ -n ${DEBUG} ]] && echo "colors already loaded..."
  fi

  #trap reset-color EXIT
}

txt-info() { printf "${clr}${txtblu}"; }
txt-err() { printf "${clr}${bldylw}${bakred}"; }
txt-warn() { printf "${clr}${bldylw}"; }

error-text() { printf "${txtred}"; }
bold() { ansi 1 "$@"; }
italic() { ansi 3 "$@"; }
underline() { ansi 4 "$@"; }
strikethrough() { ansi 9 "$@"; }
red() { ansi 31 "$@"; }
ansi() { echo -e "\e[${1}m${*:2}\e[0m"; }

color.disable() {
  export clr='\e[0m' # Text Reset

  unset txtblk
  unset txtred
  unset txtgrn
  unset txtylw
  unset txtblu
  unset txtpur
  unset txtcyn
  unset txtwht
  unset bldblk
  unset bldred
  unset bldgrn
  unset bldylw
  unset bldblu
  unset bldpur
  unset bldcyn
  unset bldwht
  unset unkblk
  unset undred
  unset undgrn
  unset undylw
  unset undblu
  unset undpur
  unset undcyn
  unset undwht
  unset bakblk
  unset bakred
  unset bakgrn
  unset bakylw
  unset bakblu
  unset bakpur
  unset bakcyn
  unset bakwht
  unset txtrst
  unset italic
  unset bold
  unset strikethrough
  unset underlined

  unset white_on_orange
  unset white_on_yellow
  unset white_on_red
  unset white_on_pink
  unset white_on_salmon
  unset yellow_on_gray

  export AppColorsLoaded=1

  #trap reset-color EXIT
}

((${AppColorsLoaded})) || color.enable
