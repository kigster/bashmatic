#!/usr/bin/env bats 
load test_helper

@test "lib::git::repo-is-clean() when dirty" { 
  pwd=$(pwd)
  dir="/tmp/clean/repo"
  mkdir -p $dir && cd $dir 
  touch README
  echo '## README' >> README
  git init . && git add . && git commit -m 'initial commit'
  echo '### Modified' >> README
  clean=false
  lib::git::repo-is-clean && clean=true
  cd /tmp && rm -rf clean
  cd $pwd
  [[ ${clean} == false ]] 
}
@test "lib::git::repo-is-clean() when clean" { 
  pwd=$(pwd)
  dir="/tmp/clean/repo"
  mkdir -p $dir && cd $dir 
  touch README
  echo '## README' >> README
  git init . && git add . && git commit -m 'initial commit'
  clean=false
  lib::git::repo-is-clean && clean=true
  cd /tmp && rm -rf clean
  cd $pwd
  [[ ${clean} == true ]] 
}
