#!/usr/bin/env bats
# vi: ft=sh

load test_helper

@test "git.repo-is-clean() when dirty" {
  pwd=$(pwd)
  dir="/tmp/clean/repo"
  mkdir -p $dir && cd $dir
  touch README
  echo '## README' >> README
  git init . && git add . && git commit -m 'initial commit'
  echo '### Modified' >> README
  clean=0
  export Bashmatic__Test=1
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
  export Bashmatic__Test=1
  clean=1
  set +e
  git.repo-is-clean "${dir}" && clean=0
  cd /tmp && rm -rf clean
  cd $pwd
  set -e
  [[ ${clean} -eq 0 ]]
}
