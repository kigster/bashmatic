#!/usr/bin/env bash

( [[ -n ${ZSH_EVAL_CONEXT} && ${ZSH_EVAL_CONTEXT} =~ :file$ ]] || \
  [[ -n $BASH_VERSION && $0 != "$BASH_SOURCE" ]]) && __ran_as_script=0 || __ran_as_script=1

loader=$(find . -name Loader.bash)
source ${loader}

h1  "Welcome to My Awesome Script" "${bldylw}Version 1.0.1" \
    "We hope you'll enjoy your demo!"

info "info() prints an information message in blue. You can use other"
info "colors inside, such as ${bldred}RED$(txt-info) just reset it afterwards."

echo
hl::subtle "Sometimes it's more appropriate to have a more 'subtle' header."
info "These headers are great for styling help pages, for example:"

hl::subtle "USAGE — this type of header is great for this!"
info "command-line-tool [ --verbose ] [ -d/--directory DIR ]"

hl::yellow "But there are many other kinds of headers."
hl::blue "Some are blue..."
hl::green "And some are green"

h::red 'And some are centered'
h::yellow 'As well as colored :)'

info "Well, 'hl' stands for 'header left aligned', because you can also"
info "use, well, centered headers like so:"

h::red "MY MESSAGE IS VERY IMPORTANT"

echo
hr
echo
info "Noticed a horizontal line?"

info "Lets talk about running commands. This is where it gets cool!"
inf  "For example, this info message does not end with a line break! "
shortish-pause
ok:

info "Above we put a check box next to it, but there are other options:"

inf  "In this next case it's will be an error..."
shortish-pause
not_ok:

h2 "And we have 'info()', 'error()' and 'warning()' methods to communicate'" \
   "with the user effectively and easily" \
   "using multiple lines in this awesome header box :) "

br 
warning "A Warning is usually yellow and indicates something is awry, no? ⚠️  ${clr}"

error "Perhaps we encountered an error!" \
  "Well, there is a nice box for it too!" \
  "With many lines, ${bakblu}${bldwht}if your heart so desires!${clr}"

box::yellow-in-blue "Perhaps we should run some more commands!"

run  "mkdir -p hello"
run  "cd hello"
export temp_file=$(mktemp)

run::set-next abort-on-error

run  "touch ${temp_file}"
run  "rm -f ${temp_file}"

hl::subtle "Let's simulate having a Gemfile.lock — for those of you using Ruby:"
run "cp -v ../test/Gemfile.lock ."
run::set-next show-output-on
hr
run 'head -10 Gemfile.lock'
hr::colored "${bldred}"
br
info "This is so that now we can detect a gem version from the Gemfile.lock:"
info "${bldylw}IMPORTANT! $(txt-info)Active support version is ${bldylw}$(lib::gem::gemfile::version activesupport)"

hl::subtle "Did you notice that commands are printed with their execution times?"

shortish-pause
hr
br
success "This demonstration was a remarkable success!"
br
h1 "Thanks for checking this library out, and happy bashing!"
br


