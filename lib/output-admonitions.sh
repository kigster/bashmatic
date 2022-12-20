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
  .title.line "${shadow}" "${title_title_color:-${title_text_color}}" "${line}"
  if [[ ${#@} -gt 0 ]]; then
    printf " ${title_border_color} ${box_divider} ${shadow}\n"
    for line in "$@"; do
      .title.line "${shadow}" "${title_text_color}" "${line}"
    done
  fi
    
  printf " ${title_border_color} ${box_bottom} ${shadow}\n"
  printf " ${title_shadow_color}   ${box_bottom_shadow}${clr}\n\n"
}

function .title.line() {
  local shadow="$1"; shift
  local text_color="$1"; shift
  printf " ${clr}${title_border_color} ┃  ${clr}${text_color}%-80.80s${clr}${title_border_color}   ┃ ${shadow}\n" "$*"
}

function panel-error() {
  export title_title_color="${bg_bright_red}${bldwht}"
  export title_text_color="${bg_bright_red}${bldwht}"
  export title_border_color="${bg_bright_red}${fg_dark_red}"
  export title_shadow_color="${fg_dark_red}"
  title-panel "$@"
}


function box-error() {
  panel-error "$@"
}


function panel-error-yellow() {
  export title_title_color="${bldwht}${bakred}"
  export title_text_color="${bldylw}${bakred}"
  export title_border_color="${bldylw}${bakred}"
  export title_shadow_color="${fg_dark_red}"
  title-panel "$@"
}

function panel-info-yellow() {
  export title_title_color="${bldwht}${bakgrn}"
  export title_text_color="${bldylw}${bakgrn}"
  export title_border_color="${bldylw}${bakgrn}"
  export title_shadow_color="${fg_deep_blue}"
  title-panel "$@"
}

function panel-info-blue() {
  export title_title_color="${bldwht}${bg_sky_blue}"
  export title_text_color="${bldwht}${bg_sky_blue}"
  export title_border_color="${bldwht}${fg_deep_blue}"
  export title_shadow_color="${fg_deep_blue}"
  title-panel "$@"
}

function panel-green() {
  export title_title_color="${txtblk}${bg_bright_green}"
  export title_text_color="${txtblk}${bg_bright_green}"
  export title_border_color="${fg_deep_green}${bg_bright_green}"
  export title_shadow_color="${fg_deep_green}"
  title-panel "$@"
}

function box-success() {
  panel-green "$@"
}


function panel-info-blue-black() {
  export title_title_color="${txtblk}${bg_sky_blue}"
  export title_text_color="${txtblk}${bg_sky_blue}"
  export title_border_color="${txtblk}${bg_sky_blue}"
  export title_shadow_color="${fg_deep_blue}"
  title-panel "$@"
}

function panel-error-yellow() {
  export title_title_color="${bldwht}${bakred}"
  export title_text_color="${bldylw}${bakred}"
  export title_border_color="${bldylw}${bakred}"
  export title_shadow_color="${fg_dark_red}"
  title-panel "$@"
}

function panel-red-white() {
  export title_title_color="${fg_bright_red}"
  export title_text_color="${bg_bright_red}${bg_mustard}"
  export title_border_color="${bg_mustard}${bldwht}"
  export title_shadow_color="${fg_dark_red}"
  title-panel "$@"
}

function box-warning() {
  panel-red-white "$@"
}

function panel-purple-red() {
  export title_title_color="${fg_bright_red}"
  export title_text_color="${bg_pink}${bldwht}"
  export title_border_color="${bg_pink}${bldred}"
  export title_shadow_color="${fg_dark_red}"
  title-panel "$@"
}

function box-purple() {
  panel-purple-red "$@"
}

function panel-info() {
  export title_title_color="${bldwht}${bg_sky_blue}"
  export title_text_color="${bldylw}${bg_sky_blue}"
  export title_border_color="${bg_sky_blue}"
  export title_shadow_color="${fg_deep_blue}"
  title-panel "$@"
}

function box-info() {
  panel-info "$@"
}

function panel-info-dark() {
  export title_text_color="${txtblk}${bakcyn}"
  export title_border_color="${txtblk}${bakcyn}"
  export title_shadow_color="${txtblu}"
  title-panel "$@"
}

function title-box() {
  local len
  local len_actual
  local width
  local diff
  width=82
  printf "${clr}\n
 ${title_border_color} ┌─────────────────────────────────────────────────────────────────────────────────────┐ ${clr}\n"
  for line in "$@"; do
    len=$(ruby -e "puts '${line}'.size")
    len_actual=$(echo "${line}" | wc -c | tr -d ' ')
    diff=$(( width - len ))
    # echo "len=${len}, len_actual=${len_actual}, diff=${diff}"
    printf " ${bold}${title_border_color} │  ${title_text_color}%${len_actual}.${len_actual}s${title_border_color}%${diff}.${diff}s${clr}${title_border_color}│ ${clr}${title_shadow_color}██${clr}\n" "${line}" " "
  done
  printf " ${title_border_color} └─────────────────────────────────────────────────────────────────────────────────────┘ ${clr}${title_shadow_color}██${clr}
    ${title_shadow_color}████████████████████████████████████████████████████████████████████████████████████████${clr}
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
  export title_text_color="${txtwht}${bakred}"
  export title_border_color="${bldwht}${bakred}"
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
  divider__ "$@"
  printf "${clr}\n"
}

function divider__() {
  local color="${1:-${fg_bright_green}}"
  printf "${color}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${clr}"
}

function divider.yellow() {
  printf "${clr}\n${txtylw}"
  divider__ "${txtylw}${bakylw}"
  printf "${clr}${txtylw}${clr}\n"
}

