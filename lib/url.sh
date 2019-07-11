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

# Returns 'ok' or 'invalid' based on the URL
lib::url::valid-status() {
  local url="$1"

  echo "${url}" | ruby -ne '
    require "uri"
    u = URI::parse("#{$_}".chomp)
    if u && u.host && u.host&.include?(".") && u&.scheme =~ /^http/
      print "ok"
    else
      print "invalid"
    end'
}

# Returns function exit status 0 if the URL is valid.
lib::url::is-valid() {
  local url="$1"
  if [[ $(lib::url::valid-status "$url") = "ok" ]]; then
    return 0
  else
    return 1
  fi
}

# Returns HTTP code when attempting to fetch the URL.
# If the URL does not parse, prints error and returns a non-zero status.
#
# Finally, sets a global variable LibUrl__LastHttpCode to the
# HTTP code received.
#
# If the second argument is +true+, intead of printing the code to
# the STDOUT, function silently exits eith with 0 (200+) or 1 (other.)
lib::url::http-code() {
  local url="$1"
  local quiet="${2:-false}"

  [[ -z $(which wget) ]] && {
    echo >&2
    err "This function currently only supports ${bldylw}wget.\n" >&2
    echo >&2
    return 100
  }

  lib::url::is-valid "$url" || {
    echo >&2
    err "The URL provided is not a valid URL: ${bldylw}${url}\n" >&2
    echo >&2
    return 101
  }

  local result=$(wget -v --spider "${url}" 2>&1 | egrep "response" | awk '{print $6}' | tr -d ' ' | tail -1)

  export LibUrl__LastHttpCode="${result}"

  if [[ ${quiet} == true ]]; then
    # if the return code between 200 and 209 we return success.
    if [[ ${result} -gt 199 && ${result} -lt 210 ]]; then
       return 0
     else
       return 1
     fi
  else
    [[ -n "${result}" ]] && printf ${result} || printf "404"
  fi
}
