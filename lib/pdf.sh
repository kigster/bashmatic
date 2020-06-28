pdf.combine() {
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
}
