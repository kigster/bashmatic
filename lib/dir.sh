lib::dir::count-slashes() {
  local dir="${1}"
  echo "${dir}" | \
    sed 's/[^/]//g' | \
    tr -d '\n' | \
    wc -c | \
    tr -d ' '
}

lib::dir::is-a-dir() {
  local dir="${1}"
  [[ -d "${dir}" ]] 
}


