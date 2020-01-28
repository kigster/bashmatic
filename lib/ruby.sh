#!/usr/bin/env bash
# vi: ft=sh

# This function can be used to generate a YAML array of the latest minor ruby versions
# against each major version. The output should be compatible with .travis.yml format
function ruby.top-versions-as-yaml() {
  ruby.top-versions | \
     sed 's/^/ - /g'
}
function ruby.top-versions() {
  rbenv install --list | \
    egrep "^2\." | \
    ruby -e '
      last_v = nil; 
      last_m = nil; 
      ARGF.each do |line| 
        v = line.split(".")[0..1].join(".")
        if last_v != v
          puts last_m if last_m
          last_v = v; 
        end; 
        last_m = line
      end
      puts last_m if last_m'
} 

function ruby.default-gems() {
  declare -a DEFAULT_RUBY_GEMS=(
    rubocop
    relaxed-rubocop
    rubocop-performance
    warp-dir
    colored2
    sym
    pg
    pry
    pry-doc
    pry-byebug
    rspec
    rspec-its
    awesome_print
    activesupport
    pivotal_git_scripts
    git-smart
    travis
    awscli
    irbtools
  )

  export DEFAULT_RUBY_GEMS

  printf "${DEFAULT_RUBY_GEMS[*]}"
}

##——————————————————————————————————————————————————————————————————————————————————
##
##    function: ruby.rbenv
## description: Initialize rbenv
##
function ruby.rbenv() {
  if [[ -n "$*" ]]; then
    rbenv $*
  else
    eval "$(rbenv init - )"
  fi

  run "rbenv rehash"
}
##——————————————————————————————————————————————————————————————————————————————————
function ruby.installed-gems() {
  gem list | cut -d ' ' -f 1 | uniq
}

