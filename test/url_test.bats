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
  local code=$(url.http-code https://google.com)
  [[ ${code} == 200 ]]
}

@test "url.http-code() with a valid url but non-existant page" {
  source lib/url.sh
  local code=$(url.http-code https://google.com/asdfasldkfjasldkjf)
  [[ ${code} == 404 ]]
}

@test "url.http-code() with an invalid URL" {
  source lib/url.sh
  local code=$(url.http-code zhopa-egorovna 2>&1)
  [[ ${code} =~ 'The URL provided is not a valid URL' ]]
}
