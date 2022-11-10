#!/usr/bin/env bash
# vim: ft=sh

zsh.install.oh-my-zsh() {
  if [[ -d ${HOME}/.oh-my-zsh/ ]] ; then
    info "oh-my-zsh is already installed, updating..."
    run "cd ${HOME}/.oh-my-zsh"
    run "git pull || true"
  else
    info "Installing oh-my-zsh..."
    run "sh -c \"\$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
  fi

  if [[ -f ${HOME}/.zshrc ]] ; then
    run "sed -E -i '' 's/robbyrussell/agnoster/g' ${HOME}/.zshrc"
    run "sed -E -i '' 's/^plugins=.*$/plugins=(git wd golang osx aws brew zsh-completions)/g' ${HOME}/.zshrc"
  fi
}

zsh.install.plugins() {
  zsh.install.oh-my-zsh

  local dest="${ZSH_CUSTOM:=${HOME}/.oh-my-zsh/custom}/plugins"
  run "mkdir -p ${dest}"

  [[ -d ${dest}/zsh-completions ]] || {
    run "git clone https://github.com/zsh-users/zsh-completions ${dest}/zsh-completions"
  }

  [[ -d ${dest}/brew ]] || {
    run "mkdir ${dest}/brew"
    run "curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/brew/brew.plugin.zsh > ${dest}/brew/brew.plugin.zsh"
  }
}

zsh.install() {
  zsh.install.plugins
}




