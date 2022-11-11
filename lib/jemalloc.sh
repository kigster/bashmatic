#!/usr/bin/env bash

export ColorRed="\e[1;31m"
export ColorGreen="\e[1;32m"
export ColorYellow="\e[1;33m"
export ColorBlue="\e[1;34m"
export ColorReset="\e[0m"

# prints the info about current version of ruby
jm.ruby.report() {
  printf "Ruby version being tested:\n  →  ${ColorBlue}$(which ruby) ${ColorYellow}$(jm.ruby.detect)${ColorReset}\n"
}

# returns a string such as "/usr/local/bin/ruby 2.6.4 (x86darwin)"
jm.ruby.detect() {
  local ruby_loc
  if [[ -n $(which rbenv) ]]; then
    ruby_loc=$(rbenv versions | grep '*' | awk '{print $2}')
    [[ -n ${ruby_loc} ]] && ruby_loc="(rbenv) ${ruby_loc}"
  else
    ruby_loc="$(which ruby) $(ruby -e 'puts "#{RUBY_VERSION} (#{RUBY_PLATFORM})"')"
  fi

  printf "%s" "${ruby_loc}"
}

# prints jemalloc statistics if jemalloc is available
jm.jemalloc.stats() {
  jm.jemalloc.detect-quiet || {
    printf "No Jemalloc was found for the curent ruby $(jm.ruby.detect)\n"
    return 1
  }

  MALLOC_CONF=stats_print:true ruby -e "exit" 2>&1 | less -S
}

jm.jemalloc.detect-quiet() {
  MALLOC_CONF=stats_print:true ruby -e "exit" 2>&1 | grep -q "jemalloc statistics"
  return $?
}

jm.jemalloc.detect-loud() {
  jm.jemalloc.detect-quiet

  local code=$?
  local local_ruby=$(jm.ruby.detect)

  printf "${ColorBlue}Checking if ruby ${ColorYellow}${local_ruby}${ColorBlue} is linked with jemalloc... \n\n "
  if [[ ${code} -eq 0 ]]; then
    printf " ✅ ${ColorGreen} — jemalloc was detected.\n"
  else
    printf " 🚫 ${ColorRed} — jemalloc was not detected.\n"
  fi
  printf "${ColorReset}\n"
  return ${code}
}

jm.usage() {
  printf "
${ColorBlue}USAGE:${ColorReset}
  $(basename "$0") [ -q/--quiet ]
                 [ -r/--ruby  ]
                 [ -s/--stats ]
                 [ -h/--help  ]

${ColorBlue}DESCRIPTION:${ColorReset}
  Determines whether the currently defined in the PATH ruby
  interpreter is linked with libjemalloc memory allocator.

${ColorBlue}OPTIONS${ColorReset}
  -q/--quiet        Do not print output, exit with 1 if no jemalloc
  -r/--ruby         Print which ruby is currently in the PATH
  -s/--stats        Print the jemalloc stats
  -h/--help         This page.
%s
" ""
  exit 0
}

jm.check() {
  local JM_Quiet=false
  local JM_Ruby=false
  local JM_Stats=false

  # Parse additional flags
  while :; do
    case $1 in
    -q | --quiet)
      shift
      export JM_Quiet=true
      ;;
    -r | --ruby)
      shift
      export JM_Ruby=true
      ;;
    -s | --stats)
      shift
      export JM_Stats=true
      exit $?
      ;;
    -h | -\? | --help)
      shift
      jm.usage
      exit 0
      ;;
    --) # End of all options; anything after will be passed to the action function
      shift
      break
      ;;
    *)
      break
      ;;
    esac
  done

  ${JM_Ruby} && {
    jm.ruby.report
    exit 0
  }
  ${JM_Quiet} && {
    jm.jemalloc.detect-quiet
    code=$?
    exit ${code}
  }
  ${JM_Stats} && {
    jm.jemalloc.stats
    exit 0
  }

  jm.jemalloc.detect-loud
}


