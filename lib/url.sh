#!/usr/bin/env bash

# Override these variables before using this library with your username/API key.
export BITLY_LOGIN
export BITLY_API_KEY

# These globals define flags used in fetching URLs.
export LibUrl__CurlDownloaderFlags="-fsSL --connect-timeout 2 --retry 2 --retry-delay 1 --retry-max-time 2"
export LibUrl__WgetDownloaderFlags="-q --connect-timeout=2 --retry-connrefused --tries 2 -O - "

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
#      export short=$(url.shorten ${long})
#
#      open ${short}  # opens in the browser
#      # => http://bit.ly/d9f02
#
url.shorten() {
  local longUrl="$1"

  error "This function used Bitly API V3 which is now defunct."
  return 1

  if [[ -z "${BITLY_LOGIN}" || -z "${BITLY_API_KEY}" ]]; then
    printf "${longUrl}"

  else
    export BITLY_LOGIN=$(printf '%s' "${BITLY_LOGIN}" | tr -d '\r' | tr -d '\n')
    export BITLY_API_KEY=$(printf '%s' "${BITLY_API_KEY}" | tr -d '\r' | tr -d '\n')

    if [[ -n $(which ruby) ]]; then
      longUrl=$(ruby -e "require 'uri'; str = '${longUrl}'.force_encoding('ASCII-8BIT'); puts URI.encode(str)")
    fi

    bitlyUrl="http://api.bit.ly/v3/shorten?login=${BITLY_LOGIN}&apiKey=${BITLY_API_KEY}&format=txt&longURL=${longUrl}"

    debug "BITLY_LOLGIN : ${clr}${bldylw}${BITLY_LOGIN}" >&2
    debug "BITLY_LOLGIN : ${clr}${bldgrn}${BITLY_API_KEY}" >&2
    debug "BITLY_API_URL: ${clr}${undblu}${bitlyUrl}${clr}" >&2

    local output="$($(url.downloader) "${bitlyUrl}" 2>&1)"
    if [[ "${output}" =~ "INVALID" || "${output}" =~ "Server Error" ]]; then
      error "${output}"
      return 1
    else
      printf "%s" "${output}" | tr -d '\n' | tr -d ' '
      return 0
    fi
  fi
}

url.downloader() {
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
url.valid-status() {
  local url="$1"

  echo "${url}" | ruby -ne '
    require "uri"
    u = URI.parse("#{$_}".chomp)
    if u && u.host && u.host&.include?(".") && u&.scheme =~ /^http/
      print "ok"
    else
      print "invalid"
    end'
}

# Returns function exit status 0 if the URL is valid.
url.is-valid() {
  local url="$1"
  if [[ $(url.valid-status "$url") = "ok" ]]; then
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
url.http-code() {
  local url="$1"
  local quiet="${2:-false}"

  [[ -z $(which wget) ]] && {
    echo >&2
    err "This function currently only supports ${bldylw}wget.\n" >&2
    echo >&2
    return 100
  }

  url.is-valid "$url" || {
    echo >&2
    err "The URL provided is not a valid URL: ${bldylw}${url}\n" >&2
    echo >&2
    return 101
  }

  local result=$(wget -v --spider "${url}" 2>&1 | ${GrepCommand} "response" | awk '{print $6}' | tr -d ' ' | tail -1)

  export LibUrl__LastHttpCode="${result}"

  if [[ ${quiet} == true ]]; then
    # if the return code between 200 and 209 we return success.
    if [[ ${result} -gt 199 && ${result} -lt 210 ]]; then
      return 0
    else
      return 1
    fi
  else
    [[ -n "${result}" ]] && printf "${result}" || printf "404"
  fi
}



# @description Returns 0 if the certificate is valid of the domain
# passed as an argument.
# @arg0 domain or a complete https url
# @return 0 if certificate is valid, other codes if not
function url.cert.is-valid() {
  local url="$1"; shift
  [[ ${url} =~ https:// ]] || url="https://${url}"
  curl -L -q -I "${url}" "$@" 1>/dev/null 2>&1
}

# @description Prints the common name for which the SSL certificate is registered
# @example 
#   ❯ url.cert.domain google.com
#   *.google.com
#
#   ❯ url.cert.domain fnf.org
#   *.wordpress.com
function url.cert.domain() {
  url.cert.info "$@" | grep 'subject: CN=' | cut -d '=' -f 2
}

# @description Returns 0 when the argument is a valid Internet host
# resolvable via DNS. Otherwise returns 255 and prints an error to STDERR.
function url.host.is-valid() {
  local host="$1"
  local host="${host/https:\/\//}"
  host "${host}" >/dev/null || {
    error "${host} does not appear to be a valid host.">&2
    return 255
  }
}

# @description Returns the SSL information about the remote certificate
function url.cert.info() {
  local url="$1"
  local quiet="${2:-false}"

  [[ ${url} =~ https:// ]] || url="https://${url}"

  url.host.is-valid "${url}" || return 1

  curl --insecure -vvI "${url}" 2>&1 | \
    awk 'BEGIN { cert=0 } 
        /^\* SSL connection/ { cert=1 } /^\*/ { if (cert) print }'
}



