#!/usr/bin/env bash

run() {
  __lib::run $@
  return ${LibRun__LastExitCode}
}
