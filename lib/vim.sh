#!/usr/bin/env bash

vim.setup() {
  export LibVim__initFile="${HOME}/.bash_profile"
  export LibVim__editorVi="vi"
  export LibVim__editorGvimOn="gvim"
  export LibVim__editorGvimOff="vim"
}

vim.gvim-off() {
  vim.setup

  [[ "${EDITOR}" == "vim" ]] && return 0

  local regex_from='^export EDITOR=.*$'
  local regex_to='export EDITOR=vim'

  # fix any EDITOR assignments in ~/.bashrc
  file.gsub "${LibVim__initFile}" "${regex_from}" "${regex_to}"
  file.gsub "${LibVim__initFile}" '^gvim.on$' 'gvim.off'

  # append to ~/.bashrc
  ${GrepCommand} -q "${regex_from}" "${LibVim__initFile}" || echo "${regex_to}" >>"${LibVim__initFile}"
  ${GrepCommand} -q "^gvim\.o" "${LibVim__initFile}" || echo "gvim.off" >>"${LibVim__initFile}"

  # import into the current shell
  eval "
    [[ -n '${BASHMATIC_DEBUG}' ]] && set -x
    export EDITOR=${LibVim__editorGvimOff}
    unalias ${LibVim__editorVi} 2>/dev/null
    unalias ${LibVim__editorGvimOff} 2>/dev/null
  "
}

vim.gvim-on() {
  vim.setup

  [[ "${EDITOR}" == "gvim" ]] && return 0

  local regex_from='^export EDITOR=.*$'
  local regex_to='export EDITOR=gvim'

  file.gsub "${LibVim__initFile}" "${regex_from}" "${regex_to}"
  file.gsub "${LibVim__initFile}" '^gvim.off$' 'gvim.on'

  # append to ~/.bashrc
  ${GrepCommand} -q "${regex_from}" "${LibVim__initFile}" || echo "${regex_to}" >>"${LibVim__initFile}"
  ${GrepCommand} -q "^gvim\.o.*" "${LibVim__initFile}" || echo "gvim.on" >>"${LibVim__initFile}"

  # import into the current shell
  eval "
    [[ -n '${BASHMATIC_DEBUG}' ]] && set -x
    export EDITOR=${LibVim__editorGvimOn}
    alias ${LibVim__editorVi}=${LibVim__editorGvimOn}
    alias ${LibVim__editorGvimOff}=${LibVim__editorGvimOn}
  "
}

gvim.on() { vim.gvim-on; }
gvim.off() { vim.gvim-off; }


