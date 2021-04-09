#!/usr/bin/env bats
# vi: ft=sh

load test_helper

source lib/user.sh
source lib/output.sh
source lib/is.sh
source lib/bashmatic.sh
source lib/git.sh
source lib/util.sh

set -e

@test "git.repo.latest-local-tag regex" {
  tag=$(git.repo.latest-local-tag)
  [[ ${tag} =~ ^v[0-9]+.[0-9]+.[0-9]+$  ]] 
}

@test "git.repo.next-local-tag regex" {
  ntag=$(git.repo.next-local-tag)
  [[ ${ntag} =~ ^v[0-9]+.[0-9]+.[0-9]+$  ]] 
}

@test "git.repo.next-local-tag increment" {
  otag=$(git.repo.latest-local-tag)
  ntag=$(git.repo.next-local-tag)
  over=$(util.ver-to-i ${otag}) 
  nver=$(util.ver-to-i ${ntag}) 
  diff=$(( nver - over ))
  [[ ${diff} -eq 1 ]]
}

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
