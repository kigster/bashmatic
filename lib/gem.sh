#
# GEM dependencies
#
# This extracts a gem.version from Gemfile.lock. If not found,
# default (argument) is used. This helps prevent version mismatch
# between the very few gem dependencies of the zeus subsystem, and Rails.

.gem.verify-name() {
  [[ -z "${1}" ]] && {
    error "Error — gem name is required as an argument"
    return 1
  }

  return 0
}

gem.configure-cache() {
  export LibGem__GemListCacheBase="${BASHMATIC_TEMP}/.gem/gem.list"
  export LibGem__GemListCache=
  export LibGem__GemInstallFlags=" -N --force --quiet "

  local ruby_version=$(ruby.numeric-version)

  export LibGem__GemListCache="${LibGem__GemListCacheBase}.${ruby_version}"

  local dir=$(dirname "${LibGem__GemListCache}")
  [[ -d ${dir} ]] || mkdir -p "${dir}" >/dev/null
}

gem.version() {
  local gem="$1"
  local default="$2"

  [[ -z ${gem} ]] && return

  local version

  [[ -f Gemfile.lock ]] && version=$(gem.gemfile.version "${gem}")

  if [[ -z ${version} ]]; then
    if gem.is-installed "${gem}"; then
      version=$(gem.global.latest-version "${gem}")
    else
      version=$(gem.remote.version "${gem}")
    fi
  fi

  [[ -z ${version} && -n ${default} ]] && version=${default} # fallback to the default if not found

  printf "%s" "${version}"
}

# Returns a space-separated list of installed gem versions
gem.global.versions() {
  local gem=$1
  [[ -z ${gem} ]] && return
  gem.cache-installed
  grep -E -e "^${gem} " < "${LibGem__GemListCache}" | sedx "s/^${gem} //g;s/[(),]//g"
}

gem.remote.version() {
  [[ -z "$1" ]] && return
  gem search "$1" --remote -e | sedx "s/^${1} //g; s/[(),]//g"
}

# Returns a space-separated list of installed gem versions
gem.global.latest-version() {
  local gem="$1"
  [[ -z ${gem} ]] && return

  declare -a versions=($(gem.global.versions "${gem}"))
  local max=0
  local max_version=${versions[0]}
  for v in "${versions[@]}"; do
    vi=$(util.ver-to-i "${v}")
    if [[ ${vi} -gt ${max} ]]; then
      max=${vi}
      max_version="${v}"
    fi
  done
  printf "%s" "${max_version}"
}

gem.gemfile.version() {
  local gem=$1
  local gemfile="${2:-"Gemfile.lock"}"

  [[ -z ${gem} ]] && return

  [[ -f ${gemfile} ]] || {
    error "Can't find Gemfile ${gemfile} in the current directory" >&2
    return 1
  }

  grep -E -e " ${gem} \([0-9]" "${gemfile}" | \
      awk '{print $2}' | \
      sed 's/[()]//g'
}

# this ensures the cache is only at most 30 minutes old
gem.cache-installed() {
  gem.configure-cache
  if [[ ! -f "${LibGem__GemListCache}" || ! -s "${LibGem__GemListCache}" || \
    -z "$(find "${LibGem__GemListCache}" -mmin -30 2>/dev/null)" ]]; then
    mkdir -p $(dirname ${LibGem__GemListCache})
    gem list > "${LibGem__GemListCache}" 2>/dev/null
  fi

  [[ -s "${LibGem__GemListCache}" ]]
}

gem.cache-list() {
  cat "${LibGem__GemListCache}"
}

gem.clear-cache() {
  cp /dev/null "${LibGem__GemListCache}"
}

gem.cache-refresh() {
  (
    gem.configure-cache
    gem.clear-cache
    gem.cache-installed
  ) >/dev/null
}

gem.cache-reset() {
  gem.cache-refresh
}

gem.ensure-gem-version() {
  local gem=$1
  local gem_version=$2

  [[ -z ${gem} || -z ${gem_version} ]] && return

  gem.cache-installed

  if [[ -z $(grep "${gem} (${gem_version}) < ${LibGem__GemListCache}") ]]; then
    gem.uninstall "${gem}"
    gem.install "${gem}" "${gem_version}"
  else
    info "gem ${gem} version ${gem_version} is already installed."
  fi
}

gem.is-installed() {
  local gem=$1
  local version=$2

  gem.cache-installed >/dev/null

  if [[ -z ${version} ]]; then
    grep -q -E -e "^${gem} \(" "${LibGem__GemListCache}"
  else
    grep -E -e "^${gem} \(" "${LibGem__GemListCache}" | grep -E -q -e "${version}"
  fi
}

gem.gemfile.bundler-version() {
  [[ -f Gemfile.lock ]] && grep -A2 BUNDLED Gemfile.lock | tail -1 | tr -d ' '
}

# Install the gem, but use the version argument as a default. Final version
# is determined from Gemfile.lock using the +gem.version+ above.
gem.install() {
  .gem.verify-name "$@" || return 1

  local gem_name="$1"
  local gem_version="$2"
  local gem_version_flags=
  local gem_version_name=

  gem_version=${gem_version:-$(gem.version "${gem_name}")}

  if [[ -z ${gem_version} ]]; then
    gem_version_name=latest
    gem_version_flags=
  else
    gem_version_name="${gem_version}"
    gem_version_flags="--version ${gem_version}"
  fi

  if gem.is-installed "${gem_name}" "${gem_version}"; then
    info: "gem ${bldylw}${gem_name} (${bldgrn}${gem_version_name}${bldylw})${txtblu} is already installed"
  else
    info "installing ${bldylw}${gem_name} ${bldgrn}(${gem_version_name})${txtblu}..."
    run "gem install ${gem_name} ${gem_version_flags} ${LibGem__GemInstallFlags}"
    if [[ ${LibRun__LastExitCode} -eq 0 ]]; then
      rbenv rehash >/dev/null 2>/dev/null
      gem.cache-refresh
    else
      error "Unable to install gem ${bldylw}${gem_name}"
    fi
    return "${LibRun__LastExitCode}"
  fi
}

gem.uninstall() {
  .gem.verify-name "$@" || return 1
  local gem_name=$1
  local gem_version=$2 # optional

  gem.is-installed "${gem_name}" "${gem_version}" || {
    info "gem ${bldylw}${gem_name}${txtblu} is not installed"
    return
  }

  local gem_flags="-x -I --force"
  if [[ -z ${gem_version} ]]; then
    gem_flags="${gem_flags} -a"
  else
    gem_flags="${gem_flags} --version ${gem_version}"
  fi

  run "gem uninstall ${gem_name} ${gem_flags}"
  gem.clear-cache
  return "${LibRun__LastExitCode}"
}

gem.changelog-generate() {
  local project="$1"
  [[ -z ${project} ]] && {
    error "usage: gem.changelog-generate username/repo"
    return 1
  }

  local user
  local repo
  user="${project/\/*/}"
  repo="${project/*\//}"

  gem.install github_changelog_generator

  [[ -z  ${GITHUB_TOKEN} ]] && {
    error "Please set GITHUB_TOKEN to avoid hitting 50 reqs/minute API limit."
    exit 1
  }

  run "github_changelog_generator --project ${repo} --user ${user} -t ${GITHUB_TOKEN} --no-verbose"
  ls -al CHANGELOG.md
}

## Shortcuts

g-i() {
  gem.install "$@"
}

g-u() {
  gem.uninstall "$@"
}


