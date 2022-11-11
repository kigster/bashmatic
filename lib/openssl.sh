#!/usr/bin/env bash
# vim: ft=bash

# @description Generate a CSR for NGINX domain

export default_certificate_info="/C=US/ST=California/L=San Francisco/O=ReinventONE Inc./OU=IT/CN="

function .openssl.certs.print-generated() {
    local file="$1"
    h.blue "Would you like to view the generated certificate?"
    run.ui.ask "Press any key to view, or Ctrl-C to abort."
    openssl req -text -in "${file}" -noout -verify
}

function openssl.certs.generate-csr() {
    local domain="${1:-"domain"}"
    local subject="${2:-"${default_certificate_info}"}${domain}"
    local server="${domain/\*/star}"

    hl.desc "Generating CSR + Private Key for domain [${domain}]"
    set -e
    openssl req -new -newkey rsa:4096 -nodes -keyout "${server}.key" -out "${server}.csr" -subj "${subject}"
    pbcopy < "${server}.csr"
    success "CSR is now in the file ${server}.csr and your clipboard."
    set +e

    .openssl.certs.print-generated "${server}.csr" 2>/dev/null

    return 0
}



