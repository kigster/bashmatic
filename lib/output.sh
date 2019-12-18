#!/usr/bin/env bash
# Private functions

export LibOutput__CommandPrefixLen=7
export LibOutput__LeftPrefix="       "

__lib::output::cursor-right-by()  {
  lib::output::is_terminal && printf "\e[${1}C"
}

__lib::output::cursor-left-by()  {
  lib::output::is_terminal && printf "\e[${1}D"
}

__lib::output::cursor-up-by()  {
  lib::output::is_terminal && printf "\e[${1}A"
}

__lib::output::cursor-down-by()  {
  lib::output::is_terminal && printf "\e[${1}B"
}

__lib::output::cursor-move-to-y() {
  lib::output::is_terminal || return
  __lib::output::cursor-up-by 1000
  __lib::output::cursor-down-by ${1:-0}
}

__lib::output::cursor-move-to-x() {
  lib::output::is_terminal || return
  __lib::output::cursor-left-by 1000
  __lib::output::cursor-right-by ${1:-0}
}

cursor.rewind() {
  local x=${1:-0}
  __lib::output::cursor-move-to-x ${x}
}

cursor.left() {
  __lib::output::cursor-left-by "$@"
}

cursor.up() {
  __lib::output::cursor-up-by "$@"
}

cursor.down() {
  __lib::output::cursor-down-by "$@"
}

cursor.right() {
  __lib::output::cursor-right-by "$@"
}


__lib::ver-to-i() {
  version=${1}
  echo ${version} | awk 'BEGIN{FS="."}{ printf "1%02d%03.3d%03.3d", $1, $2, $3}'
}

lib::output::color::on() {
  printf "${bldred}" >&2
  printf "${bldblu}" >&1
}

lib::output::color::off() {
  reset-color: >&2
  reset-color: >&1
}

__lib::output::screen-width() {
  if [[ -n "${AppCurrentScreenWidth}" && $(( $(millis) - ${AppCurrentScreenMillis} )) -lt 20000 ]]; then
    printf -- "${AppCurrentScreenWidth}"
    return
  fi

  if [[ ${AppCurrentOS:-$(uname -s)} == 'Darwin' ]]; then
    w=$(stty -a 2>/dev/null | grep columns | awk '{print $6}')
  elif [[ ${AppCurrentOS} == 'Linux' ]]; then
    w=$(stty -a 2>/dev/null | grep columns | awk '{print $7}' | hbsed 's/;//g')
  fi

  MIN_WIDTH=${MIN_WIDTH:-50}
  w=${w:-${MIN_WIDTH}}
  [[ "${w}" -lt "${MIN_WIDTH}" ]] && w=${MIN_WIDTH}

  export AppCurrentScreenWidth=${w}
  export AppCurrentScreenMillis=$(millis)

  printf -- "${w}"
}

__lib::output::screen-height() {
  if [[ ${AppCurrentOS:-$(uname -s)} == 'Darwin' ]]; then
    h=$(stty -a 2>/dev/null | grep rows | awk '{print $4}')
  elif [[ ${AppCurrentOS} == 'Linux' ]]; then
    h=$(stty -a 2>/dev/null | grep rows | awk '{print $5}' | hbsed 's/;//g')
  fi

  MIN_HEIGHT=${MIN_HEIGHT:-30}
  h=${h:-${MIN_HEIGHT}}
  [[ "${h}" -lt "${MIN_HEIGHT}" ]] && h=${MIN_HEIGHT}
  printf -- $(( $h - 2 ))
}

__lib::output::line() {
  __lib::output::repeat-char "─" $(( $(__lib::output::screen-width) - 2 ))
}

__lib::output::hr()  {
  local cols=${1:-$(__lib::output::screen-width)}
  local char=${2:-"—"}
  local color=${3:-${txtylw}}

  printf "${color}"
  __lib::output::repeat-char "─"
  reset-color
}

__lib::output::replicate-to() {
  local char="$1"
  local len="$2"

  __lib::output::repeat-char "${char}" "${len}"
}

__lib::output::sep() {
  __lib::output::hr
  printf "\n"
}

__lib::output::repeat-char() {
  local char="${1}"
  local width=${2}
  [[ -z "${width}" ]] && width=$(__lib::output::screen-width)
  local line=""
  for i in {1..300}; do
    [[ $i -gt ${width} ]] && {
      printf -- "${line}"
      return
    }
    line="${line}${char}"
  done
  printf -- "${line}"
}

