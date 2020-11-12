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


main() {
  local kubectl_version="$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"
  local -A binaries=()

  # To install additional binaries, add them to the associative array
  binaries[kubectl]="https://storage.googleapis.com/kubernetes-release/release/${kubectl_version}/bin/darwin/amd64/kubectl"
  binaries[minikube]="https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64"

  h2 "This script downloads and installs several executables, such as: ${!binaries[*]}" \
    "Binaries are downloaded into the current folder." \
    "${bldylw}Press any key to continue, or Ctrl-C to abort."

  run.ui.press-any-key

  # Print = lines...

  local install_dir="/usr/local/bin"
  local current_dir=$(pwd -P)
  trap "cd ${current_dir}" EXIT

  for binary in "${!binaries[@]}"; do
    hl.subtle Setting up ${binary}...

    k8s.ensure-no-brew "${binary}" || {
      error "It appears you have ${binary} already installed via Homebrew."
      info "Please uninstall it first, and re-run this script."
      return 1
    }

    local url=${binaries[${binary}]}

    [[ -x ${binary} ]] || run "curl -Lo ${binary} ${url}"
    [[ -f ${binary} ]] && run "chmod +x ${binary}"

    info "Symlinking ${binary} in ${bldylw}${install_dir}..."

    run "rm -f ${install_dir}/${binary}"
    cd "${install_dir}" || return 1

    run "ln -nfs ${current_dir}/${binary} ${binary}"

    inf "verifying ${bldylw}${install_dir}/${binary}..."

    if [[ $(find ${install_dir} -name ${binary}) == "${install_dir}/${binary}" ]]; then
      ok:
    else
      not-ok:
      error "${binary} is found in an unexpected location: ${bldwht}$(command -v ${binary})."
      return 1
    fi
    run "cd ${current_dir}>/dev/null"
    hr
  done

  success "Install successful."
}

main "$@"
