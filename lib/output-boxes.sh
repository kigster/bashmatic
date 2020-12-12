#!/usr/bin/env bash
# Private functions
# shellcheck disable=SC2155

#————————————————————
# Sections
#————————————————————

section.green() {
  .output.left-powerline grn "$@"
}

section.yellow() {
  .output.left-powerline ylw "$@"
}

section.red() {
  .output.left-powerline red "$@"
}

section.blue() {
  .output.left-powerline blu "$@"
}

section.purple() {
  .output.left-powerline pur "$@"
}

section.cyan() {
  .output.left-powerline cyn "$@"
}

section.white() {
  .output.left-powerline wht "$@"
}

section.gray() {
  .output.left-powerline blk "$@"
}

section.gray-yellow() {
  section.gray "${bldylw}${bakblk}$*"
}

section.salmon() {
  .output.left-powerline wht 65 "${white_on_salmon}  $@  "
}

notice() {
  .output.left-powerline ylw 65 "${itablk}${bakylw}$@"
}

attention() {
  .output.left-powerline blu 65 "${txtwht}${bakblu}$@"
}

#————————————————————
# Boxes
#————————————————————


box.white-on-blue() {
  .output.box "${bakblu}" "${bldwht}" "$@"
}

box.white-on-green() {
  .output.box "${bakgrn}" "${bldwht}" "$@"
}

box.yellow-on-purple() {
  .output.box "${bakpur}" "${bldylw}" "$@"
}

box.yellow-in-red() {
  .output.box "${bldred}" "${bldylw}" "$@"
}

box.yellow-in-yellow() {
  .output.box "${bldylw}" "${txtylw}" "$@"
}

box.blue-in-yellow() {
  .output.box "${bldylw}" "${bldblu}" "$@"
}

box.blue-in-green() {
  .output.box "${bldblu}" "${bldgrn}" "$@"
}

box.yellow-in-blue() {
  .output.box "${bldylw}" "${bldblu}" "$@"
}

box.red-in-yellow() {
  .output.box "${bldred}" "${bldylw}" "$@"
}

box.red-in-red() {
  .output.box "${txtred}" "${txtred}" "$@"
}

box.green-in-magenta() {
  .output.box "${bldgrn}" "${bldpur}" "$@"
}

box.red-in-magenta() {
  .output.box "${bldred}" "${bldpur}" "$@"
}

box.green-in-green() {
  .output.box "${bldgrn}" "${bldgrn}" "$@"
}

box.green-in-yellow() {
  .output.box "${bldgrn}" "${bldylw}" "$@"
}

box.green-in-cyan() {
  .output.box "${bldgrn}" "${bldcyn}" "$@"
}

box.magenta-in-green() {
  .output.box "${bldpur}" "${bldgrn}" "$@"
}

box.magenta-in-blue() {
  .output.box "${bldblu}" "${bldpur}" "$@"
}

#————————————————————
# Backgrounds
#————————————————————

box.yellow-on-green() {
  .output.box "${bakgrn}${bldwht}" "${bakgrn}${bldylw}" "$@"
}

box.white-on-red() {
  .output.box "${bakred}${bldwht}" "${bakred}${bldwht}" "$@"
}

box.white-on-green() {
  .output.box "${bakgrn}${bldwht}" "${bakgrn}${bldwht}" "$@"
}

box.white-on-blue() {
  .output.box "${bakblu}${bldwht}" "${bakblu}${bldwht}" "$@"
}

box.black-on-yellow() {
  .output.box "${txtblk}${bakylw}" "${txtblk}${bakylw}" "$@"
}

box.black-on-red() {
  .output.box "${txtblk}${bakred}" "${bakred}" "$@"
}

box.black-on-green() {
  .output.box "${txtblk}${bakgrn}" "${bakgrn}" "$@"
}

box.black-on-blue() {
  .output.box "${txtblk}${bakblu}" "${bakblu}" "$@"
}

box.black-on-purple() {
  .output.box "${txtblk}${bakpur}" "${bakpur}" "$@"
}

h.e() {
  .output.box "${bakred}${txtblk}" "${bakred}" "$@"
}

#————————————————————
# Centered
#————————————————————
h.orange-center() {
  center "${white_on_orange}" "$@"
}

h.orange() {
  left "${white_on_orange}" "$@"
}

h.salmon-center() {
  center "${white_on_salmon}" "$@"
}

h.salmon() {
  left "${white_on_salmon}" "$@"
}

hl.yellow-on-black() {
  left "${yellow_on_black}" "$@"
}

hl.yellow-on-gray() {
  left "${yellow_on_gray}" "$@"
}

hl.blue() {
  left "${bldwht}${bakpur}" "$@"
}

hl.green() {
  left "${txtblk}${bakgrn}" "$@"
}

hl.yellow() {
  left "${txtblk}${bakylw}" "$@"
}

hl.subtle() {
  left "${bldwht}${bakblk}${underlined}" "$@"
}

hl.desc() {
  left "${bakylw}${txtblk}${bakylw}" "$@"
}

h.yellow() {
  center "${txtblk}${bakylw}" "$@"
}

h.red() {
  center "${txtblk}${bakred}" "$@"
}

h.green() {
  center "${txtblk}${bakgrn}" "$@"
}

h.blue() {
  center "${txtblk}${bakblu}" "$@"
}

h.black() {
  center "${bldylw}${bakblk}" "$@"
}

h2.green() {
  box.green-in-cyan "$@"
}

h1.green() {
  box.green-in-magenta "$@"
}

h1.purple() {
  box.magenta-in-green "$@"
}

h1.blue() {
  box.magenta-in-blue "$@"
}

h1.red() {
  box.red-in-red "$@"
}

h1.yellow() {
  box.yellow-in-red "$@"
}

h1() {
  box.blue-in-yellow "$@"
}

h1bg() {
  box.white-on-blue "$@"
}

h2() {
  box.blue-in-green "$@"
}

h2bg() {
  box.white-on-green "$@"
}

h3() {
  box.magenta-in-green "$@"
}

h3bg() {
  box.yellow-on-purple "$@"
}

h4() {
  section.blue "$@"
}

h5() {
  section.purple "$@"
}

h6() {
  section.yellow "$@"
}

h7() {
  section.salmon "$@"
}

h8() {
  section.cyan "$@"
}

hdr() {
  h1 "$@"
}
