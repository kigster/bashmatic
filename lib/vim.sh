#!/usr/bin/env bash

lib::vim::setup() {
  export LibVim__initFile="${HOME}/.bashrc"
  export LibVim__editorVi="vi"
  export LibVim__editorGvimOn="gvim"
  export LibVim__editorGvimOff="vim"
}

lib::vim::gvim-off() {
  lib::vim::setup

  local regex_from='^export EDITOR=.*$'
  local regex_to='export EDITOR=vim'

  # fix any EDITOR assignments in ~/.bashrc
  lib::file::gsub "${LibVim__initFile}" "${regex_from}" "${regex_to}"
  lib::file::gsub "${LibVim__initFile}" '^gvim.on$' 'gvim.off'

  # append to ~/.bashrc
  egrep -q "${regex_from}" ${LibVim__initFile} || echo "${regex_to}" >> ${LibVim__initFile}
  egrep -q "^gvim\.o" ${LibVim__initFile} || echo "gvim.off" >> ${LibVim__initFile}

  # import into the current shell
  eval "
    set -x
    export EDITOR=${LibVim__editorGvimOn}
    unalias ${LibVim__editorVi} 2>/dev/null
    unalias ${LibVim__editorGvimOff} 2>/dev/null
    set +x
  "
}

lib::vim::gvim-on() {
  lib::vim::setup

  local regex_from='^export EDITOR=.*$'
  local regex_to='export EDITOR=gvim'

  lib::file::gsub "${LibVim__initFile}" "${regex_from}" "${regex_to}"
  lib::file::gsub "${LibVim__initFile}" '^gvim.off$' 'gvim.on'

  # append to ~/.bashrc
  egrep -q "${regex_from}" ${LibVim__initFile} || echo "${regex_to}" >> ${LibVim__initFile}
  egrep -q "^gvim\.o.*" ${LibVim__initFile} || echo "gvim.on" >> ${LibVim__initFile}

  # import into the current shell
  eval "
    set -x
    export EDITOR=${LibVim__editorGvimOn}
    alias ${LibVim__editorVi}=${LibVim__editorGvimOn}
    alias ${LibVim__editorGvimOff}=${LibVim__editorGvimOn}
    set +x
  "
}


gvim.on() { lib::vim::gvim-on; }
gvim.off() { lib::vim::gvim-off; }

