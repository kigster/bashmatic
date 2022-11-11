#!/usr/bin/env bash
# vi: ft=sh

export RUBY_CONFIGURE_OPTS="${RUBY_CONFIGURE_OPTS:-""}"

ruby.ensure-rbenv() {
  [[ -n $(command -v rbenv) ]] && return 0

  brew.install
  brew.install.package rbenv ruby-build

  grep -q "rbenv init" ~/.bash_profile && echo 'eval "$(rbenv init -)"' >>~/.bash_profile

  [[ -n $(command -V rbenv) ]] && return 0

  return 1
}

ruby.ensure-rbenv-or-complain() {
  ruby.ensure-rbenv || {
    error "Can't install rbenv via HomeBrew, please try manually."
    return 1
  }
  return 0
}

# This function can be used to generate a YAML array of the latest minor ruby versions
# against each major version. The output should be compatible with .travis.yml format
ruby.top-versions-as-yaml() {
  ruby.top-versions | sed 's/^/ - /g'
}

.ruby.ruby-build-updated() {
  ruby.ensure-rbenv-or-complain || return 1

  rbenv install --version | awk '{ if($2 >= 20200518) exit(0); else exit(1); }'
}

.ruby.ruby-build.list-argument() {
  local arg="--list"
  if .ruby.ruby-build-updated; then
    arg="--list-all"
  fi
  printf -- '%s' "${arg}"
}

