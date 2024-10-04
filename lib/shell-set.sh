#!/usr/bin/env bash
# ———————————————————————————————————————————————————————
# BashMatic Utilities Library
# ———————————————————————————————————————————————————————
# © 2016-2024 Konstantin Gredeskoul, All rights reserved. MIT License.
#
# Distributed under the MIT LICENSE.
#
# Sources: https://github.com/kigster/bashmatic
# ———————————————————————————————————————————————————————
#
# This part of the library deals with Shell's set properties.
# As you may know you can call set -e/+e or set -x/+x and so on
# to control various behaviors of the shell.
#
# Sometimes when we run a subroutine, we want to not fail on
# error, and set +e is the solution. However, what if before we
# entered the subroutine, that option was set to -e instead?
# In this case the right thing to do is to restore it to whatever
# it was prior to changing it.
#
# This is what this library is about. It maintains a stack
# of set values for each call to shell-set.push-stack "character"
# and subsequently restore with shell-set.pop-stack "character".
# It works with both +{value} and -{value} — whatever the state is
# it is pushed on top of the stack.
#
# Example:
#
#    #!/usr/bin/env bash
#    source ${BASHMATIC_HOME}/lib/shell-set.sh
#    # we set this because we want to fail on errors
#    set -e
#
#    # this function has a body that might trigger a failure
#    # but we'd rather handle it in the function than abort.
#    function myfunc() {
#       shell-set.push-stack e             # save the state of set -e/+e
#
#       set +e
#       # perform operation that may fail
#
#       shell-set.pop-stack e              # now set -e/+e is restored.
#    }
#
#

shell-set.is-set() {
  local v="$1"
  local is_set=${-//[^${v}]/}
  if [[ -n ${is_set} ]]; then
    return 0
  else
    return 1
  fi
}

shell-set.show-stack() {
  info "Current Shell Set Stack: ${bldylw}[${SetOptsStack[*]}]"
}

shell-set.init-stack() {
  unset SetOptsStack
  declare -a SetOptsStack=()
  export SetOptsStack
}

shell-set.push-stack() {
  local value="$1"
  local is_set=${-//[^${value}]/}

  shell-set.is-set "${value}" && export SetOptsStack=(${SetOptsStack[@]} "-${value}")
  shell-set.is-set "${value}" || export SetOptsStack=(${SetOptsStack[@]} "+${value}")

  [[ -n ${BASHMATIC_DEBUG} ]] && shell-set-show
}

shell-set.pop-stack() {
  local value="$1"

  local len=${#SetOptsStack[@]}
  local last_index=$((len - 1))
  local last=${SetOptsStack[${last_index}]}
  if [[ ${last} != "-${value}" && ${last} != "+${value}" ]]; then
    error "Can not restore ${value}, not the last element in ${SetOptsStack[*]} stack."
    return 1
  fi

  local pop=(${last})

  export SetOptsStack=("${SetOptsStack[@]/$pop/}")
  [[ -n ${BASHMATIC_DEBUG} ]] && shell-set-show
  eval "set ${last}"
}

# Deprecated
save-set-x() { shell-set.push-stack x; }
save-restore-x() { shell-set.pop-stack x; }

[[ -z "${SetOptsStack[*]}" ]] && shell-set.init-stack


