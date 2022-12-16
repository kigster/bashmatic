#!/usr/bin/env bash
# Private functions
# shellcheck disable=SC2155

export LibOutput__CommandPrefixLen=7
export LibOutput__LeftPrefix="       "

export LibOutput__MinWidth__Default=50
export LibOutput__MaxWidth__Default=100
export LibOutput__MinHeight__Default=20

export LibOutput__WidthDetectionStrategy="unconstrained"
export LibOutput__CachedScreenWidthMs=10000 # how long to cache screen-width for.
export bashmatic_spacer_width="${bashmatic_spacer_width:-4}"

function output.reset-min-max-width() {
  export LibOutput__MinWidth=${LibOutput__MinWidth:-${LibOutput__MinWidth__Default}}
  export LibOutput__MaxWidth=${LibOutput__MaxWidth:-${LibOutput__MaxWidth__Default}}
  export LibOutput__MinHeight=${LibOutput__MaxHeight:-${LibOutput__MinHeight__Default}}
}

output.reset-min-max-width

# @description OS-independent way to determine screen width.
function output.screen-width.actual() {
  local w
  case "${BASHMATIC_OS_NAME}" in
  darwin)
    w="$(.output.stty.field columns)"
    ;;
  linux)
    w="$(stty -a 2>/dev/null | grep columns | awk '{print $7}' | sedx 's/;//g')"
    ;;
  *)
    error "Unsupported OS: ${BASHMATIC_OS_NAME}"
    return 1
    ;;
  esac

  printf -- "%d" "${w}"
}

# @description OS-independent way to determine screen height.
function output.screen-height.actual() {
  local h
  case ${BASHMATIC_OS_NAME} in
  darwin)
    h="$(.output.stty.field rows)"
    ;;
  linux)
    h="$(stty -a 2>/dev/null | grep rows | awk '{print $5}' | sedx 's/;//g')"
    ;;
  *)
    error "Unsupported OS: ${BASHMATIC_OS_NAME}"
    return 1
    ;;
  esac

  printf -- "%d" "${h}"
}

function output.constrain-screen-width() {
  export LibOutput__WidthDetectionStrategy="constrained"
  [[ $1 -gt 0 ]] && output.set-max-width "$1"
  [[ $2 -gt 0 ]] && output.set-min-width "$2"
  return 0
}

function bashmatic.set-widget-width-to() {
  output.constrain-screen-width "$@"
}

function output.unconstrain-screen-width() {
  export LibOutput__WidthDetectionStrategy="unconstrained"
  return 0
}

function output.set-max-width() {
  [[ $1 -gt 0 ]] && export LibOutput__MaxWidth="$1"
}

function output.set-min-width() {
  [[ $1 -gt 0 ]] && export LibOutput__MinWidth="$1"
}

function .output.cursor-right-by() {
  output.is-terminal && printf "\e[${1}C"
}

function .output.cursor-left-by() {
  output.is-terminal && printf "\e[${1}D"
}

function .output.cursor-up-by() {
  output.is-terminal && printf "\e[${1}A"
}

function .output.cursor-down-by() {
  output.is-terminal && printf "\e[${1}B"
}

function .output.cursor-move-to-y() {
  output.is-terminal || return
  .output.cursor-up-by 1000
  .output.cursor-down-by "${1:-0}"
}

function .output.cursor-move-to-x() {
  output.is-terminal || return
  .output.cursor-left-by 1000
  [[ -n $1 && "$1" -ne 0 ]] && .output.cursor-right-by "${1}"
}

function cursor.rewind() {
  local x=${1:-0}
  .output.cursor-move-to-x "${x}"
}

function cursor.left() {
  .output.cursor-left-by "$@"
}

function cursor.up() {
  .output.cursor-up-by "$@"
}

function cursor.down() {
  .output.cursor-down-by "$@"
}

function cursor.right() {
  .output.cursor-right-by "$@"
}

function cursor.save() {
  printf "\e[s"
}

function cursor.restore() {
  printf "\e[u"
}