# shellcheck disable=SC2120
# Usage: ruby.top-versions [ platform ]
#    eg: ruby.top-versions
#    eg: ruby.top-versions jruby
#    eg: ruby.top-versions rbx
ruby.top-versions() {
  local platform="${1}"
  local arg="$(.ruby.ruby-build.list-argument)"
  local filter="cat"
  [[ -n ${platform} ]] && filter="grep -E '^${platform}'"

  eval "rbenv install ${arg}" | \
    eval "${filter}" | \
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

ruby.default-gems() {
  declare -a DEFAULT_RUBY_GEMS=(
    bundler
    rubocop
    relaxed-rubocop
    rubocop-performance
    warp-dir
    colored2
    sym
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
    kramdown-asciidoc
    asciidoctor
    kramdown
    gemsmith
    rspec
    rspec-its
  )

  export DEFAULT_RUBY_GEMS

  printf "${DEFAULT_RUBY_GEMS[*]}"
}

ruby.handle-missing() {
  command -v ruby >/dev/null || {
    info "Couldn't find Ruby, installing it..." >&2
    ruby.install-ruby "$(ruby.numeric-version)"
  }

  command -v ruby >/dev/null
}

##——————————————————————————————————————————————————————————————————————————————————
##
##    function: ruby.rbenv
## description: Initialize rbenv
##
ruby.rbenv() {
  ruby.ensure-rbenv-or-complain || return 1
  if [[ -n "$*" ]]; then
    rbenv "$*"
  else
    eval "$(rbenv init -)"
  fi

  run "rbenv rehash"
}
##——————————————————————————————————————————————————————————————————————————————————
ruby.installed-gems() {
  gem list | cut -d ' ' -f 1 | uniq
}

##——————————————————————————————————————————————————————————————————————————————————
ruby.gems.install() {
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
    if [[ $(array.has-element "${gem}" "${existing[@]}") == "true" ]]; then
      gem_info="${bldgrn} ✔  ${gem}${clr}\n"
    else
      gem_info="${bldred} x  ${gem}${clr}\n"
      gems_to_be_installed+=("${gem}")
    fi
    printf "   ${gem_info}"
  done

  if [[ ${#gems_to_be_installed[@]} -eq 0 ]]; then
    info "All gems are already installed. 👍🏼"
    return 0
  fi

  info "Looks like ${#gems_to_be_installed[@]} gems are left to install..."

  local -a gem_installed

  #trap-setup
  for gem in "${gems_to_be_installed[@]}"; do
    #trapped && {
    #  error "Interrupt was detected. Aborting!"
    #  exit
    #}
    run "gem install -q --force --no-document $gem"
    if [[ ${LibRun__LastExitCode} -ne 0 ]]; then
      error "Gem ${gem} refuses to install." \
        "Perhaps try installing it manually?" \
        "${bldgrn}Action: Skip and Continuing..."
      break
    else
      gem_installed+=("${gem}")
      continue
    fi
  done
  gem.clear-cache
  info "Total of ${#gem_installed[@]} gems were installed."
  echo
}

ruby.gems() {
  ruby.gems.install "$@"
}

interrupted() {
  export BashMatic__Interrupted=true
}

##——————————————————————————————————————————————————————————————————————————————————
ruby.gems.uninstall() {
  local -a gems
  gems=("$@")

  gem.clear-cache

  [[ ${#gems[@]} -eq 0 ]] && declare -a gems=($(ruby.default-gems))
  local -a existing=($(ruby.installed-gems))
  [[ ${#gems[@]} -eq 0 ]] && {
    error "Unable to determine what gems to remove. Argument is empty, so is ${DEFAULT_RUBY_GEMS[@]}" \
      "USAGE: ${bldgrn}ruby.gems.uninstall ${bldred} rails rubocop puma pry"
    return 1
  }

  h1.blue "There are a total of ${#existing[@]} of gems installed in a global namespace." \
    "Total of ${#gems[@]} need to be removed."

  local deleted=0

  #trap-setup
  for gem in "${gems[@]}"; do
    #trapped && {
    #  abort
    #  return 1
    #}

    local gem_info=
    if [[ $(array.has-element "${gem}" "${existing[@]}") == "true" ]]; then
      run "gem uninstall -a -x -I -D --force ${gem}"
      deleted=$((deleted + 1))
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
ruby.rubygems-update() {
  info "Updating RubyGems..."
  run.set-next show-output-on
  run "gem update --system -N"
  gem.clear-cache
}

##——————————————————————————————————————————————————————————————————————————————————
ruby.kigs-gems() {
  if [[ -z $(type wd 2>/dev/null) && -n $(command -v warp-dir) ]]; then
    [[ -f ~/.bash_wd ]] || {
      warp-dir install --dotfile ~/.bashrc >/dev/null
      source ~/.bash_wd
    }
  fi

  [[ -n $(command -v sym) ]] && {
    [[ -f ~/.sym.completion.bash ]] || {
      sym -B ~/.bashrc
    }
  }
}

ruby.install-upgrade-bundler() {
  gem.install bundler
  run "bundle --update bundler || true"
}

##——————————————————————————————————————————————————————————————————————————————————
# initialize current ruby installation by installing required gems
ruby.init() {
  h1 "Installing Critical Gems for Your Glove, Thanos..."

  ruby.rubygems-update
  ruby.install-upgrade-bundler
  ruby.gems.install
  ruby.kigs-gems
}

#——————————————————————————————————————————————————————————————————————————————————
ruby.install-ruby-with-deps() {
  local version="$1"

  # Brew Packages we like to install.
  declare -a packages=(
    cask bash bash-completion git go haproxy htop jemalloc
    libxslt jq libiconv libzip netcat nginx openssl pcre
    pstree p7zip rbenv redis ruby_build readline
    tree vim watch wget zlib
  )

  run.set-next show-output-on
  run "brew install --display-times ${packages[*]}"
}

ruby.install-ruby-with-readline-and-openssl() {
  local version="$1"
  [[ -z ${version} ]] && {
    error "usage: ruby.install-ruby-with-readline-and-openssl ruby-version"
    return 1
  }
  shift
  ruby.install-ruby "${version}" openssl readline "$@"
}

##—————————————————————————————————————————————————————————————
# usage: ruby.install-ruby RUBY_VERSION
ruby.install-ruby() {
  local version="$1"
  shift
  local version_source="provided as an argument"
  if [[ -z ${version} && -f .ruby-version ]]; then
    version="$(cat .ruby-version | tr -d '\n')"
    version_source="auto-detected from .ruby-version file"
  fi

  [[ -z ${version} ]] && {
    error "USAGE: ruby.install-ruby VERSION" \
      "Or, you can create a local .ruby-version file"
    return 1
  }

  local -a required_packages
  required_packages=(rbenv ruby-build)

  h3 "Installing Ruby Version ${bldpur}${version} ${bldblu}${version_source}."

  ruby.validate-version "${version}" || return 1
  brew.install.packages "${required_packages[@]}"
  brew.upgrade.packages "${required_packages[@]}"

  if [[ -n "$*" ]]; then
    info "Attemping to install additional packages via Brew:"

    for package in "$@"; do
      run.set-next abort-on-error
      brew.install.package "${package}"

      local func=".ruby.configure-with.${package}"
      util.is-a-function "${func}" && ${func}
    done
  fi

  eval "$(rbenv init -)"
  h2 "RUBY_CONFIGURE_OPTS: ${bldgrn}${RUBY_CONFIGURE_OPTS}"
  run "RUBY_CONFIGURE_OPTS=\"${RUBY_CONFIGURE_OPTS}\" rbenv install -s ${version}"

  return "${LibRun__LastExitCode:-"0"}"
}

# Configures Ruby with jemalloc
.ruby.configure-with.jemalloc() {
  export RUBY_CONFIGURE_OPTS="--with-jemalloc ${RUBY_CONFIGURE_OPTS}"
}

# Configures Ruby with readline
.ruby.configure-with.readline() {
  export RUBY_CONFIGURE_OPTS="--with-readline-dir=$(brew --prefix readline) ${RUBY_CONFIGURE_OPTS}"
}

# Configures Ruby with openssl
.ruby.configure-with.openssl() {
  export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl) ${RUBY_CONFIGURE_OPTS}"
}

##————————————————————————————————————————————————————————————————
ruby.validate-version() {
  local version="$1"
  local -a ruby_versions=()

  run "brew upgrade ruby-build || true"

  # Ensure that we get the very latest ruby versions
  [[ -d ~/.rbenv/plugins/ruby-build ]] && {
    run "cd ~/.rbenv/plugins/ruby-build && git reset --hard && git pull --rebase"
  }

  local arg="$(.ruby.ruby-build.list-argument)"
  array.from.command ruby_versions "rbenv install ${arg}"

  inf "Validating ruby version: ${version}"

  array.includes "${version}" "${ruby_versions[@]}" || {
    not-ok:
    error "Ruby Version provided was NOT found by rbenv: ${bldylw}${version}" "Found a total of ${bldgrn}${#ruby_versions[*]} ruby versions."
    return 1
  }

  ok:

  return 0
}

##——————————————————————————————————————————————————————————————————————————————————
ruby.gemfile-lock-version() {
  local gem=${1}

  if [[ ! -f Gemfile.lock ]]; then
    error "Can not find Gemfile.lock"
    return 1
  fi

  ${GrepCommand} " ${gem} \([0-9]" Gemfile.lock | sed -e 's/[\(\)]//g' | awk '{print $2}'
}

##——————————————————————————————————————————————————————————————————————————————————

ruby.bundle-install() {
  if [[ -f Gemfile.lock ]]; then
    run "bundle install"
  fi
}

##——————————————————————————————————————————————————————————————————————————————————
ruby.bundler-version() {
  if [[ ! -f Gemfile.lock ]]; then
    error "Can not find Gemfile.lock"
    return 1
  fi
  tail -1 Gemfile.lock | sedx 's/ //g'
}

##——————————————————————————————————————————————————————————————————————————————————
ruby.full-version() {
  /usr/bin/env ruby --version
}

##——————————————————————————————————————————————————————————————————————————————————
ruby.numeric-version() {
  /usr/bin/env ruby --version | sed 's/^ruby //g; s/ (.*//g'
}

# Public Interfaces
##——————————————————————————————————————————————————————————————————————————————————
bundle.gems-with-c-extensions() {
  run.set-next show-output-on
  run "bundle show --paths | ruby -e \"STDIN.each_line {|dep| puts dep.split('/').last if File.directory?(File.join(dep.chomp, 'ext')) }\""
}

##——————————————————————————————————————————————————————————————————————————————————
ruby.install() {
  ruby.install-ruby "$@"
}

##——————————————————————————————————————————————————————————————————————————————————
ruby.linked-libs() {
  ruby -r rbconfig -e "puts RbConfig.CONFIG['LIBS']"
}

# ...ruby.compiled-with jemalloc && echo yes
##——————————————————————————————————————————————————————————————————————————————————
ruby.compiled-with() {
  if [[ -z "$*" ]]; then
    error "usage: ruby.compiled-with <library>"
    return 1
  fi

  ruby -r rbconfig -e "puts RbConfig.CONFIG['LIBS']" | grep -q "$*"
}

##——————————————————————————————————————————————————————————————————————————————————
ruby.stop() {
  local regex='/[r]uby| [p]uma| [i]rb| [r]ails | [b]undle| [u]nicorn| [r]ake'
  local procs=$(ps -ef | ${GrepCommand} "${regex}" | ${GrepCommand} -v grep | awk '{print $2}' | sort | uniq | wc -l)
  [[ ${procs} -eq 0 ]] && {
    info: "No ruby processes were found."
    return 0
  }

  local -a pids=$(ps -ef | ${GrepCommand} "${regex}" | ${GrepCommand} -v grep | awk '{print $2}' | sort | uniq | tr '\n' ' -p ')

  h2 "Detected ${#pids[@]} Ruby Processes..., here is the tree:"
  printf "${txtcyn}"
  pstree "${pids[*]}"
  printf "${clr}"
  hr

  printf "To abort, press Ctrl-C. To kill them all press any key.."
  run.ui.press-any-key

  ps -ef | ${GrepCommand} "${regex}" | ${GrepCommand} -v grep | awk '{print $2}' | sort | uniq | xargs kill -9
}

ruby.aliases() {
  alias b="bundle"
  alias be="bundle exec"
  alias ber="bundle exec rake"
  alias bert="bundle exec rake -T"
  alias berr="bundle exec rspec"
  alias rdb="set -ex; bundle exec rake db:drop:all; bundle exec rake db:create:all; bundle exec rake db:migrate db:seed; bundle exec rake db:test:prepare; set +ex"
}



