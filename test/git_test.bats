#!/usr/bin/env bats
# vi: ft=sh

load test_helper

source lib/user.sh
source lib/output.sh
source lib/is.sh
source lib/bashmatic.sh
source lib/git.sh

@test "git.repo-is-clean() when dirty" {
  git.config.kigster 2>/dev/null
  pwd=$(pwd)
  dir="/tmp/clean/repo"
  mkdir -p $dir && cd $dir
  touch README
  echo '## README' >> README
  git init . && git add . && git commit -m 'initial commit'
  echo '### Modified' >> README
  clean=0
  export LibGit__ForceUpdate=1
  export Bashmatic__Test=1
  set +e
  git.repo-is-clean "${dir}" || clean=1
  cd /tmp && rm -rf clean
  cd $pwd
  set -e
  [[ ${clean} == 1 ]]
}

@test "git.repo-is-clean() when clean" {
  git.config.kigster 2>/dev/null
  pwd=$(pwd)
  dir="/tmp/clean/repo"
  mkdir -p $dir && cd $dir
  touch README
  echo '## README' >> README
  git init . && git add . && git commit -m 'initial commit'
  export Bashmatic__Test=1
  export LibGit__ForceUpdate=1
  clean=1
  set +e
  git.repo-is-clean "${dir}" && clean=0
  cd /tmp && rm -rf clean
  cd $pwd
  set -e
  [[ ${clean} -eq 0 ]]
}
