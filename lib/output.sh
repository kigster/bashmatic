#/usr/bin/env bash
# Private functions

export LibOutput__CommandPrefixLen=7
export LibOutput__LeftPrefix="       "

export LibOutput__MinWidth__Default=80
export LibOutput__MaxWidth__Default=

output.reset-min-max-width() {
  export LibOutput__MinWidth=${LibOutput__MinWidth__Default}
  export LibOutput__MaxWidth=${LibOutput__MaxWidth__Default}
}

output.set-max-width() {
  export LibOutput__MaxWidth="$1"
}

output.set-min-width() {
  export LibOutput__MinWidth="$1"
}

.output.cursor-right-by() {
  output.is-terminal && printf "\e[${1}C"
}

.output.cursor-left-by() {
  output.is-terminal && printf "\e[${1}D"
}

.output.cursor-up-by() {
  output.is-terminal && printf "\e[${1}A"
}

.output.cursor-down-by() {
  output.is-terminal && printf "\e[${1}B"
}

.output.cursor-move-to-y() {
  output.is-terminal || return
  .output.cursor-up-by 1000
  .output.cursor-down-by ${1:-0}
}

.output.cursor-move-to-x() {
  output.is-terminal || return
  .output.cursor-left-by 1000
  [[ -n $1 && "$1" -ne 0 ]] && .output.cursor-right-by ${1}
}

cursor.rewind() {
  local x=${1:-0}
  .output.cursor-move-to-x ${x}
}

cursor.left() {
  .output.cursor-left-by "$@"
}

cursor.up() {
  .output.cursor-up-by "$@"
}

cursor.down() {
  .output.cursor-down-by "$@"
}

cursor.right() {
  .output.cursor-right-by "$@"
}

output.print-at-x-y() {
  local x=$1
  shift
  local y=$1
  shift

  .output.cursor-move-to-x "${x}"
  cursor.up "${y}"
  printf "%s" "$*"
  cursor.down "${y}"
  .output.cursor-move-to-x 0
}

.ver-to-i() {
  version=${1}
  echo ${version} | awk 'BEGIN{FS="."}{ printf "1%02d%03.3d%03.3d", $1, $2, $3}'
}

output.color.on() {
  printf "${bldred}" >&2
  printf "${bldblu}" >&1
}

output.color.off() {
  reset-color: >&2
  reset-color: >&1
}

.output.current-screen-width() {
  local w
  local os=$(uname -s)

  if [[ $os == 'Darwin' ]]; then
    w=$(stty -a 2>/dev/null | grep columns | awk '{print $6}')
  elif [[ $os == 'Linux' ]]; then
    w=$(stty -a 2>/dev/null | grep columns | awk '{print $7}' | sedx 's/;//g')
  fi

  [[ -z ${w} ]] && w=${LibOutput__MinWidth}
  [[ ${w} -lt ${LibOutput__MinWidth} ]] && w=${LibOutput__MinWidth}

  if [[ -n ${LibOutput__MaxWidth} ]]; then
    if [[ ${w} -gt ${LibOutput__MaxWidth} ]]; then
      w=${LibOutput__MaxWidth}
    fi
  fi

  printf -- "%d" $w
}

.output.screen-width() {
  if [[ -n ${CI} ]]; then
    printf -- "120"
    return 0
  fi

  if [[ -n "${AppCurrentScreenWidth}" && $(($(millis) - ${AppCurrentScreenMillis})) -lt 1000 ]]; then
    printf -- "${AppCurrentScreenWidth}"
    return
  fi

  local w=$(.output.current-screen-width)

  export AppCurrentScreenWidth=${w}
  export AppCurrentScreenMillis=$(millis)

  printf -- "%d" ${w}
}

