#!/usr/bin/env bash
# Private functions
# shellcheck disable=SC2155

#source "${BASHMATIC_HOME}/lib/util.sh"

export LibOutput__CommandPrefixLen=7
export LibOutput__LeftPrefix="       "

export LibOutput__MinWidth__Default=50
export LibOutput__MaxWidth__Default=300
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

function output.constrain-screen-width() {
  export LibOutput__WidthDetectionStrategy="constrained"
  [[ $1 -gt 0 ]] && output.set-max-width "$1"
  [[ $2 -gt 0 ]] && output.set-min-width "$2"
  return 0
}

function output.unconstrain-screen-width() {
  export LibOutput__WidthDetectionStrategy="unconstrained"
  return 0
}

output.set-max-width() {
  [[ $1 -gt 0 ]] && export LibOutput__MaxWidth="$1"
}

output.set-min-width() {
  [[ $1 -gt 0 ]] && export LibOutput__MinWidth="$1"
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
  echo "${version}" | awk 'BEGIN{FS="."}{ printf "1%02d%03.3d%03.3d", $1, $2, $3}'
}

output.color.on() {
  printf "${bldred}" >&2
  printf "${bldblu}" >&1
}

output.color.off() {
  reset-color: >&2
  reset-color: >&1
}

.output.stty.field() {
  local field="$1"
  stty -a 2>/dev/null| grep "${field}" | tr -d ';' | tr ' ' '\n' | grep -B 1 "${field}" | head -1
}

.output.current-screen-width.unconstrained() {
  local w
  util.os
  if [[ ${AppCurrentOS} =~ darwin ]]; then
    w="$(.output.stty.field columns)"
  elif [[ ${AppCurrentOS} =~ linux ]]; then
    w="$(stty -a 2>/dev/null | grep columns | awk '{print $7}' | sedx 's/;//g')"
  fi
  printf -- "%d" "$w"
}

.output.current-screen-width.constrained() {
  local w=$(.output.current-screen-width.unconstrained)

  local min_w="${LibOutput__MinWidth}"
  local max_w="${LibOutput__MaxWidth}"

  [[ -z ${w} ]] && w="${min_w}"

  [[ -n ${min_w} && ${w} -lt ${min_w} ]] && w="${min_w}"
  [[ -n ${max_w} && ${w} -gt ${max_w} ]] && w="${max_w}"

  printf -- "%d" "$w"
}

.output.current-screen-width() {
  local strategy="${LibOutput__WidthDetectionStrategy}"
  local func=".output.current-screen-width.${strategy}"
  is.a-function "${func}" || {
    error "invalid strategy: ${strategy}" >&2
    return 1
  }
  ${func}
}

.output.screen-width() {
  if [[ -n ${CI} ]]; then
    printf -- "120"
    return 0
  fi

  # local now
  # now="$(millis)"

  # if [[ -n "${LibOutput__CachedScreenWidth}" && $((now - LibOutput__CachedScreenMillis)) -lt ${LibOutput__CachedScreenWidthMs} ]]; then
  #   printf -- "${LibOutput__CachedScreenWidth}"
  #   return 0
  # fi

  local w
  w="$(.output.current-screen-width)"

  # export LibOutput__CachedScreenWidth="${w}"
  # export LibOutput__CachedScreenMillis="${now}"

  printf -- "%d" "${w}"
}

.output.screen-height() {
  util.os
  local h
  if [[ ${AppCurrentOS} =~ darwin ]]; then
    h="$(.output.stty.field rows)"
  elif [[ ${AppCurrentOS} =~ linux ]]; then
    h="$(stty -a 2>/dev/null | grep rows | awk '{print $5}' | sedx 's/;//g')"
  fi

  [[ -z ${h} ]] && h=${LibOutput__MinHeight}
  [[ ${h} -lt ${LibOutput__MinHeight} ]] && h=${LibOutput__MinHeight}
  printf -- $((h - 2))
}

.output.line() {
  .output.repeat-char "─" "$(.output.width)"
}

.output.hr() {
  local cols=${1:-$(.output.screen-width)}
  local char=${2:-"—"}
  local color=${3:-${txtylw}}

  printf "${color}"
  .output.repeat-char "─" "${cols}"
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

# set background color to something before calling this
.output.bar() {
  .output.repeat-char " "
  reset-color
}

.output.clean.pipe() {
  sedx 's/(\x1b|\\\e)\[[0-9]*;?[0-9]?+m//g; s/\r//g'
}

ascii-pipe() {
  cat | .output.clean.pipe
}

.output.clean() {
  local text="$*"
  printf -- '%s' "${text}" | .output.clean.pipe
}

ascii-clean() {
  .output.clean "$@"
}

################################################################################
# <box>
################################################################################
# shellcheck disable=SC2120
.output.box-separator() {
  printf "$1├"
  .output.line
  #.output.cursor-left-by 1
  printf "┤${clr}\n"
}

# shellcheck disable=SC2120
.output.box-top() {
  printf "$1┌"
  .output.line
  #.output.cursor-left-by 1
  printf "┐${clr}\n"
}

.output.box-bottom() {
  printf "└"
  .output.line
  #.output.cursor-left-by 1
  printf "┘${clr}\n"
}

.output.boxed-text() {
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

.output.center() {
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

.output.set-indent() {
  local shift="$1"

  [[ ${shift} -ge 0 && ${shift} -lt 100 ]] && {
    export bashmatic_spacer_width=${shift}
  }
}

.set-indent() {
  .output.set-indent "$@"
}

.output.width() {
  local w=$(screen.width)
  printf "%d" $((w  - 4))
}

.output.left-justify() {
  local color="${1}"
  shift
  local text="$*"
  printf "\n${color}"
  if output.is-terminal; then
    local width=$(( $(.output.width) - 4 ))
    printf -- "    %-${width}.${width}s${clr}\n\n" "${text}"
  else
    printf -- " ❯❯ %-${width}.${width}s${clr}\n\n" "${text}"
  fi
}

.output.left-powerline() {
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
center() {
  .output.center "$@"
}

left() {
  .output.left-justify "$@"
}

# @description Prints a "arrow-like" line using powerline characters
# @arg1 Width (optional) — only intepretered as width if the first argument is a number.
# @args Text to print
section() {
  .output.left-powerline pur "$@"
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

screen-width() {
  .output.screen-width
}

screen.height() {
  .output.screen-height
}

screen-height() {
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

output.has-stdin() {
  [[ ! -t 0 ]]
}

output.is-redirect() {
  [[ ! -t 1 && ! -p /dev/stdout ]]
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