function output.print-at-x-y() {
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

function .ver-to-i() {
  version=${1}
  echo "${version}" | awk 'BEGIN{FS="."}{ printf "1%02d%03.3d%03.3d", $1, $2, $3}'
}

function output.color.on() {
  printf "${bldred}" >&2
  printf "${bldblu}" >&1
}

function output.color.off() {
  reset-color: >&2
  reset-color: >&1
}

function .output.stty.field() {
  local field="$1"
  stty -a 2>/dev/null | grep "${field}" | tr -d ';' | tr ' ' '\n' | grep -B 1 "${field}" | head -1
}

function .output.current-screen-width.unconstrained() {
  if output.is-pipe; then
    printf -- '%d' "${LibOutput__MaxWidth:-100}"
  else
    output.screen-width.actual
  fi
}

function screen.width.actual() {
  .output.current-screen-width.unconstrained
}

function screen.height.actual() {
  .output.screen-height
}

function .output.current-screen-width.constrained() {
  local w=$(.output.current-screen-width.unconstrained)

  local min_w="${LibOutput__MinWidth}"
  local max_w="${LibOutput__MaxWidth}"

  [[ -z ${w} ]] && w="${min_w}"

  [[ -n ${min_w} && ${w} -lt ${min_w} ]] && w="${min_w}"
  [[ -n ${max_w} && ${w} -gt ${max_w} ]] && w="${max_w}"

  printf -- "%d" "$w"
}

function .output.current-screen-width() {
  local strategy="${LibOutput__WidthDetectionStrategy}"
  local func=".output.current-screen-width.${strategy}"
  is.a-function "${func}" || {
    error "invalid strategy: ${strategy}" >&2
    return 1
  }
  ${func}
}

function .output.screen-width() {
  if output.is-terminal ; then
    printf -- "%d" $(output.screen-width.actual)
    return 0
  fi

  if output.is-pipe || output.is-redirect || output.is-ssh; then
    printf -- "%d" 120
    return 0
  fi

  if [[ -n ${CI} ]]; then
    printf -- "%d" 120
  else
    printf -- "%d" 100
  fi

  local w
  w="$(.output.current-screen-width)"

  printf -- "%d" "${w}"
  return 0
}

function .output.screen-height() {
  local h=$(output.screen-height.actual)
  [[ -z ${h} ]] && h=${LibOutput__MinHeight}
  [[ ${h} -lt ${LibOutput__MinHeight} ]] && h=${LibOutput__MinHeight}
  printf -- $((h - 2))
}

function .output.line() {
  .output.repeat-char "─" "$(.output.width)"
}

function .output.hr() {
  local cols=${1:-$(.output.screen-width)}
  local char=${2:-"—"}
  local color=${3:-${txtylw}}

  printf "${color}"
  .output.repeat-char "─" "${cols}"
  reset-color
}

function .output.replicate-to() {
  local char="$1"
  local len="$2"

  .output.repeat-char "${char}" "${len}"
}

function .output.sep() {
  .output.hr
  printf "\n"
}

# set background color to something before calling this
function .output.bar() {
  .output.repeat-char " "
  reset-color
}

function .output.clean.pipe() {
  sedx 's/(\x1b|\\\e)\[[0-9]*;?[0-9]?+m//g; s/\r//g'
}

function ascii-pipe() {
  cat | .output.clean.pipe
}

function .output.clean() {
  local text="$*"
  printf -- '%s' "${text}" | .output.clean.pipe
}

function ascii-clean() {
  .output.clean "$@"
}

################################################################################
# <box>
################################################################################
# shellcheck disable=SC2120
function .output.box-separator() {
  printf "$1├"
  .output.line
  #.output.cursor-left-by 1
  printf "┤${clr}\n"
}

# shellcheck disable=SC2120
function .output.box-top() {
  printf "$1┌"
  .output.line
  #.output.cursor-left-by 1
  printf "┐${clr}\n"
}

function .output.box-bottom() {
  printf "└"
  .output.line
  #.output.cursor-left-by 1
  printf "┘${clr}\n"
}

function .output.boxed-text() {
  local __color_bdr="${1}"
  shift
  local __color_fg="${1}"
  shift
  local text="$*"

  output.is-terminal || {
    printf ">>> %80.80s <<< \n" "${text}"
    return
  }

  local width="$(.output.width)"
  local border_right=$((width))
  local inner_width=$((width - 1))

  # left border
  printf -- "${__color_bdr}%s${__color_fg}" '│'

  # whitespace padding
  .output.repeat-char " " "${inner_width}"

  # right border
  cursor.at.x "${border_right}"
  printf -- " ${__color_bdr}%s${clr}" '│'

  # back to beginning
  cursor.at.x 3

  printf -- "${__color_fg}${text}${clr}\n"
}

# Usage: .output.box border-color text-color "line 1" "line 2" ....
function .output.box() {
  local __color_bdr=${1}
  shift
  local __color_fg=${1}
  shift
  local line

  output.is-terminal || {
    for line in "$@"; do
      printf ">>> %80.80s <<< \n" "${line}"
    done
    return
  }

  [[ -n "${opts_suppress_headers}" ]] && return

  printf "\n${__color_bdr}"
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
  echo
}

################################################################################
# </box>
################################################################################

function .output.center() {
  local color="${1}"
  shift
  local text="$*"

  local width=$(.output.width)

  printf "${color}"
  output.is-tty && {
    cursor.at.x 0
    .output.repeat-char " " "${width}"
    cursor.at.x 4
  }
  printf "${color}%s${clr}" "${text}"
  echo
}

function .output.set-indent() {
  local shift="$1"

  [[ ${shift} -ge 0 && ${shift} -lt 100 ]] && {
    export bashmatic_spacer_width=${shift}
  }
}

function .set-indent() {
  .output.set-indent "$@"
}

function .output.width() {
  local w=$(screen.width)
  printf "%d" $((w - 4))
}

function .output.left-as-is() {
  .output.left-as-is.black-text "$@"
}

function .output.left-as-is.black-text() {
  local bg="${1}"
  shift # bar  background
  local tfg="${1}"
  shift # text foreground
  local text="$*"

  local len=${#text}
  len=$((len + 5))
  local tlen=$((len - 5))
  text="$(printf -- "%${tlen}.${tlen}s" "${text}")"

  local fg="${txtblk}"
  local prefix="${clr} "

  printf -- "\n${prefix}${fg}${bg}"
  if output.is-terminal; then
    .output.repeat-char " " ${len}
    printf -- "${inverse_on}${clr}${inverse_off}"
    .output.cursor-left-by 1000
    printf -- "${prefix}${fg}${tfg}${bg}   ${text}"
    cursor.down 1
    printf -- "${clr}\n"
  else
    printf -- "${prefix}${bg}${fg} ${text} ${inverse_on}${clr}\n\n"
  fi
  hr
  .output.cursor-left-by 1000
  printf -- "${prefix}\n"

}

function .output.left-justify() {
  local color="${1}"
  shift
  local text="$*"
  printf "\n${color}"
  if output.is-terminal; then
    local width=$(($(.output.width) - 4))
    printf -- "    %-${width}.${width}s${clr}\n\n" "${text}"
  else
    printf -- " ❯❯ %-${width}.${width}s${clr}\n\n" "${text}"
  fi
}

function .output.left-powerline() {
  local color="$1"
  shift

  local width
  is.numeric "$1" && {
    width="$1"
    shift
  }

  local v_bg="bak${color}"
  local v_fg="txt${color}"

  local bg="$(.subst "${v_bg}")"
  local fg="$(.subst "${v_fg}")"

  local normal="${txtblk}${bg}"
  local inverse="${fg}"

  local text="$*"
  printf "\n"
  if output.is-terminal; then
    [[ -z ${width} ]] && width=$(.output.width)

    printf -- "${normal}%${width}.${width}s${inverse}${clr}" " "
    cursor.at.x 3
    printf -- "${normal}${text}${clr}"
    echo
    cursor.down 1
  else
    printf -- "——❯❯ ${text} ——❯❯\n\n"
  fi
  echo
}

################################################################################
# Public functions
################################################################################

# Prints text centered on the screen
# Usage: center "colors/prefix" "text"
#    eg: center "${bakred}${txtwht}" "Welcome Friends!"
function center() {
  .output.center "$@"
}

function left() {
  .output.left-justify "$@"
}

# @description Prints a "arrow-like" line using powerline characters
# @arg1 Width (optional) — only intepretered as width if the first argument is a number.
# @args Text to print
function section() {
  .output.left-powerline pur "$@"
}

function cursor.at.x() {
  .output.cursor-move-to-x "$@"
}

function cursor.at.y() {
  .output.cursor-move-to-y "$@"
}

function cursor.shift.x() {
  local shift="$1"
  if [[ "${shift:0:1}" == "-" ]]; then
    .output.cursor-left-by "${shift:1}"
  else
    .output.cursor-right-by "${shift}"
  fi
}

function screen.width() {
  .output.screen-width
}

function screen-width() {
  .output.screen-width
}

function screen.height() {
  .output.screen-height
}

function screen-height() {
  .output.screen-height
}

function output.is-terminal() {
  output.is-tty || output.is-redirect || output.is-pipe || output.is-ssh
}

function output.is-ssh() {
  [[ -n "${SSH_CLIENT}" || -n "${SSH_CONNECTION}" ]]
}

function output.is-tty() {
  [[ -t 1 ]]
}

function output.is-pipe() {
  [[ -p /dev/stdout ]]
}

function output.has-stdin() {
  [[ ! -t 0 ]]
}

function output.is-redirect() {
  [[ ! -t 1 && ! -p /dev/stdout ]]
}

function hr.colored() {
  local color="$*"
  [[ -z ${color} ]] && color="${bldred}"
  .output.hr "$(screen-width)" "—" "${*}"
}

function hr() {
  [[ -z "$*" ]] || printf "$*"
  .output.hr
}

function stdout() {
  local file=$1
  hl.subtle STDOUT
  printf "${clr}"
  [[ -s ${file} ]] && cat "${file}"
  reset-color
}

function stderr() {
  local file=$1
  hl.subtle STDERR
  printf "${txtred}"
  [[ -s ${file} ]] && cat "${file}"
  reset-color
}

function duration() {
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
    [[ ${exit_code} -eq 0 ]] && printf " ${txtblk}${bakgrn} %3d ${clr}" "${exit_code}"
    [[ ${exit_code} -gt 0 ]] && printf " ${bldwht}${bakred} %3d ${clr}" "${exit_code}"
  fi
}

function left-prefix() {
  [[ -z ${LibOutput__LeftPrefix} ]] && {
    export LibOutput__LeftPrefix=$(.output.replicate-to " " "${LibOutput__LeftPrefixLen}")
  }
  printf "${LibOutput__LeftPrefix}"
}

#—————————————————————————————————————————————————————————————————
# Closers for open-ended statements like `inf`, `warn`, `debug`, `err`
#—————————————————————————————————————————————————————————————————
function ui.closer.ok() {
  .output.cursor-left-by 1000
  printf " ${txtblk}${bakgrn} ✔︎ ${clr} "
}

function inline.ok() {
  printf " ${txtblk}${bakgrn} ✔︎ ${clr} "
}

function inline.not-ok() {
  printf " ${txtwht}${bakred} ✘ ${clr} "
}

function ui.closer.ok:() {
  ui.closer.ok "$@"
  echo
}

function ok() { ui.closer.ok "$@"; }
function ok:() { ui.closer.ok: "$@"; }

function ui.closer.not-ok() {
  .output.cursor-left-by 1000
  printf " ${bakred}${bldwht} ✘ ${clr} "
}

function ui.closer.not-ok:() {
  ui.closer.not-ok "$@"
  echo
}

function not-ok() { ui.closer.not-ok "$@"; }

function not-ok:() { ui.closer.not-ok: "$@"; }

function ui.closer.kind-of-ok() {
  .output.cursor-left-by 1000
  printf " ${bakylw}${bldwht} ❖ ${clr} "
}

function ui.closer.kind-of-ok:() {
  ui.closer.kind-of-ok "$@"
  echo
}