.output.screen-height() {
  if [[ ${AppCurrentOS:-$(uname -s)} == 'Darwin' ]]; then
    h=$(stty -a 2>/dev/null | grep rows | awk '{print $4}')
  elif [[ ${AppCurrentOS} == 'Linux' ]]; then
    h=$(stty -a 2>/dev/null | grep rows | awk '{print $5}' | sedx 's/;//g')
  fi

  MIN_HEIGHT=${MIN_HEIGHT:-30}
  h=${h:-${MIN_HEIGHT}}
  [[ "${h}" -lt "${MIN_HEIGHT}" ]] && h=${MIN_HEIGHT}
  printf -- $(($h - 2))
}

.output.line() {
  .output.repeat-char "─" $(($(.output.screen-width) - 2))
}

.output.hr() {
  local cols=${1:-$(.output.screen-width)}
  local char=${2:-"—"}
  local color=${3:-${txtylw}}

  printf "${color}"
  .output.repeat-char "─"
  reset-color
}

.output.replicate-to() {
  local char="$1"
  local len="$2"

  .output.repeat-char "${char}" "${len}"
}

.output.sep() {
  .output.hr
  printf "\n"
}

.output.repeat-char() {
  local char="${1}"
  local width=${2}
  [[ -z "${width}" ]] && width=$(.output.screen-width)
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
.output.bar() {
  .output.repeat-char " "
  reset-color
}

.output.box-separator() {
  printf "$1"
  printf "├"
  .output.line
  .output.cursor-left-by 1
  printf "┤${clr}\n"
}

.output.box-top() {
  printf "$1┌"
  .output.line
  .output.cursor-left-by 1
  printf "┐${clr}\n"
}

.output.box-bottom() {
  printf "└"
  .output.line
  .output.cursor-left-by 1
  printf "┘${clr}\n"
}

.output.which-ruby() {
  if [[ -n $(which rbenv) && -n $(rbenv which ruby) ]]; then
    rbenv which ruby
  elif [[ -x /usr/bin/ruby ]]; then
    printf /usr/bin/ruby
  elif [[ -x /usr/local/bin/ruby ]]; then
    printf /usr/local/bin/ruby
  else
    which ruby
  fi
}

.output.clean() {
  local text="$*"
  $(.output.which-ruby) -e "input=\"${text}\"; " -e 'puts input.gsub(/\e\[[;m\d]+/, "")'
}

.output.boxed-text() {
  local __color_bdr=${1}
  shift
  local __color_fg=${1}
  shift
  local text="$*"

  output.is-terminal || {
    printf ">>> %80.80s <<< \n" ${text}
    return
  }

  local clean_text=$(.output.clean "${text}")
  local width=$(($(.output.screen-width) - 2))
  local remaining_space_len=$(($width - ${#clean_text} - 1))
  printf "${__color_bdr}│ ${__color_fg}"
  printf -- "${text}"
  [[ ${remaining_space_len} -gt 0 ]] && {
    cursor.shift.x $((remaining_space_len - 1))
  }
  printf "${__color_bdr}│${clr}\n"
}

#
# Usage: .output.box border-color text-color "line 1" "line 2" ....
#
.output.box() {
  local __color_bdr=${1}
  shift
  local __color_fg=${1}
  shift
  local line

  output.is-terminal || {
    for line in "$@"; do
      printf ">>> %80.80s <<< \n" ${line}
    done
    return
  }

  [[ -n "${opts_suppress_headers}" ]] && return

  printf "${__color_bdr}"
  .output.box-top

  local __i=0
  for line in "$@"; do
    [[ $__i == 1 ]] && {
      printf "${__color_bdr}"
      .output.box-separator
    }
    .output.boxed-text "${__color_bdr}" "${__color_fg}" "${line}"
    __i=$(($__i + 1))
  done

  printf "${__color_bdr}"
  .output.box-bottom
}

.output.center() {
  local color="${1}"
  shift
  local text="$*"

  local clean_text=$(.output.clean "${text}")
  local width=$(($(.output.screen-width) - 4))
  local remaining_space_len=$((1 + ($width - ${#clean_text}) / 2))

  local offset=0
  [[ $(((${width} - ${#clean_text}) % 2)) == 1 ]] && offset=1

  printf "${color}"
  cursor.at.x 1
  .output.repeat-char " " ${remaining_space_len}
  printf "%s" "${text}"
  .output.repeat-char " " $((remaining_space_len + offset - 1))
  reset-color
  cursor.at.x 0
  echo
}

.output.left-justify() {
  local color="${1}"
  shift
  local text="$*"
  echo
  printf " ${color}"
  if output.is-terminal; then
    local width=$(($(.output.screen-width) - 2))
    #local width=$((2 * $(.output.screen-width) / 3))
    [[ ${width} -lt 70 ]] && width="70"
    printf -- "  %-${width}.${width}s${clr}\n\n" "❯❯ ${text} ❯❯"
  else
    printf -- "  ❯❯ ${text} ❯❯ "
    printf -- "  ${clr}\n\n"
  fi
}

################################################################################
# Public functions
################################################################################

# Prints text centered on the screen
# Usage: center "colors/prefix" "text"
#    eg: center "${bakred}${txtwht}" "Welcome Friends!"
center() {
  .output.center "$@"
}

left() {
  .output.left-justify "$@"
}

cursor.at.x() {
  .output.cursor-move-to-x "$@"
}

cursor.at.y() {
  .output.cursor-move-to-y "$@"
}

cursor.shift.x() {
  local shift="$1"
  if [[ "${shift:0:1}" == "-" ]]; then
    .output.cursor-left-by "${shift:1}"
  else
    .output.cursor-right-by "${shift}"
  fi
}

screen.width() {
  .output.screen-width
}

screen.height() {
  .output.screen-height
}

output.is-terminal() {
  output.is-tty || output.is-redirect || output.is-pipe || output.is-ssh
}

output.is-ssh() {
  [[ -n "${SSH_CLIENT}" || -n "${SSH_CONNECTION}" ]]
}

output.is-tty() {
  [[ -t 1 ]]
}

output.is-pipe() {
  [[ -p /dev/stdout ]]
}

output.is-redirect() {
  [[ ! -t 1 && ! -p /dev/stdout ]]
}

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
  .output.box "${bldred}" "${txtred}" "$@"
}

h.e() {
  local header="$1"
  shift
  box.red-in-red "${bakred}${bldwht} ${bldylw}${header}" "$@" >&2
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

test-group() {
  [[ -z ${white_on_salmon} ]] && hr
  h.salmon "$@"
}

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
  left "${bakylw}${txtblk}" "$@"
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
  box.magenta-in-green "$@"
}

hdr() {
  h1 "$@"
}

screen-width() {
  .output.screen-width
}

hr.colored() {
  local color="$*"
  [[ -z ${color} ]] && color="${bldred}"
  .output.hr "$(screen-width)" "—" "${*}"
}

hr() {
  [[ -z "$*" ]] || printf "$*"
  .output.hr
}

stdout() {
  local file=$1
  hl.subtle STDOUT
  printf "${clr}"
  [[ -s ${file} ]] && cat ${file}
  reset-color
}

stderr() {
  local file=$1
  hl.subtle STDERR
  printf "${txtred}"
  [[ -s ${file} ]] && cat ${file}
  reset-color
}

command-spacer() {
  local color="${txtgrn}"
  [[ ${LibRun__LastExitCode} -ne 0 ]] && color="${txtred}"

  [[ -z ${LibRun__AssignedWidth} || -z ${LibRun__CommandLength} ]] && return

  printf "%s${color}" ""

  # shellcheck disable=SC2154
  local __width=$((LibRun__AssignedWidth - LibRun__CommandLength - 10))
  # shellcheck disable=SC2154

  [[ ${__width} -gt 0 ]] && .output.replicate-to "▪" "${__width}"
}

duration() {
  local millis="$1"
  local exit_code="$2"
  [[ -n $(which bc) ]] || return
  if [[ -n ${millis} && ${millis} -ge 0 ]]; then
    local pattern
    pattern=" %6.6s ms "
    pattern="${txtblu}〔${pattern}〕"
    printf "${txtblu}${pattern}" "${millis}"
  fi

  if [[ -n ${exit_code} ]]; then
    [[ ${exit_code} -eq 0 ]] && printf " ${txtblk}${bakgrn} %3d ${clr}" ${exit_code}
    [[ ${exit_code} -gt 0 ]] && printf " ${bldwht}${bakred} %3d ${clr}" ${exit_code}
  fi
}

left-prefix() {
  [[ -z ${LibOutput__LeftPrefix} ]] && {
    export LibOutput__LeftPrefix=$(.output.replicate-to " " "${LibOutput__LeftPrefixLen}")
  }
  printf "${LibOutput__LeftPrefix}"
}

#—————————————————————————————————————————————————————————————————
# Closers for open-ended statements like `inf`, `warn`, `debug`, `err`
#—————————————————————————————————————————————————————————————————
ui.closer.ok() {
  .output.cursor-left-by 1000
  printf " ${txtblk}${bakgrn} ✔︎ ${clr} "
}

ui.closer.ok:() {
  ui.closer.ok "$@"
  echo
}

ok() { ui.closer.ok "$@"; }
ok:() { ui.closer.ok: "$@"; }

ui.closer.not-ok() {
  .output.cursor-left-by 1000
  printf " ${bakred}${bldwht} ✘ ${clr} "
}

ui.closer.not-ok:() {
  ui.closer.not-ok $@
  echo
}

not-ok() { ui.closer.not-ok "$@"; }
not-ok:() { ui.closer.not-ok: "$@"; }

ui.closer.kind-of-ok() {
  .output.cursor-left-by 1000
  printf " ${bakylw}${bldwht} ❖ ${clr} "
}

ui.closer.kind-of-ok:() {
  ui.closer.kind-of-ok $@
  echo
}

#—————————————————————————————————————————————————————————————————

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

ask() {
  printf -- "%s${txtylw}$*${clr}\n" "${LibOutput__LeftPrefix}"
  printf -- "%s${txtylw}❯ ${bldwht}" "${LibOutput__LeftPrefix}"
}

inf() {
  printf -- "${LibOutput__LeftPrefix}${txtblu}${clr}${txtblu}$*${clr}"
}

debug() {
  [[ -z ${DEBUG} ]] && return
  printf -- "${LibOutput__LeftPrefix}${bakpur}[ debug ] $*  ${clr}\n"
}

warn() {
  printf -- "${LibOutput__LeftPrefix}${bldwht}${bakylw} « WARNING! » ${clr} ${bldylw}$*${clr}" >&2
}

warning() {
  header=$(printf -- "${txtblk}${bakylw} « WARNING » ${clr}")
  local first="$1"
  shift
  box.yellow-in-yellow "${header} ${bldylw}$first" "$@" >&2
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
  box.red-in-red "${header} ${bldylw}$@" >&2
}

info:() {
  inf $*
  ui.closer.ok:
}

error:() {
  err $*
  ui.closer.not-ok:
}

warning:() {
  warn $*
  ui.closer.kind-of-ok:
}

shutdown() {
  local message=${1:-"Shutting down..."}
  echo
  box.red-in-red "${message}"
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
  .output.clean "$@"
}

columnize() {
  local columns="${1:-2}"

  local sw=${SCREEN_WIDTH:-120}
  [[ -z ${sw} ]] && sw=$(screen-width)

  pr -l 10000 -${columns} -e4 -w ${sw} |
    expand -8 |
    sed -E '/^ *$/d' |
    grep -v 'Page '
}
