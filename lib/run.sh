#!/usr/bin/env bash

run() {
  .run $@
  return ${LibRun__LastExitCode}
}
