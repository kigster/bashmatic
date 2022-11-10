#!/usr/bin/env bash
# Private functions
# shellcheck disable=SC2155

#————————————————————
# Sections
#————————————————————

status.ok() {
   cursor.right 5; section.cyan "       $*" ; cursor.up 2;  ok:; cursor.down 2;
}

status.failed() {
   cursor.right 5; section.red "       $*" ; cursor.up 2;  not-ok:; cursor.down 2;
}

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
  .output.left-powerline wht 65 "${txtwht}${white_on_salmon}  $*  "
}

notice() {
  .output.left-powerline ylw 65 "${itablk}${bakylw} $*  "
}

attention() {
  .output.left-powerline blu 65 "${txtwht}${bakblu}  $*  "
}

# ———————————————————
# Left Aligned Arrows
#                    

arrow-right() {
  .output.left-as-is "$@"
}

arrow.blk-on-ylw() { arrow-right "${bakylw}" "${txtblk}" "$@"; }
arrow.blk-on-grn() { arrow-right "${bakgrn}" "${txtblk}" "$@"; }
arrow.blk-on-wht() { arrow-right "${bakwht}" "${txtblk}" "$@"; }
arrow.blk-on-blu() { arrow-right "${bakblu}" "${txtblk}" "$@"; }
arrow.blk-on-cyn() { arrow-right "${bakcyn}" "${txtblk}" "$@"; }
arrow.blk-on-pur() { arrow-right "${bakpur}" "${txtblk}" "$@"; }
arrow.blk-on-red() { arrow-right "${bakred}" "${txtblk}" "$@"; }

arrow.wht-on-ylw() { arrow-right "${bakylw}" "${txtwht}" "$@"; }
arrow.wht-on-grn() { arrow-right "${bakgrn}" "${txtwht}" "$@"; }
arrow.wht-on-blk() { arrow-right "${bakblk}" "${txtwht}" "$@"; }
arrow.wht-on-blu() { arrow-right "${bakblu}" "${txtwht}" "$@"; }
arrow.wht-on-cyn() { arrow-right "${bakcyn}" "${txtwht}" "$@"; }
arrow.wht-on-pur() { arrow-right "${bakpur}" "${txtwht}" "$@"; }
arrow.wht-on-red() { arrow-right "${bakred}" "${txtwht}" "$@"; }


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

h.salmon-center() { 
  center "${white_on_salmon}" "$@"
}

h.yellow-center-black() {
  center "${black_on_yellow}" "$@"
}

h.salmon-center-black() {
  center "${black_on_salmon}" "$@"
}

# ———————————————————
# LEFT aligned       
# ———————————————————
h.orange() {
  left "${white_on_orange}" "$@"
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

h2() {
  box.blue-in-green "$@"
}

h3() {
  box.magenta-in-green "$@"
}

h4() {
  section.blue "$@"
}

h5() {
  section.green "$@"
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

# 
# Boxes with filled backgrounds of various colors

h1bg() {
  box.white-on-blue "$@"
}

h2bg() {
  box.black-on-green "$@"
}

h3bg() {
  box.black-on-yellow "$@"
}

h4bg() {
  box.white-on-blue "$@"
}

h5bg() {
  box.yellow-on-green "$@"
}

# Aliases to the above
h1.blue()   { h1bg "${@}"; }
h2.green()  { h2bg "${@}"; }
h3.yellow() { h3bg "${@}"; }
h4.red()    { h4bg "${@}"; }
hdr() {
  h1 "$@"
}


