#!/usr/local/env bash

github.org() {
  local namespace="$1"

  if [[ -z ${namespace} ]]; then
    git config --global --get user.github
  else
    git config --global --unset user.github
    git config --global --add user.github "${namespace}"
  fi
}

github.setup() {
  local namespace="$(github.org)"
  if [[ -z "${namespace}" ]]; then
    unset GITHUB_ORG
    run.ui.ask-user-value GITHUB_ORG "Please enter the name of your Github Organization:" || return 1
    github.org "${GITHUB_ORG}"
    echo
    h2 "Your github organization was saved in your ~/.gitconfig file." \
      "To change it in the future, run: ${bldylw}github.org ${blgrn}new-organization"
    echo
  fi

  # return the exit code of this function
  github.org >/dev/null
}

github.validate() {
  inf "Validating Github Configuration..."
  if github.org >/dev/null; then
    ok:
    return 0
  else
    not-ok:
    github.setup
    return $?
  fi
}

github.clone() {
  test -n "$1" && github.validate && run "git clone git@github.com:$(github.org)/$1"
}


