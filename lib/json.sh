#!/usr/bin/env bash
#
# (c) 2019 Konstantin Gredeskoul, MIT License.
#
# Usage Example (Generating JSON Certificates)
# ============================================
#
# DOMAIN="my.awesome.domain"
# lib::json::begin-hash
#  lib::json::begin-hash "${DOMAIN/star/*}"
#    lib::json::file-to-array "key"         "${DOMAIN}.key"        true
#    lib::json::file-to-array "certificate" "${DOMAIN}.crt"        true
#    lib::json::file-to-array "chain"       "${DOMAIN}.chain"
#  lib::json::end-hash
# lib::json::end-hash
 
lib::json::begin-array() {
  [[ -n "$1" ]] && lib::json::begin-key "$1"
  echo " ["
}

lib::json::end-array() {
  printf "]"
  [[ "$1" == "true" ]] && printf ","
  echo
}

lib::json::file-to-array() {
  lib::json::begin-array "$1"
  cat $2 |  \
    tr -d '\r' | \
    tr -d '\015' | \
    sed 's/^/"/g;s/$/",/g' | \
    tail -r | \
    awk -F, '{if (FNR!=1) print; else print $1} ' | \
    tail -r

  lib::json::end-array $3
}

lib::json::begin-key() {
  if [[ -n "$1" ]]; then
    printf "\"${1}\": "
  fi
}

lib::json::begin-hash() {
  [[ -n "$1" ]] && lib::json::begin-key "$1"
  echo "{"
}

lib::json::end-hash() {
  printf "}"
  [[ "$1" == "true" ]] && printf ","
  echo
}
