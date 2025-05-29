#!/usr/bin/env bash
# vim: ft=bash
# @copyright © 2016-2024 Konstantin Gredeskoul, All rights reserved
# @license MIT License.
#
# @file lib/menus.sh

# @description: A generic menu select from a list of values.
#       Works even if the list is longer than the screen height.
#       Arrows left/right can be used as Page Up/Down
#
# @example
#     selections=(
#       "Selection A"
#       "Selection B"
#       "Selection C"
#     )
#     menu-select "Please make a choice:" selected_choice "${selections[@]}"
#     echo "You chose: $selected_choice"
#
function menu.select() {
  local prompt="$1"
  local outvar="$2"
  clear
  shift
  shift
  local -a options

  options=("$@")
  cur=0
  index=0
  count=${#options[@]}

  local max_height=$(( $(screen.height) - 5 ))
  local from=0
  local visible_size=$(( max_height > count ? count : max_height ))
  local to=$((visible_size))
  local action
  local delta
  local -a esc
  esc=$(echo -en "\e") # cache ESC as test doesn't allow esc codes

  if [[ $visible_size -lt $count ]]; then
    prompt="${prompt} (Use arrows ⇅ to scroll by one, or ⇆ to scroll by page)"
  fi

  while true; do
    printf "${txtylw}$prompt${clr}\n\n"
    # list all options (option list is zero-based)
    index=0

    ((from < 0)) && from=0
    ((to > count)) && to=$((count - 1))

    for o in "${options[@]:${from}:${to}}"; do
      if [[ $index -ge ${max_height} ]]; then
        break
      fi
      if [[ $((from + index)) -eq $cur ]]; then
        printf "${esc}[1;7;33m ❯ %-120.120s${clr}\n" "$o"
      else
        printf "   ${txtgrn}%-120.120s${clr}\n" "$o"
      fi
      ((index++))
    done
    read -r -s -n3 key                  # wait for user to key in arrows or ENTER
    if [[ ${key} == "${esc}[A" ]]; then # up arrow
      ((cur--))
      ((cur < 0)) && {
        ((cur = 0))
        ((from = 0))
        ((to = visible_size))
      }
      ((cur < from)) && {
        ((from = cur))
        ((to = from + visible_size))
      }
    elif [[ ${key} == "${esc}[B" ]]; then # down arrow
      ((cur++))
      if ((cur >= count)); then
        ((cur = count - 1))
      else
        if ((cur >= to )) ; then
          ((to = cur + 1))
          ((from = to - visible_size))
        fi
      fi
    elif [[ ${key} == "${esc}[C" && ${count} -gt ${visible_size}  ]]; then # page up
      ((cur -= visible_size))
      ((to -= visible_size))
      ((from -= visible_size))

      ((cur < 0)) && {
        ((cur = 0))
        ((from = 0))
        ((to = visible_size))
      }
      ((from < 0)) && ((from = 0))
      ((to < max_height)) && ((to = visible_size))
    elif [[ ${key} == "${esc}[D" && ${count} -gt ${visible_size} ]]; then # page down
      ((cur += visible_size))
      ((to += visible_size))
      ((from += visible_size))

      ((cur >= count)) && {
        delta=$(( cur - count + 1))
        ((cur -= delta))
        ((from -= delta))
        ((to -= delta))
      }
      ((to > count)) && ((to = count))
      ((from != to - max_height)) && ((from = to - max_height))
    elif [[ ${key} == "" ]]; then # nothing, i.e the read delimiter - ENTER
      break
    fi
    echo -en "\e[$((visible_size + 2))A" # go up to the beginning to re-render
  done
  # export the selection to the requested output variable
  printf -v $outvar "${options[${cur}]}"
}



