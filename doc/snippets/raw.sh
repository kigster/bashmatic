#!/usr/bin/env bash
# vim: ft=bash sw=4 ft=4
#—————————————————————————————————————————————————————————————————————————
# Load Bashmatic Framework for ease of development and user interaction.
# For more information, please run one of the below messages:
#   
# Read Bashmatic PDF Documentation:
#  • https://bashmatic-pdf.re1.re/
#   
# Or, read the Github README:
#  • open https://bashmatic-readme.re1.re
#   
# © 2015-2021 Konstantin Gredeskoul, MIT License.
#   
# Please note that you can customize how Bashmatic is Installed by passing flags
# to bashmatic-install script. For more info click on https://bashmatic-install.re1.re/

[[ -d "HOME/.bashmatic" ]] || bash -c "$(curl -fsSL https://bashmatic.re1.re); bashmatic-install -q"
[[ -f "HOME/.bashmatic/init.sh" ]] || { echo "Unable to find Bashmatic's init.sh after an attempted installation."; exit 1; }
 
# NOTE: to see what loading bashmatic/init.sh actually does, run
# export DEBUG=1 prior to sourcing Bashmatic. And good luck, darling :)
# shellcheck source="HOME/.bashmatic/init.sh"
# shellcheck disable=SC1091

. "HOME/.bashmatics/init.sh"
 
# If you are not familiar with Bashmatic, now would be a good time to run:
# > bashmatic.functions 4 # to get a sense of the breadth of the BASH helpers offered.
#——————————————————————————————————————————————————————————————————————————
