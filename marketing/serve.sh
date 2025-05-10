#!/usr/bin/env bash
# vim: ft=bash

[[ -f ~/.bashmatic/init ]] || {
  bash -c "$(curl -fsSL https://bashmatic.re1.re); bashmatic-install -q"
}
source ~/.bashmatic/init

run "bundle check || bundle install -j 12"

run.set-next show-output-on
run "bundle exec puma -C config/puma.rb"
