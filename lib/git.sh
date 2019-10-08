#!/usr/bin/env bash

lib::git::repo-is-clean() {
   [[ -z $(git status -s) ]] 
}
