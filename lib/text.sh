#!/usr/bin/env bash
# vim: ft=bash

text.markdown-to-asciidoc() {
  local file="$1"; shift
  local default_flags="--imagesdir=/assets/images --no-html-to-native"

  [[ -n $(command -v kramdoc) ]] || gem.install "kramdown-asciidoc"

  if [[ -z "${file}" ]]; then
    usage.set-min-flag-len 1
    usage-box "text.markdown-to-asciidoc markdown-file [ flags ] © Converts a markdown doc to asciidoc using the kramdown-asciidoc ruby gem" \
      " " "Default flags: ${bldcyn}${default_flags}" \
      " " "To override pass any flags that are supported by ${bldred}kramdoc${bldylw}, see below:"
    
    printf "\n${txtblu}"
    kramdoc --help | tail -16
    printf "${clr}\n"
    return 0
  fi

  [[ -f ${file} && $(file.extension "${file}") == "md" ]] || {
    error "File ${file} either does not exist, or is not markdown."
    run.set-all on-decline-return
    run.ui.ask "Convert anyway?"
  }

  local target="$(file.extension.replace adoc "${file}")"
  file.ask.if-exists "${target}" || {
    info "Aborting conversion, leaving ${target} in place."
    return 1
  }

  gem.install "kramdown-asciidoc"
  local args
  if [[ -z "$*" ]]; then
    args="--auto-ids --auto-id-prefix=_ --auto-id-separator=_ --imagesdir=/assets/images --no-html-to-native"
  else
    args="$*"
  fi

  run "kramdoc -o ${target} ${args} ${file}"
}

text.ord() {
  LC_CTYPE=C printf '%d' "'$1"
}

text.chr() {
  [ "$1" -lt 256 ] || return 1
  printf "\\$(printf '%03o' "$1")"
}

