#!/usr/bin/env bash

lib::vim::setup() {
  export LibVim__initFile="${HOME}/.bashrc"
  export LibVim__editorVi="vi"
  export LibVim__editorGvimOn="gvim"
  export LibVim__editorGvimOff="vim"
}

lib::vim::gvim-off() {
  lib::vim::setup

  # fix any EDITOR assignments in ~/.bashrc
  egrep -q '^export EDITOR=gvim' ${LibVim__initFile} && \
    run "cat ${LibVim__initFile} | sed -e 's/^export EDITOR=.*$/export EDITOR=vim/g' > /tmp/.a.$$"
  egrep -q '^export EDITOR=gvim' ${LibVim__initFile} && \
    run "mv /tmp/.a.$$ ${LibVim__initFile}"

  # append to ~/.bashrc
  egrep -q '^export EDITOR=' ${LibVim__initFile} || echo "export EDITOR=${LibVim__editorGvimOff}" >> ${LibVim__initFile}
  # import into the current shell
  eval "
    set -x
    export EDITOR=${LibVim__editorGvimOn}
    unalias ${LibVim__editorVi}
    unalias ${LibVim__editorGvimOff}
    set +x
  "
}

lib::vim::gvim-on() {
  lib::vim::setup

  # fix any EDITOR assignments in ~/.bashrc
  egrep -q '^export EDITOR=gvim' ${LibVim__initFile} && \
    run "cat ${LibVim__initFile} | sed -e 's/^export EDITOR=.*$/export EDITOR=${LibVim__editorGvimOn}/g' > /tmp/.a.$$"
  egrep -q '^export EDITOR=gvim' ${LibVim__initFile} && \
    run "mv /tmp/.a.$$ ${LibVim__initFile}"

  # append to ~/.bashrc
  egrep -q '^export EDITOR=' ${LibVim__initFile} || \
    echo "export EDITOR=${LibVim__editorGvimOn}" >> ${LibVim__initFile}

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

