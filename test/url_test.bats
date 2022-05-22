#!/usr/bin/env bats
load test_helper

@test "url.downloader()" {
  source lib/url.sh
  local curl_path=$(command -v curl)
  local wget_path=$(command -v wget)
  if [[ -n ${curl_path} ]]; then
    [[ "$(url.downloader)" =~ "${curl_path}" ]]
  elif [[ -n ${wget_path}  ]]; then
    [[ "$(url.downloader)" =~ "${wget_path}" ]]
  else
    false
  fi
}

@test "url.http-code() with a valid url" {
  source lib/url.sh
  local code=$(url.http-code https://kig.re)
  [[ ${code} == 200 ]]
}

@test "url.http-code() with a valid url but non-existant page" {
  source lib/url.sh
  local code=$(url.http-code https://kig.re/asdfasldkfjasldkjf)
  [[ ${code} == 404 ]]
}

@test "url.http-code() with an invalid URL" {
  source lib/url.sh
  local code=$(url.http-code zhopa-egorovna 2>&1)
  [[ ${code} =~ 'The URL provided is not a valid URL' ]]
}

@test "url.cert.domain with a valid domain" {
  source lib/url.sh
  local cert_domain=$(url.cert.domain google.com)
  [[ ${cert_domain} == '*.google.com' ]]
}

@test "url.cert.is-valid with a valid domain" {
  source lib/url.sh
  set -e
  url.cert.is-valid google.com
}

@test "url.cert.is-valid with an invalid domain" {
  source lib/url.sh
  set +e
  url.cert.is-valid www.makeabox.io 2>/dev/null
  code=$?
  [[ ${code} -ne 0 ]]
}

@test "url.host.is-valid with an invalid host" {
  source lib/url.sh
  set +e
  url.host.is-valid www.makeabox.io 2>/dev/null
  code=$?
  [[ ${code} -ne 0 ]]
}
