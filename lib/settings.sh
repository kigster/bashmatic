#!/usr/bin/env bash

export True="1"
export False="0"

export AppNodeVersion="9.4.0"
export AppNvmVersion="0.33.2"

export AppPostgresVersion=${PostgreSQLVersion:-"9.4"}
export AppPostgresHostname="localhost"
export AppPostgresUsername="postgres"

export AppCurrentOS=$(uname -s)

if [[ -f ".ruby-version" ]]; then
  export AppRubyVersion=$(cat .ruby-version)
else
  export AppRubyVersion="2.4.3"
fi

declare -a AppBrewCasks=(
  chromedriver
  gitx
  textmate
  atom
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
