#!/usr/bin/env bash
#
# (c) 2019 Konstantin Gredeskoul, MIT License.
#
# Usage Example (Generating JSON Certificates)
# ============================================
#
# DOMAIN="my.awesome.domain"
# json.begin-hash
#  json.begin-hash "${DOMAIN/star/*}"
#    json.file-to-array "key"         "${DOMAIN}.key"        true
#    json.file-to-array "certificate" "${DOMAIN}.crt"        true
#    json.file-to-array "chain"       "${DOMAIN}.chain"
#  json.end-hash
# json.end-hash

json.begin-array() {
  [[ -n "$1" ]] && json.begin-key "$1"
  echo " ["
}

json.end-array() {
  printf "]"
  [[ "$1" == "true" ]] && printf ","
  echo
}

json.file-to-array() {
  json.begin-array "$1"
  cat "$2" |
    tr -d '\r' |
    tr -d '\015' |
    sed 's/^/"/g;s/$/",/g' |
    tail -r |
    awk -F, '{if (FNR!=1) print; else print $1} ' |
    tail -r

  json.end-array "$3"
}

json.begin-key() {
  if [[ -n "$1" ]]; then
    printf "\"${1}\": "
  fi
}

json.begin-hash() {
  [[ -n "$1" ]] && json.begin-key "$1"
  echo "{"
}

json.end-hash() {
  printf "}"
  [[ "$1" == "true" ]] && printf ","
  echo
}


