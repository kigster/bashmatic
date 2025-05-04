#!/usr/bin/env bash

if [[ -f "${BASHMATIC_INIT}" ]]; then 
   source "${BASHMATIC_INIT}"; 
else 
   source ${BASHMATIC_HOME}/init.sh; 
fi

export BASH_SUBSHELL=1

DELAY_SECONDS="${1:-3}"

function pause-bar() {
   progress.bar.auto-run "${1:-"2"}"
}

function delay() {
   pause ${DELAY_SECONDS}
}

function pause-multiplier() {
   local factor="$1"
   echo -n $(ruby -e "puts ${DELAY_SECONDS}*${factor}")
}

clear

h1 "Welcome to Bashmatic DEMO Script" "${bldylw}Version ${BASHMATIC_VERSION}"
h2 "We hope you'll enjoy this demo!"

delay

echo
info "NOTE: This file lives in ${txtylw}examples/ui-showcase.sh"
echo
info "During this demo we'll be using many of the UI widgets that come with"
info "Bashmatic. They are named after HTML elements to make it easy to remember."
info "For instance, we'll be using the following functions:"
echo
h3bg "NOTE: to print the functions below we are using function ${txtylw}array.to.bullet-list"
echo

array.to.bullet-list h1 h2 h3 h4 h1bg h2bg h3bg h4bg hl.yellow hl.red hl.green h.orange h.yellow h.salmon 
run.ui.press-any-key

clear
echo
h2 "Speaking of the arrays, here are the array functions available:"
array.to.bullet-list $(bashmatic.functions 1 | grep '^array' | tr '\n' ' ')

run.ui.press-any-key

clear

echo
info "Once you source the file init.sh inside Bashmatic's folder, all functions"
info "become available."
echo

delay

info "Bashmatic can detect whether of not your are running in a subshell."
info "For example: ${txtylw}(( \$bashmatic.detect-subshell) )) || echo 'NO, we are not!'"
echo

inf "Are we in a subshell? "

export IN_SUB_SHELL=$(bashmatic.detect-subshell)
((IN_SUB_SHELL)) && printf "YES we are!" && ui.closer.ok:
((IN_SUB_SHELL)) || printf "NO, we are not!"  && ui.closer.not-ok:

run.ui.press-any-key

echo; hr; echo
info "Lets list every BASH function this library has imported into our current"
info "BASH environment. The function usage is ${txtylw}bashmatic.functions <columns>"
info "which lists functions in one or more columns. We'll show top 10 lines..."

delay

run.set-next show-output-on
run "bashmatic.functions 3 | head -10"
echo

delay

info "Neat, huh?"
run.ui.press-any-key

clear
h3 "Let's look at ways to run commands and show some feedback to the user..."
delay

info "Instead of a sleep — we can show a progress bar that runs for however"
info "many seconds we like — for example ${txtylw}progress.bar 3"
echo
pause-bar $(pause-multiplier 4)
echo
run.ui.press-any-key

clear
echo

h1bg "How cool is this header box on the blue background! With automatic width!" \
     "Now lets run some commands — this is likely going to be the most useful" \
     "part of Bashmatic for creating installers and other scripts."
echo
info "To run commands we use the function ${txtylw}run()$(txt-info). By the default,"
info "running commands this way only show their exit status and timing it took."
delay
info "For example: we could invoke it like so: ${txtylw}run \"mkdir -p /tmp/bashmatic\""
echo

run.ui.press-any-key

run "ps -ef | grep ${USER} | awk '{print $2}' | sort"
run "sleep 1"
run "df -h"

delay

h3 "Please notice how each command is printed with the exit code and the timing."

info "NOTE: If a command fails, it will appear with a red box instead of a green checkmark."
info "BUT:  Whether your script continues to run after a command fails, depends on"
info "the run configuration. By default, the script continues to run. To change that,"
info "execute ${txtylw}run.set-next abort-on-error${txtcyn} which only affects the next command."
info "Or, execute ${txtylw}run.set-all abort-on-error${txtcyn} to make any subsequent command abort"
info "the script entirely."