##——————————————————————————————————————————————————————————————————————————————————
function ruby.gems.install() {
  local -a gems=($@)
  gem.clear-cache
  
  [[ ${#gems[@]} -eq 0 ]] && gems=($(ruby.default-gems))
  local -a existing=($(ruby.installed-gems))

  [[ ${#gems[@]} -eq 0 ]] && {
    error 'Unable to determine what gems to install. ' \
    "Argument is empty, so is ${DEFAULT_RUBY_GEMS[@]}" \
    "USAGE: ${bldgrn}ruby.gems ${bldred} rails rubocop puma pry"
    return 1
  }

  h2 "There are a total of ${#existing[@]} of globally installed Gems." \
  "Total of ${#gems[@]} need to be installed unless they already exist. " \
  "${bldylw}Checking for gems that still missing..."

  local -a gems_to_be_installed=()

  for gem in "${gems[@]}"; do
    local gem_info=
    if [[ $(array-contains-element "${gem}" "${existing[@]}") == "true" ]]; then
      gem_info="${bldgrn} ✔  ${gem}${clr}\n"
    else
      gem_info="${bldred} x  ${gem}${clr}\n"
      gems_to_be_installed=(${gems_to_be_installed[@]} ${gem})
    fi
    printf "   ${gem_info}"
  done

  hl::subtle "It appears that only ${#gems_to_be_installed[@]} gems are left to install..."

  local -a gems_installed=()

  #lib::trap-setup
  for gem in ${gems_to_be_installed[@]}; do
    #lib::trapped && { 
    #  error "Interrupt was detected. Aborting!"
    #  exit
    #}
    run "gem install -q --force --no-document $gem"
    if [[ ${LibRun__LastExitCode} -ne 0 ]] ; then
      error "Gem ${gem} refuses to install." \
        "Perhaps try installing it manually?" \
        "${bldgrn}Action: Skip and Continuing..."
        break
    else
      gem_installed=(${gem_installed[@]} ${gem})
      continue
    fi
  done
  hr
  echo
  gem.clear-cache
  success "Total of ${#gem_installed[@]} gems were successfully installed."
  echo
}

function ruby.gems() {
  ruby.gems.install "$@"
}

function interrupted() {
  export BashMatic__Interrupted=true
}

##——————————————————————————————————————————————————————————————————————————————————
function ruby.gems.uninstall() {
  local -a gems=($@)

  gem.clear-cache

  [[ ${#gems[@]} -eq 0 ]] && declare -a gems=($(ruby.default-gems))
  local -a existing=($(ruby.installed-gems))
  [[ ${#gems[@]} -eq 0 ]] && {
    error "Unable to determine what gems to remove. Argument is empty, so is ${DEFAULT_RUBY_GEMS[@]}" \
          "USAGE: ${bldgrn}ruby.gems.uninstall ${bldred} rails rubocop puma pry"
    return 1
  }

  h1::blue "There are a total of ${#existing[@]} of gems installed in a global namespace." \
           "Total of ${#gems[@]} need to be removed."

  local deleted=0

  #lib::trap-setup
  for gem in ${gems[@]}; do
    #lib::trapped && {
    #  abort
    #  return 1
    #} 

    local gem_info=
    if [[ $(array-contains-element "${gem}" "${existing[@]}") == "true" ]]; then
      run "gem uninstall -a -x -I -D --force ${gem}"
      deleted=$(( $deleted +1 ))
    else
      gem_info="${bldred} x [not found] ${bldylw}${gem}${clr}\n"
    fi
    printf "   ${gem_info}"
  done

  gem.clear-cache
  echo
  success "Total of ${deleted} gems were successfully obliterated."
  echo
}

##——————————————————————————————————————————————————————————————————————————————————
function ruby.rubygems-update() {
  info "This might take a little white, darling. Smoke a spliff, would you?"
  run "gem update --system"
}

##——————————————————————————————————————————————————————————————————————————————————
function ruby.kigs-gems() {
  if [[ -z $(type wd 2>/dev/null) ]]; then
    wd install --dotfile ~/.bashrc > /dev/null
    [[ -f ~/.bash_wd ]] && source ~/.bash_wd
  fi

  sym -B ~/.bashrc

  for file in .sym.completion.bash .sym.symit.bash; do
    [[ -f ${file} ]] && next
    sym -B ~/.bashrc
    break
  done
}

function ruby.install-upgrade-bundler() {
  lib::gem::install bundler
  run "bundle --update bundler || true"   
}

##——————————————————————————————————————————————————————————————————————————————————
# initialize current ruby installation by installing required gems
function ruby.init() {
  h1 "Installing Critical Gems for Your Glove, Thanos..."

  ruby.rubygems-update
  ruby.install-upgrade-bundler
  ruby.gems.install
  ruby.kigs-gems
}

#——————————————————————————————————————————————————————————————————————————————————
lib::ruby::install-ruby-with-deps() {
  local version="$1"

  # Brew Packages we like to install.
  declare -a packages=(
  cask bash bash-completion git go haproxy htop jemalloc
  libxslt jq libiconv libzip netcat nginx  openssl pcre
  pstree p7zip rbenv redis ruby_build
  tree vim watch wget zlib
  )

  run::set-next show-output-on
  run "brew install --display-times ${packages[*]}"
}

##——————————————————————————————————————————————————————————————————————————————————
function lib::ruby::install-ruby() {
  local version="$1"
  local version_source="provided as an argument"

  if [[ -z ${version} && -f .ruby-version ]] ; then
    version="$(cat .ruby-version | tr -d '\n')"
    version_source="auto-detected from .ruby-version file"
  fi

  [[ -z ${version} ]] && {
    error "usage: ${BASH_SOURCE[*]} ruby-version" "Alternatively, create .ruby-version file"
    return 1
  }

  hl::subtle "Installing Ruby Version ${version} ${version_source}."

  lib::ruby::validate-version "${version}" || return 1

  lib::brew::install::packages rbenv ruby-build jemalloc
  eval "$(rbenv init -)"

  run "RUBY_CONFIGURE_OPTS=--with-jemalloc rbenv install -s ${version}"
  return "${LibRun__LastExitCode:-"0"}"
}

##——————————————————————————————————————————————————————————————————————————————————
function lib::ruby::validate-version() {
  local version="$1"
  local -a ruby_versions=()

  run "brew upgrade ruby-build || true"

  # Ensure that we get the very latest ruby versions
  [[ -d ~/.rbenv/plugins/ruby-build ]] && {
    run "cd ~/.rbenv/plugins/ruby-build && git reset --hard && git pull --rebase"
  }

  lib::array::from-command-output ruby_versions 'rbenv install --list | sed -E "s/\s+//g"'

  lib::array::contains-element "${version}" "${ruby_versions[@]}" || {
    error "Ruby Version provided was found by rbenv: ${bldylw}${version}"
    return 1
  }

  return 0
}

##——————————————————————————————————————————————————————————————————————————————————
function lib::ruby::gemfile-lock-version() {
  local gem=${1}

  if [[ ! -f Gemfile.lock ]]; then
    error "Can not find Gemfile.lock"
    return 1
  fi

  egrep " ${gem} \([0-9]" Gemfile.lock | sed -e 's/[\(\)]//g' | awk '{print $2}'
}

##——————————————————————————————————————————————————————————————————————————————————
function lib::ruby::bundler-version() {
  if [[ ! -f Gemfile.lock ]]; then
    error "Can not find Gemfile.lock"
    return 1
  fi
  tail -1 Gemfile.lock | hbsed 's/ //g'
}

##——————————————————————————————————————————————————————————————————————————————————
function ruby.full-version() {
  /usr/bin/env ruby --version
}

##——————————————————————————————————————————————————————————————————————————————————
function ruby.numeric-version() {
  /usr/bin/env ruby --version | sed 's/^ruby //g; s/ (.*//g'
}

# Public Interfaces
##——————————————————————————————————————————————————————————————————————————————————
function bundle.gems-with-c-extensions() {
  run::set-next show-output-on
  run "bundle show --paths | ruby -e \"STDIN.each_line {|dep| puts dep.split('/').last if File.directory?(File.join(dep.chomp, 'ext')) }\""
}

##——————————————————————————————————————————————————————————————————————————————————
function ruby.install() {
  lib::ruby::install-ruby "$@"
}

##——————————————————————————————————————————————————————————————————————————————————
function ruby.linked-libs() {
  ruby -r rbconfig -e "puts RbConfig::CONFIG['LIBS']"
}

# ...ruby.compiled-with jemalloc && echo yes
##——————————————————————————————————————————————————————————————————————————————————
function ruby.compiled-with() {
  if [[ -z "$*" ]]; then
    error "usage: ruby.compiled-with <library>"
    return 1
  fi

  ruby -r rbconfig -e "puts RbConfig::CONFIG['LIBS']" | grep -q "$*"
}

##——————————————————————————————————————————————————————————————————————————————————
function ruby.stop() {
  local regex='/[r]uby| [p]uma| [i]rb| [r]ails | [b]undle| [u]nicorn| [r]ake'
  local procs=$(ps -ef | egrep "${regex}" | egrep -v grep | awk '{print $2}' | sort | uniq | wc -l)
  [[ ${procs} -eq 0 ]] && {
    info: "No ruby processes were found."
    return 0
  }

  local -a pids=$(ps -ef | egrep "${regex}" | egrep -v grep | awk '{print $2}' | sort | uniq | tr '\n' ' -p ')

  h2 "Detected ${#pids[@]} Ruby Processes..., here is the tree:"
  printf "${txtcyn}"
  pstree ${pids[*]}
  printf "${clr}"
  hr

  printf "To abort, press Ctrl-C. To kill them all press any key.."
  press-any-key-to-continue

  ps -ef | egrep "${regex}" | egrep -v grep | awk '{print $2}' | sort | uniq | xargs kill -9
}


##——————————————————————————————————————————————————————————————————————————————————
alias b="bundle exec"
alias brake="rbenv exec bundl exec rake"
alias bcap="rbenv exec bundle exec cap"
##——————————————————————————————————————————————————————————————————————————————————

