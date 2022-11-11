#!/usr/bin/env bash

sym.dev.install-shell-helpers() {
  local found=
  declare -a init_files=($(util.shell-init-files))

  for file in "${init_files[@]}"; do
    f="${file}"
    [[ ! -f "${f}" ]] && continue
    [[ -n $(grep sym.symit "${f}") ]] && {
      found=${f}
      break
    }
  done

  if [[ -z ${found} ]]; then
    for file in "${init_files[@]}"; do
      f="${file}"
      if [[ -f "${f}" ]]; then
        run "sym -B ${f} 1>/dev/null"
        return $?
      fi
    done
  else
    run "sym -B ${found} 1>/dev/null"
  fi
}

sym.install.symit() {

  if [[ ! -f config.ru ]]; then
    error "Please run this command from the RAILS_ROOT folder"
    return 1
  fi

  [[ -n "$(which sym 2>/dev/null)" && -f ~/.sym.symit.bash ]] && return

  local symit_source="/tmp/sym.symit.bash.$$"

  trap "rm -f ${symit__source}; " EXIT

  local symit_url="https://raw.githubusercontent.com/kigster/sym/master/bin/sym.symit.bash"
  local cmd="curl -fsSL ${symit_url} -o ${symit_source}"
  export LibRun__AbortOnError=${True}
  run "${cmd}"
  if [[ ! -f ${symit_source} ]]; then
    err "unable to find downloaded file ${symit_source}"
    return 1
  fi

  source ${symit_source}
  rm -f ${symit_source}

  # This ensures we are on the latest version of Sym
  run "symit install"
  # This next line ensures we have Sym bash helpers installed.
  sym.dev.install-shell-helpers
}

sym.dev.configure() {
  export SYMIT__KEY="APP_SYM_KEY"
}

sym.dev.have-key() {
  sym.dev.configure

  if [[ -z ${CI} ]]; then
    [[ -z "$(keychain ${SYMIT__KEY} find 2>/dev/null)" ]] || printf "yes"
  else
    [[ -n "${APP_SYM_KEY}" ]] && print "yes"
  fi
}

__pause() {
  local skip_sleep=${1:-0}
  local sleep_duration=${2:-2}
  ((${skip_sleep})) || sleep "${sleep_duration}"
}

sym.dev.import() {
  local skip_instructions=${1:-0}

  if [[ ${BASHMATIC_OS} != 'darwin' ]]; then
    error 'This is only meant to run on Mac OS-X'
    return
  fi

  sym.dev.configure
  sym.install.symit

  [[ -f ~/.sym.symit.bash ]] && source ~/.sym.symit.bash

  h2 'Encryption Key Import'

  info "Checking for the existence of the current key..."

  if [[ -n "$(sym.dev.have-key)" ]]; then
    info: "Key ${SYMIT_KEY} is already in you your OS-X Key Chain."
    run.ui.ask "Would you like to re-import it?"
    [[ $? != 0 ]] && return
  fi

  if [[ ${skip_instructions} == ${false} ]]; then
    hr
    echo
    info "1. Please open 1Password App and search for 'Encryption Key'"
    echo
    info "2. Once you find the entry, it will contain two items: encryption key"
    info "      and password. Start by copying the key to the clipboard."
    echo
    info "3. You will need to paste the key first, and then copy/paste"
    info "      the key password (also in 1Password)"
    echo
    info "4. As a final setup, you will be asked to create a new password."
    info "      It must be at least 7 characters long, and will be used to encrypt"
    info "      the key locally on your machine."
    echo
    echo

    run.ui.ask "Ready?"
    [[ $? != 0 ]] && return
  fi

  echo
  hr

  sym -iqpx APP_SYM_KEY
  code=$?

  [[ ${code} != 0 ]] && {
    error "Sym exited with error code ${code}"
    return ${code}
  }
  hr
  echo
  info "Key import was successful, great job! ${bldylw}☺ "
  info "You can test that it works by encrypting, and decrypting a string,"
  echo
  info "\$ ${bldylw}source bin/bash"
  info "\$ ${bldylw}dev.encrypt.str hello"
  info "\$ ${bldylw}dev.decrypt.str \$(dev.encrypt.str hello )"
  echo
  info "Or a file:"
  info "\$ ${bldylw}dev.decrypt.file config/application.dev.yml.enc"
  echo
  info "You can edit the file as if it wasn't encrypted:"
  info "\$ ${bldylw}dev.edit.file config/application.dev.yml.enc"
  echo
}

sym.dev.files() {
  find . -name '*.enc' -type f
}

# Runs sym and prepends the key name for Chef
dev.crypt.chef() {
  sym -ck APP_CHEF_SYM_KEY "$*"
}

# Runs sym and prepends the key name for the App
# To use: eg, to encrypt a file:
#
#     sym.sym -e -f file.txt -o file.enc
#
dev.sym() {
  sym -cqk APP_SYM_KEY "$*"
}

dev.encrypt.str() {
  [[ -z "${1}" ]] && {
    error 'usage: dev.encrypt.str "string to encrypt"'
    return
  }
  sym -ck APP_SYM_KEY -e -s "$*"
}

dev.decrypt.str() {
  [[ -z ${1} ]] && {
    error 'usage: dev.decrypt.str "string to decrypt"'
    return
  }
  sym -ck APP_SYM_KEY -d -s "$*"
}

dev.encrypt.file() {
  [[ -f ${1} ]] || {
    error 'usage: dev.encrypt.file <filename>'
    return
  }
  sym -ck APP_SYM_KEY -e -f "${1}" -o "${1}.enc"
}

dev.edit.file() {
  [[ -f ${1} ]] || {
    error 'usage: dev.edit.file <filename>'
    return
  }
  sym -ck APP_SYM_KEY -t "${1}"
}

dev.decrypt.file() {
  [[ -f ${1} ]] || {
    error 'usage: dev.decrypt.file <filename.enc>'
    return
  }
  sym -ck APP_SYM_KEY -n "${1}"
}

decrypt.secrets() {
  ./bin/decrypt

  local code=$?
  [[ ${code} != 0 ]] && {
    error "bin/decrypt returned non-zero exit status ${code}"
    echo
    exit ${code}
  }
}