delay

run.ui.press-any-key

info "For instance, let's run a command that returns a non-zero status..."
echo
run "date -f asdfadsf 2>/dev/null"
echo
delay
info "Note how we hid the STDERR of the command. If we wanted to see it, just"
info "do not redirect it:"
echo
run "date -f asdfasdf"
echo

run.ui.press-any-key

clear

h2 "Now, let's show the output of commands we are running. To do so, we" \
   "must call ${txtylw}run.set-next show-output-on" \
   "NOTE: that this only affects the first command ran after. " \
   "      To make that change affect ALL commands, run ${txtylw}run.set-all"

delay

info "In fact, let's see what options this command has, by running it without"
info "any arguments: ${txtylw}run.set-next"

run.set-next

run.ui.press-any-key

clear

h2  "So let's configure the next run() command to print its stdout:"  \
    "${txtylw}run.set-next show-output-on"

run.set-next show-output-on

delay

export vmstat=$(command -v vmstat 2>/dev/null || command -v vm_stat 2>/dev/null)

info "And run the command: ${txtylw}run \"${vmstat}\""
run  "vm_stat"

run.ui.press-any-key

clear

h1 "Next, we'll show you various UI elements that are available to you." \
   "For example, this type of header is invoked with ${txtylw}h1 \"text\""

info "info() prints an information message in blue. You can use other"
info "colors inside, such as ${bldred}RED$(txt-info) just reset it afterwards."

hl.subtle "This type of a header is a function called 'hl.subtle'"

run.ui.press-any-key

info      "These headers are great for styling help pages, for example:"
echo
hl.subtle "USAGE — this type of header is great for this!"
info "command-line-tool [ --verbose ] [ -d/--directory DIR ]"

hl.yellow "But there are many other kinds of headers."
info "This one is invoked via ${txtylw}hl.yellow 'text'"
hl.blue   "Some are purple..."
info "This one is invoked via ${txtylw}hl.green 'text'"
hl.green  "And some are green"
info "This one is invoked via ${txtylw}h.red 'text'"

echo
h.red     'And some are very very red :) '
echo
info "This one is invoked via ${txtylw}h.yellow 'text'"
echo
h.yellow  'As well as colored :)'
echo

delay

info  "Well, 'hl' stands for 'header left aligned..."
info  "Instead of calling ${txtylw}hl.red${txtblu} we can call ${txtylw}h.e"

h.e "This is red background message in a box!"

delay

echo; hr; echo
info "Oh, and 'hr' prints a horizontal line of any color."

run.ui.press-any-key
clear

h2 "For printing general messaging to the screen, we offer functions" \
   "'info()', 'error()' and 'warning()'."

br

info "First, you've already seen the 'info()' functions (this is it here)"
delay
warning "Next, you can print a warning with the 'warning()' function."
delay
info "Next, we can print a very visible error using the 'error()' function:"
delay 1
error "Perhaps we encountered an error! It can span multiple lines if needed." \
      "Each argument becomes its own line in the error box." \
      "With as many lines as your heart desires!"

run.ui.press-any-key

info "And of course there are a ton of colored boxes, just type"
info "${txtylw}box.<TAB><TAB>${txtblu} to see the possible options:"

box.yellow-in-blue "This box is called yellow-in-blue"

delay

info "When your script is successful, you can invoke the function:"
info "${txtylw}success \"This demonstration was a remarkable success!\""

br
success "This demonstration was a remarkable success!"
run.ui.press-any-key

br
h2bg "Thanks for checking this library out, and happy bashing!"
br
info "But before we go, here is yet another neat function: ${txtylw}okay \"msg\""
okay "We appreciate your time watching this, and thank you!"
success "Happy BASH-ing!"
delay
echo
h3bg "More info at...." "${underlined}https://bashmatic.dev"
echo

