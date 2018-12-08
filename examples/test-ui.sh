#!/usr/bin/env bash

loader=$(find . -name Loader.bash)
source ${loader}

h1  "Welcome to My Awesome Script" "${bldylw}Version 1.0.1" \
    "We hope you'll enjoy your demo!"

info "info() prints an information message in blue. You can use other"
info "colors inside, such as ${bldred}RED$(txt-info) just reset it afterwards."

echo
hl::subtle "Sometimes it's more appropriate to have a more 'subtle' header."
info "These headers are great for styling help pages, for example:"

hl::subtle Usage
info "command-line-tool [ --verbose ] [ -d/--directory DIR ]"

hl::yellow "But there are many other kinds of headers."

info "Well, 'hl' stands for 'header left aligned', because you can also"
info "use, well, centered headers like so:"

h::red "MY MESSAGE IS VERY IMPORTANT"

echo
hr
echo
info "Noticed a horizontal line?"

info "Lets talk about running commands. This is where it gets cool!"
inf  "For example, this info message does not end with a line break! "
sleep 1
ok:

info "Above we put a check box next to it, but there are other options:"

inf  "In this next case it's will be an error..."
sleep 1
not_ok:

h2 "And we have 'info()', 'error()' and 'warning()' methods to communicate'" \
   "with the user effectively and easily"

error "We did something wrong, didn't we?"
run  "mkdir -p hello"
run  "cd hello"
# Let's simulate having a Gemfile.lock:
echo "    activesupport (5.0.7)" > Gemfile.lock
info "and we can detect a gem version from a lock file:"
info "active support version is ${bldylw}$(lib::gem::gemfile::version activesupport)"
hl::subtle "Did you notice that commands are printed with their execution times?"
run "sleep 1"
h::yellow "Thanks for checking this library out, and happy bashing!"
br
hr
