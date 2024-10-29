#!/usr/bin/env bash
# © 2016-2024 Konstantin Gredeskoul, All rights reserved. MIT License.
# Ported from the licensed under the MIT license Project Pullulant, at
# https://github.com/kigster/pullulant
#
# Any modifications, © 2016-2024 Konstantin Gredeskoul, All rights reserved. MIT License.

export BashMatic__ColorLoaded=${BashMatic__ColorLoaded:-"0"}

[[ -z ${GLOBAL} ]] && export GLOBAL="declare "
[[ ${SHELL} =~ zsh ]] && export GLOBAL="declare -g "

if [[ ${BashMatic__ColorLoaded} -ne 1 ]]; then
  DECLARATIONS="

  ${GLOBAL} txtblk
  ${GLOBAL} txtred
  ${GLOBAL} txtgrn
  ${GLOBAL} txtylw
  ${GLOBAL} txtblu
  ${GLOBAL} txtpur
  ${GLOBAL} txtcyn
  ${GLOBAL} txtwht

  ${GLOBAL} bldblk
  ${GLOBAL} bldred
  ${GLOBAL} bldgrn
  ${GLOBAL} bldylw
  ${GLOBAL} bldblu
  ${GLOBAL} bldpur
  ${GLOBAL} bldcyn
  ${GLOBAL} bldwht

  ${GLOBAL} unkblk
  ${GLOBAL} undred
  ${GLOBAL} undgrn
  ${GLOBAL} undylw
  ${GLOBAL} undblu
  ${GLOBAL} undpur
  ${GLOBAL} undcyn
  ${GLOBAL} undwht

  ${GLOBAL} bakblk
  ${GLOBAL} bakred
  ${GLOBAL} bakgrn
  ${GLOBAL} bakylw
  ${GLOBAL} bakblu
  ${GLOBAL} bakpur
  ${GLOBAL} bakcyn
  ${GLOBAL} bakwht

  ${GLOBAL} txtrst
  ${GLOBAL} rst
  ${GLOBAL} clr

  ${GLOBAL} bold
  ${GLOBAL} italic
  ${GLOBAL} underlined
  ${GLOBAL} strikethrough

  ${GLOBAL} inverse_on
  ${GLOBAL} inverse_off
  ${GLOBAL} default_bg
  ${GLOBAL} default_fg

  ${GLOBAL} black_on_orange
  ${GLOBAL} black_on_yellow

  ${GLOBAL} white_on_orange
  ${GLOBAL} white_on_yellow

  ${GLOBAL} white_on_red
  ${GLOBAL} white_on_pink
  ${GLOBAL} white_on_salmon
  ${GLOBAL} yellow_on_gray

  ${GLOBAL} bg_blood
  ${GLOBAL} bg_blue_on_gray
  ${GLOBAL} bg_bright_green
  ${GLOBAL} bg_dark_green
  ${GLOBAL} bg_bright_red
  ${GLOBAL} bg_deep_blue
  ${GLOBAL} bg_deep_green
  ${GLOBAL} bg_green_on_gray
  ${GLOBAL} bg_grey
  ${GLOBAL} bg_mustard
  ${GLOBAL} bg_pink
  ${GLOBAL} bg_sky_blue
  ${GLOBAL} bg_yellow_on_gray

  ${GLOBAL} fg_dark_red
  ${GLOBAL} fg_bright_green
  ${GLOBAL} fg_sky_blue
  ${GLOBAL} fg_deep_green
  ${GLOBAL} fg_doll
  ${GLOBAL} fg_grey
  ${GLOBAL} fg_light_green
  ${GLOBAL} fg_mustard
  ${GLOBAL} fg_mustard
  ${GLOBAL} fg_pink
  ${GLOBAL} fg_purr

  ${GLOBAL} BashMatic__ColorLoaded

  ${GLOBAL} bg_blood
  ${GLOBAL} bg_blue_on_gray
  ${GLOBAL} bg_bright_green
  ${GLOBAL} bg_dark_green
  ${GLOBAL} bg_bright_red
  ${GLOBAL} bg_deep_blue
  ${GLOBAL} bg_deep_green
  ${GLOBAL} bg_green_on_gray
  ${GLOBAL} bg_grey
  ${GLOBAL} bg_mustard
  ${GLOBAL} bg_pink
  ${GLOBAL} bg_sky_blue
  ${GLOBAL} bg_yellow_on_gray

  ${GLOBAL} fg_dark_red
  ${GLOBAL} fg_bright_green
  ${GLOBAL} fg_sky_blue
  ${GLOBAL} fg_deep_green
  ${GLOBAL} fg_doll
  ${GLOBAL} fg_grey
  ${GLOBAL} fg_light_green
  ${GLOBAL} fg_mustard
  ${GLOBAL} fg_mustard
  ${GLOBAL} fg_pink
  ${GLOBAL} fg_purr
  "

  eval "${DECLARATIONS}"

fi

function reset-color() {
  echo -en "${clr}"
}

