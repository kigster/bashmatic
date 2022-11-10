#!/usr/bin/env bash
# vim: ft=bash

# @file Bashmatic Utilities for PDF file handling
# @description Install and uses GhostScript to manipulate PDFs.

# @description Combine multiple PDFs into a single one using ghostscript.
#
# @example
#   pdf.combine ~/merged.pdf 'my-book-chapter*'
#
# @arg $1 pathname to the merged file
# @arg $@ the rest of the PDF files to combine
#
# @returns 0 Returns the exit code of the last command (ghostscript)
function pdf.combine() {
  local merged="${1}"
  shift

  local files=""

  for f in "$@"; do
    [[ -f "${f}" ]] && {
      info "Appending file ${bldylw}${f}"
      files="${files} '${f}'"
    }
  done

  [[ -s "${merged}" ]] && {
    warning "Merged file ${merged} already exists, removing..."
    run "rm -f \"${merged}\""
  }

  unalias gs 2>/dev/null

  [[ -n $(command -V gs) ]] || brew.install.package gs

  run "mkdir -p $(dirname "${merged}")"

  info "Please wait while GhostScript combines your PDFs into"
  info "destination file: ${bldylw}${merged}"

  run "gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=${merged} ${files}"

  return "${LibRun__LastExitCode}"
}


