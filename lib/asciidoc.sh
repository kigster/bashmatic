#!/usr/bin/env bash
#
# © 2016-2020 Konstantin Gredeskoul, All rights reserved. MIT License.
# @file asciidoc
# @description Provides helper functions for dealing with asciidoc format.
#

# @description Installs gem "rouge" and prints all available themes
function asciidoc.rouge-themes() {
  gem.install rouge
  info "Available themes:"
  local -a themes=($(ruby -e 'require :rouge.to_s; puts Rouge::Theme.registry.keys.sort.join ?\n'))

  array.to.bullet-list "${themes[@]}"
  echo

  info "To specify a theme in your *.adoc file, put this at the top:"
  info "${bldlyw}:source-highlighter: ${bldgrn}rouge"
  info "${bldlyw}:rouge-style: ${bldgrn}monokai"
}