# @description Prints the background color of the terminal, assuming terminal responds
#              to the escape sequence. More info:
#              https://stackoverflow.com/questions/2507337/how-to-determine-a-terminals-background-color
function color.current-background() {
  printf "\e]11;?\a"
}

function color.enable() {
  export BashMatic__ColorLoaded=1

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

  export inverse_on='\e[7m'
  export inverse_off='\e[27m'
  export default_bg='\e[49m'
  export default_fg='\e[39m'

  export black_on_orange="\e[48;5;208m\e[48;30;208m"
  export black_on_yellow="\e[48;5;11m\e[48;30;209m"

  export white_on_orange="\e[48;5;208m"
  export white_on_yellow="\e[48;5;214m"

  export white_on_red="\e[48;5;9m"
  export white_on_pink="\e[48;5;199m"
  export white_on_salmon="\e[48;5;196m"
  export yellow_on_gray="\e[38;5;220m\e[48;5;242m"

  export bg_blood="\e[41m"
  export bg_blue_on_gray="\e[90;7;42m"
  export bg_bright_green="\e[48;5;82m"
  export bg_dark_green="\e[48;5;82m"
  export bg_bright_red="\e[1;31m\e[48;5;196m"
  export bg_deep_blue="\e[48;5;37m"
  export bg_deep_green="\e[48;5;28m"
  export bg_green_on_gray="\e[90;7;102m"
  export bg_grey="\e[48;5;239m"
  export bg_mustard="\e[48;5;178m"
  export bg_pink="\e[48;5;89m"
  export bg_sky_blue="\e[48;5;39m"
  export bg_yellow_on_gray="\e[7;33;43m"

  export fg_dark_red="\e[38;5;88m"
  export fg_bright_green="\e[38;5;82m"
  export fg_sky_blue="\e[38;5;39m"
  export fg_deep_green="\e[38;5;28m"
  export fg_doll="\e[38;5;183m"
  export fg_grey="\e[38;5;239m"
  export fg_light_green="\e[38;5;108m"
  export fg_mustard="\e[38;5;178m"
  export fg_mustard="\e[38;5;178m"
  export fg_pink="\e[38;5;89m"
  export fg_purr="\e[38;5;219m"

  export BashMatic__ColorLoaded=1

  export bg_blood="\e[41m"
  export bg_blue_on_gray="\e[90;7;42m"
  export bg_bright_green="\e[48;5;82m"
  export bg_dark_green="\e[48;5;82m"
  export bg_bright_red="\e[1;31m\e[48;5;196m"
  export bg_deep_blue="\e[48;5;37m"
  export bg_deep_green="\e[48;5;28m"
  export bg_green_on_gray="\e[90;7;102m"
  export bg_grey="\e[48;5;239m"
  export bg_mustard="\e[48;5;178m"
  export bg_pink="\e[48;5;89m"
  export bg_sky_blue="\e[48;5;39m"
  export bg_yellow_on_gray="\e[90;7;43m"

  export fg_dark_red="\e[38;5;88m"
  export fg_bright_green="\e[38;5;82m"
  export fg_sky_blue="\e[38;5;39m"
  export fg_deep_green="\e[38;5;28m"
  export fg_doll="\e[38;5;183m"
  export fg_grey="\e[38;5;239m"
  export fg_light_green="\e[38;5;108m"
  export fg_mustard="\e[38;5;178m"
  export fg_mustard="\e[38;5;178m"
  export fg_pink="\e[38;5;89m"
  export fg_purr="\e[38;5;219m"
}

[[ ${BashMatic__ColorLoaded} -eq 0 ]] && color.enable


function txt-info() { printf "${clr}${txtblu}"; }
function txt-err() { printf "${clr}${bldylw}${bakred}"; }
function txt-warn() { printf "${clr}${bldylw}"; }

function error-text() { printf "${txtred}"; }
function bold() { .ansi 1 "$@"; }
function italic() { .ansi 3 "$@"; }
function underline() { .ansi 4 "$@"; }
function strikethrough() { .ansi 9 "$@"; }
function red() { .ansi 31 "$@"; }
function .ansi() { echo -e "\e[${1}m${*:2}\e[0m"; }

function color.disable() {
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

  unset bg_blood
  unset bg_blue_on_gray
  unset bg_bright_green
  unset bg_dark_green
  unset bg_bright_red
  unset bg_deep_blue
  unset bg_deep_green
  unset bg_green_on_gray
  unset bg_grey
  unset bg_mustard
  unset bg_pink
  unset bg_sky_blue
  unset bg_yellow_on_gray
  unset fg_dark_red
  unset fg_bright_green
  unset fg_sky_blue
  unset fg_deep_green
  unset fg_doll
  unset fg_grey
  unset fg_light_green
  unset fg_mustard
  unset fg_mustard
  unset fg_pink
  unset fg_purr

  export BashMatic__ColorLoaded=0
}

function color.wheel() {
  for x in 0 1 4 5 7 8; do 
    for i in {30..37}; do 
      for a in {40..47}; do 
        echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m "; 
      done; echo; 
    done; 
  done; 
  echo "";
}
