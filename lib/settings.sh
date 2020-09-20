#!/usr/bin/env bash

export True="1"
export False="0"

export AppCurrentOS=$(uname -s)

# Last updated 12/06/2019

export AppNodeVersion="13.2.0"
export AppYarnVersion="1.19.2"

if [[ -f ".ruby-version" ]]; then
  AppRubyVersion=$(cat .ruby-version)
else
  AppRubyVersion="2.6.5"
fi
export AppRubyVersion

declare -a AppBrewCasks=(
  visual-studio-code
  chromedriver
  GitX-dev
  textmate
)

export AppBrewCasks

declare -a AppBrewPackages=(
  ag
  autoconf
  autogen
  automake
  awscli
  bash
  bash-completion
  coreutils
  curl
  direnv
  go
  htop
  hub
  imagemagick
  jemalloc
  jq
  mas
  memcached
  openssl
  rbenv
  redis
  ruby-build
  screen
  the_silver_searcher
  tmux
  wget
  webpack
  yarn
)

export AppBrewPackages
export AppDefaultBackupDir='tmp/pgdump'
