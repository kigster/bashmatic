#!/usr/bin/env bats
load test_helper

@test "lib::url::downloader()" {
  source lib/url.sh
  local curl_path=$(which curl)
  local wget_path=$(which wget)
  if [[ -n ${curl_path} ]]; then
    [[ "$(lib::url::downloader)" =~ "${curl_path}" ]]
  elif [[ -n ${wget_path}  ]]; then
    [[ "$(lib::url::downloader)" =~ "${wget_path}" ]]
  else
    false
  fi
}

@test "lib::url::http-code() with a valid url" {
  source lib/url.sh
  local code=$(lib::url::http-code https://google.com)
  [[ ${code} == 200 ]]
}

@test "lib::url::http-code() with a valid url but non-existant page" {
  source lib/url.sh
  local code=$(lib::url::http-code https://google.com/asdfasldkfjasldkjf)
  [[ ${code} == 404 ]]
}

@test "lib::url::http-code() with an invalid URL" {
  source lib/url.sh
  local code=$(lib::url::http-code zhopa-egorovna 2>&1)
  [[ ${code} =~ 'The URL provided is not a valid URL' ]]
}
