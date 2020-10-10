#!/usr/bin/env bats
# vi: ft=sh

load test_helper

source lib/git.sh

git config --global user.email "kigster@gmail.com"
git config --global user.name "Konstantin Gredeskoul"

@test "git.repo-is-clean() when dirty" {
  pwd=$(pwd)
  dir="/tmp/clean/repo"
  mkdir -p $dir && cd $dir
  touch README
  echo '## README' >> README
  git init . && git add . && git commit -m 'initial commit'
  echo '### Modified' >> README
  clean=0
  export _bashmatic__test=1
  set +e
  git.repo-is-clean "${dir}" || clean=1
  cd /tmp && rm -rf clean
  cd $pwd
  set -e
  [[ ${clean} == 1 ]]
}

@test "git.repo-is-clean() when clean" {
  pwd=$(pwd)
  dir="/tmp/clean/repo"
  mkdir -p $dir && cd $dir
  touch README
  echo '## README' >> README
  git init . && git add . && git commit -m 'initial commit'
  export _bashmatic__test=1
  clean=1
  set +e
  git.repo-is-clean "${dir}" && clean=0
  cd /tmp && rm -rf clean
  cd $pwd
  set -e
  [[ ${clean} -eq 0 ]]
}
