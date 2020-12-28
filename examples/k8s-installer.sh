#!/usr/bin/env bash
# vim ft=sh
#
# BASHMATIC EXAMPLES
#
# Kuberneties & Minikube downloader and installer.

[[ -d ${BASHMATIC_HOME} ]] || bash -c "$(curl -fsSL https://bashmatic.re1.re); bashmatic-install -v"
[[ -f ${BASHMATIC_HOME}/init.sh ]] || {
  echo "Can't find or install Bashmatic. Exiting."
  exit 1
}

source ${BASHMATIC_HOME}/init.sh

bashmatic.bash.exit-unless-version-four-or-later

k8s.ensure-no-brew() {
  local package="$1"

  [[ $(brew.package.is-installed "${package}") == "false" ]]
}

main() {
  local kubectl_version="$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"
  local -A binaries=()

  # To install additional binaries, add them to the associative array
  binaries[kubectl]="https://storage.googleapis.com/kubernetes-release/release/${kubectl_version}/bin/darwin/amd64/kubectl"
  binaries[minikube]="https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64"

  h2 "This script downloads and installs several executables, such as: ${!binaries[*]}" \
    "Binaries are downloaded into the /tmp folder" \
    "${bldylw}Press any key to continue, or Ctrl-C to abort."

  run.ui.press-any-key

  # Print = lines...

  local install_dir="/usr/local/bin"
  local current_dir=$(pwd -P)
  trap "cd ${current_dir}" EXIT
  local package_count=0

  for binary in "${!binaries[@]}"; do
    local temp_binary="/tmp/${binary}"
    hl.subtle Setting up ${binary}...

    k8s.ensure-no-brew "${binary}" || {
      error "It appears you have ${binary} already installed via Homebrew."
      info "Please uninstall it first, and re-run this script."
      return 1
    }

    local url=${binaries[${binary}]}

    [[ -x ${binary} ]] || run "curl -L ${url} -o ${temp_binary}"

    [[ -f ${temp_binary} ]] && run "chmod 755 ${temp_binary}"

    # let's compare them
    if [[ -f ${install_dir}/${binary} ]]; then
      diff ${temp_binary} ${install_dir}/${binary} >/dev/null && {
        info "Destination file ${bldylw}${install_dir}/${binary} is identical, skipping."
        continue
      }
    fi

    run "[[ -f ${install_dir}/${binary} ]] && mv ${install_dir}/${binary} ${install_dir}/${binary}.backup.$(time.now.db) || true"
    run "mv ${temp_binary} ${install_dir}/${binary}"

    # Let's validate they work
    # In this case we rely on the fact that running -h with each command produces
    # "<command> --help" string in the output

    hr

    set -e
    echo
    inf "verifying ${binary} is valid..."

    ${install_dir}/${binary} -h 2>&1 | grep -q "<command> --help" || {
      not-ok:
      error "It appears ${binary} did not get installed properly."
      exit 1
    }
    
    ok:
    echo; echo
    package_count=$(( package_count + 1 ))
  done

  success "Install successful, ${package_count} binaries were installed in ${install_dir}..."
}

main "$@"


