#!/usr/bin/env bash

# Override these variables before using this library with your username/API key.
export BITLY_LOGIN
export BITLY_API_KEY

# These globals define flags used in fetching URLs.
export LibUrl__CurlDownloaderFlags="-fsSL --connect-timeout 5 --retry-delay 10 --retry-max-time 300 --retry 15 "
export LibUrl__WgetDownloaderFlags="-q --connect-timeout=5 --retry-connrefused --tries 15 -O - "


# Description:
#      If BITLY_LOGIN and BITLY_API_KEY are set, shortens the URL using Bitly.
#      Otherwise, prints the original URL.
#
# Usage:
#
#      export BITLY_LOGIN=awesome-user
#      export BITLY_API_KEY=F_09097907778FFFDFDFKFGLASKKLJ
#      export long="https://s3-us-west-2.amazonaws.com/mybucket/long/very-long-url/2018-08-01.sweet.sweet.donut.right.about.now.html"
#
#      export short=$(lib::url::shorten ${long})
#
#      open ${short}  # opens in the browser
#      # => http://bit.ly/d9f02
#
lib::url::shorten() {
  local longUrl="$1"

  if [[ -z "${BITLY_LOGIN}" || -z "${BITLY_API_KEY}" ]]; then
    printf "${longUrl}"

  else
    export BITLY_LOGIN=$(printf '%s' "${BITLY_LOGIN}" | tr -d '\r' | tr -d '\n')
    export BITLY_API_KEY=$(printf '%s' "${BITLY_API_KEY}" | tr -d '\r' | tr -d '\n')

    if [[ -n $(which ruby) ]]; then
      longUrl=$(ruby -e "require 'uri'; str = '${longUrl}'.force_encoding('ASCII-8BIT'); puts URI::encode(str)")
    fi

    #[[ -n ${DEBUG} ]] && echo "BITLY_LOLGIN: ${BITLY_LOGIN}" | cat -vet  
    #[[ -n ${DEBUG} ]] && echo "BITLY_LOLGIN: ${BITLY_API_KEY}" | cat -vet  

    bitlyUrl="http://api.bit.ly/v3/shorten?login=${BITLY_LOGIN}&apiKey=${BITLY_API_KEY}&format=txt&longURL=${longUrl}"

    #[[ -n ${DEBUG} ]] && debug "BitlyAPI URL is:\n${bitlyUrl}\n"

    $(lib::url::downloader) "${bitlyUrl}" | tr -d '\n' | tr -d ' '
  fi
}

lib::url::downloader() {
  local downloader=

  if [[ -z "${LibUrl__Downloader}" ]]; then

    [[ -z "${downloader}" && -n $(which curl) ]] && downloader="$(which curl) ${LibUrl__CurlDownloaderFlags}"
    [[ -z "${downloader}" && -n $(which wget) ]] && downloader="$(which wget) ${LibUrl__WgetDownloaderFlags}"
    [[ -z "${downloader}" ]] && {
      error "Neither Curl nor WGet appear in the \$PATH... HALP?"
      return 1
    }

    export LibUrl__Downloader="${downloader}"
  fi

  printf "${LibUrl__Downloader}"
}