# set background color to something before calling this
__lib::output::bar() {
  __lib::output::repeat-char " "
  reset-color
}

__lib::output::box-separator() {
  printf "├"
  __lib::output::line
  __lib::output::cursor-left-by 1
  printf "┤${clr}\n"
}

__lib::output::box-top() {
  printf "┌"
  __lib::output::line
  __lib::output::cursor-left-by 1
  printf "┐${clr}\n"
}

__lib::output::box-bottom() {
  printf "└"
  __lib::output::line
  __lib::output::cursor-left-by 1
  printf "┘${clr}\n"
}

__lib::output::which-ruby() {
  if [[ -n $(which rbenv) && -n $(rbenv which ruby) ]]; then
    rbenv which ruby
  elif [[ -x /usr/bin/ruby ]]; then
    printf /usr/bin/ruby
  elif [[ -x /usr/local/bin/ruby ]] ; then
    printf /usr/local/bin/ruby
  else
    which ruby
  fi
}

__lib::output::clean() {
  local text="$*"
  $(__lib::output::which-ruby) -e "input=\"${text}\"; " -e 'puts input.gsub(/\e\[[;m\d]+/, "")'
}

__lib::output::boxed-text() {
  local border_color=${1}
  shift
  local text_color=${1}
  shift
  local text="$*"

  lib::output::is_terminal || {
    printf ">>> %80.80s <<< \n" ${text}
    return
  }

  local clean_text=$(__lib::output::clean "${text}")
  local width=$(( $(__lib::output::screen-width) - 2 ))
  local remaining_space_len=$(($width - ${#clean_text} - 1))
  printf "${border_color}│ ${text_color}"
  printf -- "${text}"
  [[ ${remaining_space_len} -gt 0 ]] && __lib::output::repeat-char " " "${remaining_space_len}"
  __lib::output::cursor-left-by 1
  printf "${border_color}│${clr}\n"
}

#
# Usage: __lib::output::box border-color text-color "line 1" "line 2" ....
#
__lib::output::box() {

  save-set-x
  set +x

  local border_color=${1}
  shift
  local text_color=${1}
  shift
  local line

  lib::output::is_terminal || {
    for line in "$@"; do
      printf ">>> %80.80s <<< \n" ${line}
    done
    return
  }

  [[ -n "${opts_suppress_headers}" ]] && return

  printf "\n${border_color}"
  __lib::output::box-top

  local __i=0
  for line in "$@"; do
    [[ $__i == 1 ]] && {
      printf "${border_color}"
      __lib::output::box-separator
    }
    __lib::output::boxed-text "${border_color}" "${text_color}" "${line}"
    __i=$(( $__i + 1 ))
  done

  printf "${border_color}"
  __lib::output::box-bottom
  reset-color:
  restore-set-x
}

__lib::output::center() {
  local color="${1}"
  shift
  local text="$*"

  local clean_text=$(__lib::output::clean "${text}")
  local width=$(( $(__lib::output::screen-width) - 2 ))
  local remaining_space_len=$(( 1 + ($width - ${#clean_text}) / 2 ))

  local offset=0
  [[ $(( ( ${width} - ${#clean_text} ) % 2 )) == 1 ]] && offset=1

  printf "${color}"
  cursor.at.x 0
  __lib::output::repeat-char " " ${remaining_space_len}
  printf "%s" "${text}"
  __lib::output::repeat-char " " $(( ${remaining_space_len} + ${offset} - 1 ))
  reset-color
  cursor.at.x 0
}

__lib::output::left-justify() {
  local color="${1}"
  shift
  local text="$*"
  echo
  printf "${color}"
  ( lib::output::is_terminal ) && {
    local width=$(( 2 * $(__lib::output::screen-width) / 3 ))
    [[ ${width} -lt 70 ]] && width="70"
    printf -- "  %-${width}.${width}s${clr}\n\n" "« ${text} »"
  }

  ( lib::output::is_terminal ) || {
    printf -- "  « ${text} »"
    printf -- "  ${clr}\n\n"
  }
}

################################################################################
# Public functions
################################################################################

# Prints text centered on the screen
# Usage: center "colors/prefix" "text"
#    eg: center "${bakred}${txtwht}" "Welcome Friends!"
center() {
  __lib::output::center "$@"
}

left() {
  __lib::output::left-justify "$@"
}

cursor.at.x() {
  __lib::output::cursor-move-to-x "$@"
}

cursor.at.y() {
  __lib::output::cursor-move-to-y "$@"
}

screen.width() {
  __lib::output::screen-width
}

screen.height() {
  __lib::output::screen-height
}

lib::output::is_terminal() {
  lib::output::is_tty || lib::output::is_redirect || lib::output::is_pipe
}

lib::output::is_ssh() {
  [[ -n "${SSH_CLIENT}" || -n "${SSH_CONNECTION}" ]]
}

lib::output::is_tty() {
  [[ -t 1 ]]
}

lib::output::is_pipe() {
  [[ -p /dev/stdout ]]
}

lib::output::is_redirect() {
  [[ ! -t 1 && ! -p /dev/stdout ]]
}

box::yellow-in-red() {
  __lib::output::box "${bldred}" "${bldylw}" "$@"
}

box::yellow-in-yellow() {
  __lib::output::box "${bldylw}" "${txtylw}" "$@"
}

box::blue-in-yellow() {
  __lib::output::box "${bldylw}" "${bldblu}" "$@"
}

box::blue-in-green() {
  __lib::output::box "${bldblu}" "${bldgrn}" "$@"
}

box::yellow-in-blue() {
  __lib::output::box "${bldylw}" "${bldblu}" "$@"
}

box::red-in-yellow() {
  __lib::output::box "${bldred}" "${bldylw}" "$@"
}

box::red-in-red() {
  __lib::output::box "${bldred}" "${txtred}" "$@"
}

box::green-in-magenta() {
  __lib::output::box "${bldgrn}" "${bldpur}" "$@"
}

box::red-in-magenta() {
  __lib::output::box "${bldred}" "${bldpur}" "$@"
}

box::green-in-green() {
  __lib::output::box "${bldgrn}" "${bldgrn}" "$@"
}

box::green-in-yellow(){
  __lib::output::box "${bldgrn}" "${bldylw}" "$@"
}

box::green-in-cyan(){
  __lib::output::box "${bldgrn}" "${bldcyn}" "$@"
}

box::magenta-in-green() {
  __lib::output::box "${bldpur}" "${bldgrn}" "$@"
}

box::magenta-in-blue() {
  __lib::output::box "${bldblu}" "${bldpur}" "$@"
}

hl::white-on-orange() {
  left "${white_on_orange}" "$@"
}

hl::white-on-salmon() {
  left "${white_on_salmon}" "$@"
}

hl::orange() {
  left "${white_on_orange}" "$@"
}

hl::yellow-on-gray() {
  left "${yellow_on_gray}" "$@s"
}

hl::yellow-on-gray() {
  left "${yellow_on_gray}" "$@s"
}

hl::blue() {
  left "${bldwht}${bakpur}" "$@"
}

hl::green() {
  left "${txtblk}${bakgrn}" "$@"
}

hl::yellow() {
  left "${bakylw}${txtblk}" "$@"
}

hl::subtle() {
  left "${bldwht}${bakblk}${underlined}" "$@"
}

hl::desc() {
  left "${bakylw}${txtblk}${bakylw}" "$@"
}

h::yellow() {
  center "${txtblk}${bakylw}" "$@"
}

h::red() {
  center "${txtblk}${bakred}" "$@"
}

h::green() {
  center "${txtblk}${bakgrn}" "$@"
}

h::blue() {
  center "${txtblk}${bakblu}" "$@"
}

h::black() {
  center "${bldylw}${bakblk}" "$@"
}

h2::green() {
  box::green-in-cyan "$@"
}

h1::green() {
  box::green-in-magenta "$@"
}

h1::purple() {
  box::magenta-in-green "$@"
}

h1::blue() {
  box::magenta-in-blue "$@"
}

h1::red() {
  box::red-in-red "$@"
}

h1::yellow() {
  box::yellow-in-red "$@"
}

h1() {
  box::blue-in-yellow "$@"
}

h2() {
  box::blue-in-green "$@"
}

h3() {
  hl::subtle "$@"
}

hdr() {
  h1 "$@"
}

screen-width() {
  __lib::output::screen-width
}

hr::colored() {
  local color="$*"
  [[ -z ${color} ]] && color="${bldred}"
  __lib::output::hr "$(screen-width)" "—" "${*}"
}

function hr() {
  [[ -z "$*" ]] || printf $*
  __lib::output::hr
}

stdout() {
  local file=$1
  hl::subtle STDOUT
  printf "${clr}"
  [[ -s ${file} ]] && cat ${file}
  reset-color
}

stderr() {
  local file=$1
  hl::subtle STDERR
  printf "${txtred}"
  [[ -s ${file} ]] && cat ${file}
  reset-color
}

command-spacer() {
  [[  -z ${LibRun__AssignedWidth} || -z ${LibRun__CommandLength} ]] && return
  printf " ${bldblk}"
  # shellcheck disable=SC2154
  local w
  w=$(( LibRun__AssignedWidth - LibRun__CommandLength - 10))
  # shellcheck disable=SC2154
  [[ ${w} -gt 0 ]] && __lib::output::replicate-to "⎯" "${w}"
}

duration() {
  local millis="$1"
  local exit_code="$2"
  [[ -n $(which bc) ]] || return
  if [[ -n ${millis} && ${millis} -ge 0 ]] ; then
    local pattern
    pattern="%6.6s ms"
    pattern="${txtblu}〔${txtpur}${pattern}${txtblu}〕"
    printf "${txtblu}${pattern}" "${millis}"
  fi

  if [[ -n ${exit_code} ]]; then
    [[ ${exit_code} -eq 0 ]] && printf " ${txtblk}${bakgrn} %3d ${clr}" ${exit_code}
    [[ ${exit_code} -gt 0 ]] && printf " ${bldwht}${bakred} %3d ${clr}" ${exit_code}
  fi
}

ok() {
  __lib::output::cursor-left-by 1000
  printf " ${txtblk}${bakgrn} ✔︎ ${clr} "
}

not_ok() {
  __lib::output::cursor-left-by 1000
  printf " ${bakred}${bldwht} ✘ ${clr} "
}

kind_of_ok() {
  __lib::output::cursor-left-by 1000
  printf " ${bakylw}${bldwht} ❖ ${clr} "
}

left-prefix() {
  [[ -z ${LibOutput__LeftPrefix} ]] && {
     export LibOutput__LeftPrefix=$(__lib::output::replicate-to " " "${LibOutput__LeftPrefixLen}")
  }
  printf "${LibOutput__LeftPrefix}"
}


ok:() {
  ok $@
  echo
}

not_ok:() {
  not_ok $@
  echo
}

kind_of_ok:() {
  kind_of_ok $@
  echo
}

puts() {
  printf "  ⇨ ${txtwht}$*${clr}"
}

okay() {
  printf -- " ${bldgrn} ✓ ALL OK 👍  $*${clr}" >&2
  echo
}

success() {
  echo
  printf -- "${LibOutput__LeftPrefix}${txtblk}${bakgrn}  « SUCCESS »  ${clr} ${bldwht} ✔  ${bldgrn}$*${clr}" >&2
  echo
  echo
}

abort() {
  printf -- "${LibOutput__LeftPrefix}${txtblk}${bakred}  « ABORT »  ${clr} ${bldwht} ✔  ${bldgrn}$*${clr}" >&2
  echo
}

err() {
  printf -- "${LibOutput__LeftPrefix}${bldylw}${bakred}  « ERROR! »  ${clr} ${bldred}$*${clr}" >&2
}

inf() {
  printf -- "${LibOutput__LeftPrefix}${txtblu}${clr}${txtblu}$*${clr}"
}

debug() {
  [[ -z ${DEBUG} ]] && return
  printf -- "${LibOutput__LeftPrefix}${txtblk}${bakwht}[ debug ] $*  ${clr}\n"
}

warn() {
  printf -- "${LibOutput__LeftPrefix}${bldwht}${bakylw} « WARNING! » ${clr} ${bldylw}$*${clr}" >&2
}

warning() {
  header=$(printf -- "${txtblk}${bakylw} « WARNING » ${clr}")
  box::yellow-in-yellow "${header} ${bldylw}$*" >&2
}

br() {
  echo
}

info() {
  inf $@
  echo
}

error() {
  header=$(printf -- "${txtblk}${bakred} « ERROR » ${clr}")
  box::red-in-red "${header} ${bldylw}$@" >&2
}

info:() {
  inf $*
  ok:
}

error:() {
  err $*
  not_ok:
}

warning:() {
  warn $*
  kind_of_ok:
}

shutdown() {
  local message=${1:-"Shutting down..."}
  echo
  box::red-in-red "${message}"
  echo
  exit 1
}

reset-color() {
  printf "${clr}\n"
}

reset-color:() {
  printf "${clr}"
}

ascii-clean() {
  __lib::output::clean "$@"
}
