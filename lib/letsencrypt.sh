#!/usr/bin/env bash
# vim: ft=bash

DNS_PROVIDER="dnsmadeeasy"
DNS_CREDENTIALS_FILE="${HOME}/.${DNS_PROVIDER}/credentials.ini"
CERTBOT_CONFIG_DIR="${HOME}/.letsencrypt"
CERTBOT_LOG_DIR="${HOME}/.letsencrypt/log"
CERTBOT_WORK_DIR="${HOME}/.letsencrypt/work"

function letsencrypt.ensure-certbot() {
  command -v certbot>/dev/null 2>&1 || {
    package.install certbot
  }
  mkdir -p "${CERTBOT_CONFIG_DIR}"
  mkdir -p "${CERTBOT_LOG_DIR}"
  mkdir -p "${CERTBOT_WORK_DIR}"
  chown "${USER}" "${CERTBOT_CONFIG_DIR}"
  chown "${USER}" "${CERTBOT_LOG_DIR}"
  chown "${USER}" "${CERTBOT_WORK_DIR}"
}

function letsencrypt.obtain-ssl-certificate() {
  local domain="$1"
  local email="$2"

  if [ -z "$domain" ] || [ -z "$email" ]; then
    error "Domain and Email are required to obtain an SSL certificate."
    return 1
  fi

  certbot certonly \
    --dns-${DNS_PROVIDER} \
    --dns-${DNS_PROVIDER}-credentials "${DNS_CREDENTIALS_FILE}" \
    -d "${domain}" \
    --dns-dnsmadeeasy-propagation-seconds 120 \
    --email "${email}" \
    --agree-tos \
    --non-interactive \
    --config-dir "${CERTBOT_CONFIG_DIR}" \
    --work-dir "${CERTBOT_WORK_DIR}" \
    --logs-dir "${CERTBOT_LOG_DIR}"
}

function letsencrypt.renew-ssl-certificates() {
  local domain="$1"

  certbot renew \
    --dns-${DNS_PROVIDER} \
    --dns-${DNS_PROVIDER}-credentials "${DNS_CREDENTIALS_FILE}" \
    --dns-dnsmadeeasy-propagation-seconds 120 \
    -d "${domain}" \
    --non-interactive \
    --config-dir "${CERTBOT_CONFIG_DIR}" \
    --work-dir "${CERTBOT_WORK_DIR}" \
    --logs-dir "${CERTBOT_LOG_DIR}"
}

function letsencrypt.install-dns-provider() {
  pip install --upgrade pip
  pip install certbot-dns-${DNS_PROVIDER}
}

function letsencrypt.help() {
  printf "${bldblu}USAGE: \n"
  printf "  ${txtylw}letsencrypt.ssl <action> [options]${txtrst}\n\n"

  printf "${bldblu}ACTIONs:${txtrst}\n"
  printf "  ${txtylw}obtain${txtrst} <domain> <email>        Obtain an SSL certificate for the specified domain.\n"
  printf "  ${txtylw}renew${txtrst}                          Renew all SSL certificates.\n"
  printf "  ${txtylw}install-dns-provider${txtrst}           Install the DNS provider plugin for Certbot.\n"
  printf "  ${txtylw}help${txtrst}                           Show this help message.\n\n"
  printf "${bldblu}NOTE:${txtrst}\n"
  printf "  At the momement, only the ${txtylw}${DNS_PROVIDER}${txtrst} DNS provider is supported.\n"
}

function letsencrypt.ssl() {
  set +e
  local action="$1"
  shift

  if [ -z "${action}" ]; then
    letsencrypt.help
    return 1
  fi

  letsencrypt.ensure-certbot

  [[ -f ${DNS_CREDENTIALS_FILE} ]] || {
    error "DNS credentials file not found." "Please create [${DNS_CREDENTIALS_FILE}]"
    return 1
  }

  case "${action}" in
    obtain)
      letsencrypt.obtain-ssl-certificate "$@"
      ;;
    renew)
      letsencrypt.renew-ssl-certificates "$@"
      ;;
    install-dns-provider)
      letsencrypt.install-dns-provider "$@"
      ;;
    help)
      letsencrypt.help
      return 0
      ;;
    *)
      error "Unknown action [${action}] or no action specified"
      return 1
      ;;
  esac
}

export -f letsencrypt.ssl
export -f letsencrypt.obtain-ssl-certificate
export -f letsencrypt.renew-ssl-certificates
export -f letsencrypt.install-dns-provider
export -f letsencrypt.ensure-certbot

