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
