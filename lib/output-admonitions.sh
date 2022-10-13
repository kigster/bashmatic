#!/usr/bin/env bash
# vim: ft=bash
#
# @description The width of this box is hardcoded to 90 charcters on the outside.

export           box_top="┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
export       box_divider="┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫"
export        box_bottom="┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
export box_bottom_shadow="████████████████████████████████████████████████████████████████████████████████████████"

function title-panel() {
  local line="$1"; shift
  local shadow="${title_shadow_color}██${clr}"

  printf "${clr}\n
 ${title_border_color} ${box_top} ${clr}\n"
    .title.line "${shadow}" "${line}"
  printf " ${title_border_color} ${box_divider} ${shadow}\n"

  for line in "$@"; do
    .title.line "${shadow}" "${line}"
  done
  
  printf " ${title_border_color} ${box_bottom} ${shadow}\n"
  printf " ${title_shadow_color}   ${box_bottom_shadow}${clr}\n\n"
}

function .title.line() {
  local shadow="$1"; shift
  printf " ${title_border_color} ┃   ${title_text_color}%-80.80s${title_border_color}  ${title_border_color}┃ ${shadow}\n" "$*"
}


function panel-red() {
  export title_text_color="${bg_bright_red}${bldwht}"
  export title_border_color="${bg_bright_red}${fg_dark_red}"
  export title_shadow_color="${fg_dark_red}"
  title-panel "$@"
}

function panel-red-yellow() {
  export title_text_color="${bg_bright_red}${bldwht}"
  export title_border_color="${bg_bright_red}${bldylw}"
  export title_shadow_color="${fg_dark_red}"
  title-panel "$@"
}

function panel-red-white() {
  export title_text_color="${bg_bright_red}${bldwht}"
  export title_border_color="${bg_bright_red}${bldwht}"
  export title_shadow_color="${fg_dark_red}"
  title-panel "$@"
}

function panel-purple-red() {
  export title_text_color="${bg_pink}${bldwht}"
  export title_border_color="${bg_pink}${bldred}"
  export title_shadow_color="${fg_dark_red}"
  title-panel "$@"
}

function panel-info() {
  export title_text_color="${txtwht}${bg_sky_blue}"
  export title_border_color="${txtblk}${bg_sky_blue}"
  export title_shadow_color="${bldblk}"
  title-panel "$@"
}

function panel-info-dark() {
  export title_text_color="${txtblk}${bakcyn}"
  export title_border_color="${txtblk}${bakcyn}"
  export title_shadow_color="${txtblu}"
  title-panel "$@"
}

function title-box() {
  printf "${clr}\n
 ${title_border_color} ┌─────────────────────────────────────────────────────────────────────────────────────┐ ${clr}\n"
  for line in "$@"; do
    printf " ${title_border_color} ┃  ${title_text_color}%83.83s${title_border_color}  ${clr}${title_border_color}┃ ${clr}${title_shadow_color}██${color_clear}\n" "${line}"
  done
  printf " ${title_border_color} └─────────────────────────────────────────────────────────────────────────────────────┘ ${clr}${title_shadow_color}██${color_clear}
    ${title_shadow_color}████████████████████████████████████████████████████████████████████████████████████████${color_clear}
\n"
}

function alert() {
  export title_text_color=${bold_yellow}
  export title_border_color=${color_red}
  export title_shadow_color=${bold_red}
  title-box "$@"
}

function title-yellow() {
  export title_text_color="${color_black}${bg_yellow_on_gray}"
  export title_border_color="${bg_yellow_on_gray}"
  export title_shadow_color="${fg_mustard}"
  title-box "$@"
}

function title-red() {
  export title_text_color="${bg_bright_red}${bldwht}"
  export title_border_color="${bg_bright_red}"
  export title_shadow_color="${fg_dark_red}"
  title-box "$@"
}

function title-blue() {
  export title_text_color="${color_black}${bg_sky_blue}"
  export title_border_color="${bg_sky_blue}"
  export title_shadow_color=${txtblu}
  title-box "$@"
}

function title-green() {
  export title_text_color=${color_black}${bakgrn}
  export title_border_color=${fg_bright_green}${bakgrn}
  export title_shadow_color=${fg_deep_green}
  title-box "$@"
}

function title() {
  title-blue "$@"
}

function divider() {
  local color="${1:-${fg_bright_green}}"
  printf " ${color}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${color_clear}\n"
}
