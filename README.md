
[![Build Status](https://travis-ci.org/kigster/bashmatic.svg?branch=master)](https://travis-ci.org/kigster/bashmatic)

# BashMatic

<!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Reusable BASH Components for UI, Runtime, Ruby, Database and More](#reusable-bash-components-for-ui-runtime-ruby-database-and-more)
	- [Whats Included?](#whats-included)
		- [Runtime Framework](#runtime-framework)
		- [Examples of Runtime Framework](#examples-of-runtime-framework)
		- [UI Drawing / Output functions](#ui-drawing-output-functions)
		- [Other Utilities](#other-utilities)
- [Usage](#usage)
	- [1. Integrating With Your Project](#1-integrating-with-your-project)
	- [2. Manual Install](#2-manual-install)
		- [Custom Installer](#custom-installer)
	- [Some Tips on Writing Shell Scripts](#some-tips-on-writing-shell-scripts)
	- [The List of Available Functions](#the-list-of-available-functions)
	- [Naming Conventions](#naming-conventions)
	- [Writing tests](#writing-tests)
- [Helpful Scripts](#helpful-scripts)
	- [Changing OSX Underscan for Old Monitors](#changing-osx-underscan-for-old-monitors)
	- [Contributing](#contributing)

<!-- /TOC -->
## Reusable BASH Components for UI, Runtime, Ruby, Database and More

Welcome to **BashMatic** — an ever growing collection of scripts and mini-bash frameworks for doing all sorts of things quickly and efficiently.

We have adopted the [Google Bash Style Guide](https://google.github.io/styleguide/shell.xml), and it's recommended that anyone committing to this repo reads the guides to understand the conventions, gotchas and anti-patterns.

### Whats Included?

There is a ton of useful scripts, functions, shortcuts and frameworks that make programming BASH fun. At least for me they do!

To get a sense of the number of functions included, run `bin/print-functions` command, optionally passing a number of columns you want to see them printed with. If your screen is wide, use eg. `bin/print-functions 5`.

#### Runtime Framework

One of the core tenets of this library is it's "runtime" framework, which offers a way to run and display commands as they run, while having a fine-grained control over the following:

 * What happens when one of the commands fails? Options include:
   * Ignore and continue (default) — *continue-on-error*
   * Ask the user if she wants to proceed — *ask-on-error*
   * Abort the entire run — *abort-on-error*.
 * How is command output displayed?
   * Is it swallowed for compactness, and only shown if there is an error? (default) — *show-output-off*
   * Or is it shown regardless? — *show-output-on*
 * Should commands actually run (*dry-run-off*), or simply be printed? (*dry-run-on*).

#### Examples of Runtime Framework

> NOTE, in the following examples we assume you installed the library into your project's folder as `.bashmatic` (a "hidden" folder starting with a dot).

Programming style used in this project lends itself nicely to using a DSL-like approach to shell programming.  For example, in order to configure the behavior of the run-time framework (see below) you would run the following command:

```bash
#!/usr/bin/env bash

# (See below on the location of .bashmatic and ways to install it)
source ~/.bashmatic/lib/Loader.bash

# configure global behavior of all run() invocations
run::set-all abort-on-error show-output-off

run "git clone https://gthub.com/user/rails-repo rails"
run "cd rails"
run "bundle check || bundle install"

# the following configuration only applies to the next invocation of `run()`
# and then resets back to `off`
run::set-next show-output-on
run "bundle exec rspec"
```

You can reliably install gems or brew packages:

```bash
#!/usr/bin/env bash
source .bashmatic/lib/Loader.bash
lib::gem::install sym 1.3.0
lib::brew::install::package curl
sym_version=$(lib::gem::version sym)
echo "Version installed is ${sym_version}"
```

The output from the above script would be something like this:

```
    installing sym (2.8.4)...
 ✔︎  3.1s ❯ gem install sym --version 2.8.4 --no-ri --no-rdoc --force --quiet
 ✔︎  1.3s ❯ gem list > /tmp/gem_list.txt
 ✔︎  checking brew package curl
Version installed is 2.8.2
```

You can shorten URLs using Bitly:

```bash
lib::url::shorten https://raw.githubusercontent.com/kigster/bashmatic/master/bin/install
# http://bit.ly/2IIPNE1
```

And most importantly, you can use our fancy UI drawing routines to communicate with the user, which are based on familiar HTML constructs, such as `h1`, `h2`, `hr`, etc.

#### UI Drawing / Output functions

Here is another example where we are deciding whether to print something based on whether the output is a proper terminal (and not a pipe or redirect):

```
lib::output::is_tty && h1 "Yay For Terminals!"
```

The above reads more like a high level language like Ruby or Python than Shell. That's because BASH is more powerful than most people think.

There is an [example script](examples/test-ui.sh) that demonstrates the capabilities of BashMatic.

If you ran it, below is what you would see (although your colors may vary depending on what color scheme and font you use for your terminal).

![bashmatic](.bashmatic.png)

Here is a full list of runtime lib functions as of March 2019:

```bash
cursor.rewind                       h3
lib::output::color::on              hdr
lib::output::color::off             hr::colored
center                              hr
left                                stdout
cursor.at.x                         stderr
cursor.at.y                         duration
screen.width                        ok
screen.height                       not_ok
lib::output::is_terminal            kind_of_ok
lib::output::is_ssh                 ok:
lib::output::is_tty                 not_ok:
lib::output::is_pipe                kind_of_ok:
lib::output::is_redirect            puts
box::yellow-in-red                  okay
box::yellow-in-yellow               success
box::blue-in-yellow                 err
box::blue-in-green                  inf
box::yellow-in-blue                 warn
box::red-in-yellow                  warning
box::red-in-red                     br
box::green-in-magenta               debug
box::red-in-magenta                 info
box::green-in-green                 error
box::magenta-in-green               info:
box::magenta-in-blue                error:
hl::blue                            warning:
hl::green                           shutdown
hl::yellow                          reset-color
hl::subtle                          reset-color:
hl::desc                            ascii-clean
h::yellow                           lib::color::enable
h::red                              txt-info
h::green                            txt-err
h::blue                             txt-warn
h::black                            error-text
h1::green                           bold
h1::purple                          italic
h1::blue                            underline
h1::red                             strikethrough
h1::yellow                          red
h1                                  ansi
h2                                  lib::color::disable
```

#### Other Utilities

The utilities contained herein are of various types, such as:

 * array helpers, such as `array-contains-element` function
 * version helpers, such as functions `lib::util::ver-to-i` which convert a string version like '1.2.0' into an integer that can be used in comparisons; another function `lib::util::i-to-ver` converts an integer back into the string format. This is used, for example, by the auto-incrementing Docker image building tools available in [`docker.sh`](lib/docker.sh)
 * ruby version helpers that can extract curren gem version from either `Gemfile.lock` or globally installed gem list
 * [AWS helpers](lib/aws.sh), requires `awscli` and credentials setup.
 * [output helpers](lib/output.sh), such as colored boxes, header and lines
 * [file helpers](lib/file.sh)
 * [docker helpers](lib/docker.sh)
 * [ruby](lib/ruby.sh), [sym](lib/sym.sh) (encryption) and [utility](lib/utility.sh) helpers
 * and finally, [*LibRun*](lib/runtime.sh) — a BASH runtime framework that executes commands, while measuring their duration and following a set of flags to decide what to do on error, and so on.

----

## Usage

There are a couple of ways that you can install and use this library.

   1. The simplest way is to use the online bootstrap script.  This method is often used to integrate **BashMatic** with your other projects, so that they can be built upon their own internal BASH tooling using all the goodies in this library.

   1. One is doing a simple manual `git clone`, and then "sourcing" the main `lib/Loader.bash` file from one of your "dotfiles".

### 1. Integrating With Your Project

**BashMatic** comes with a clever installer that can be used to install it into any subfolder of an existing project.0

Here is an example of how you could integrate it directly into an existing repo:

```bash
cd ~/workspace/my-project
curl -fsSL http://bit.ly/bashmatic-bootstrap | /usr/bin/env bash
```

The installer above will do the following:

 * Checkout `bashmatic` repo into a folder typically in your home: `${HOME}/.bashmatic`

 * If your project already has a `bin` folder — it's will be used to create a `lib` symlink, otherwise it's created in the current folder.

 * The script will also create a symlink to Bashmatic's `bin/bootstrap` script, again — either in the local `bin` folder, or in the current one.

 * Finally, it will add both `bin/lib` and `bin/bootstrap` to `.gitignore` file, if that was found.

 * At this point you should be able to source the library with `source bin/lib/Loader.bash` and have all of the tools available to you.

### Installation

The standard location of Bashmatic is in your home folder — `~/.bashmatic`

Therefore the manual installation is as follows:

```bash
cd ${HOME} && git clone http://github.com/kigster/bashmatic ~/.bashmatic
```

If you want to automatically load all functions during your shell initialization, you could run the following command to auto-load Bashmatic from your `~/.bashrc`:

```bash
[[ -f ~/.bashrc ]] && \
  ( grep -q bashmatic ~/.bashrc || \
	   echo 'source ~/.bashmatic/lib/Loader.bash' >> ~/.bashrc )
```

### Detecting If Your Script is "Sourced In" or "Ran"

Some bash files exists as libraries to be "sourced in", and others exist as scripts to be run. But users won't always know what is what, and may try to source in a script that should be run, or vice versa — run a script that should be sourced in.

What do you, programmer, do to educate the user about correct usage of your script/library?

Here is one method:

```bash
#!/usr/bin/env bash
# If you want to be able to tell if the script is run or sourced:
( [[ -n ${ZSH_EVAL_CONTEXT} && ${ZSH_EVAL_CONTEXT} =~ :file$ ]] || \
  [[ -n $BASH_VERSION && $0 != "$BASH_SOURCE" ]]) && __ran_as_script=0 || __ran_as_script=1

export __ran_as_script
(( $__ran_as_script )) && {
  echo; printf "This script should be run, not sourced.${clr}\n"
  echo; exit 1
}
```

This method sets the variable `$__ran_as_script` to either 1 (if the script is *sourced in*) and 0 if the script is run. Since both values are numeric we can use BASH's numeric expansion, which evaluates as follows:

```bash
(( 1 )) && echo "1 is true and therefore this is printed"
(( 0 )) && echo "0 is false, so this statement is not printed"
```

If you run the above, you should see only one line printed:

```
1 is true and therefore this is printed
```

### The List of Available Functions

You can get the list of functions printed by loading bashmatic as shown above, and then typing:

```bash
$ bashmatic-functions [ COLUMNS ]
```

Where `COLUMNS` is an optional number of columns to split them by.

Here are the non-UI related functions of BashMatic, reducted for brevity (since the UI list is already shown above.)

```
ansi                                             lib::docker::last-version
array-bullet-list                                lib::docker::next-version
array-contains-element                           lib::file::last-modified-date
array-join                                       lib::file::last-modified-year
array-join-piped                                 lib::gem::cache-installed
ascii-clean                                      lib::gem::cache-refresh
aws::rds::hostname                               lib::gem::ensure-gem-version
bashmatic-functions                              lib::gem::gemfile::version
bashmatic-set-fqdn                               lib::gem::global::latest-version
bold                                             lib::gem::global::versions
box::blue-in-green                               lib::gem::install
box::blue-in-yellow                              lib::gem::is-installed
box::green-in-green                              lib::gem::uninstall
box::green-in-magenta                            lib::gem::version
box::magenta-in-blue                             lib::json::begin-array
box::magenta-in-green                            lib::json::begin-hash
box::red-in-magenta                              lib::json::begin-key
box::red-in-red                                  lib::json::end-array
box::red-in-yellow                               lib::json::end-hash
box::yellow-in-blue                              lib::json::file-to-array
box::yellow-in-red                               lib::osx::cookie-dump
box::yellow-in-yellow                            lib::osx::display::change-underscan
br                                               lib::osx::env-print
center                                           lib::osx::ramdisk::mount
cookie-dump                                      lib::osx::ramdisk::unmount
debug                                            lib::osx::scutil-print
duration                                         lib::osx::set-fqdn
epoch                                            lib::output::color::off
err                                              lib::output::color::on
error                                            lib::progress::bar
error-text                                       lib::psql::db-settings
error:                                           lib::ruby::bundler-version
file::list::filter-existing                      lib::ruby::gemfile-lock-version
file::list::filter-non-empty                     lib::ruby::version
file::size                                       lib::run
file::size::mb                                   lib::run::ask
file::stat                                       lib::run::inspect
ftrace-in                                        lib::run::inspect-variable
ftrace-off                                       lib::run::inspect-variables
ftrace-on                                        lib::run::inspect-variables-that-are
ftrace-out                                       lib::run::inspect::set-skip-false-or-blank
g-i                                              lib::run::print-variable
g-u                                              lib::run::print-variables
h::black                                         lib::run::variables-ending-with
h::blue                                          lib::run::variables-starting-with
h::green                                         lib::run::with-min-duration
h::red                                           lib::ssh::load-keys
h::yellow                                        lib::time::date-from-epoch
hb::crypt::chef                                  lib::time::duration::humanize
hb::decrypt::file                                lib::time::epoch-to-iso
hb::decrypt::str                                 lib::time::epoch-to-local
hb::edit::file                                   lib::time::epoch::minutes-ago
hb::encrypt::file                                lib::url::downloader
hb::encrypt::str                                 lib::url::shorten
hb::sym                                          lib::user
hbsed                                            lib::user::finger::name
hdr                                              lib::user::first
hl::blue                                         lib::user::gitconfig::email
hl::desc                                         lib::user::gitconfig::name
hl::green                                        lib::user::host
hl::subtle                                       lib::user::my::ip
hl::yellow                                       lib::user::my::reverse-ip
hr::colored                                      lib::user::username
inf                                              lib::util::append-to-init-files
info                                             lib::util::arch
info:                                            lib::util::checksum::files
italic                                           lib::util::functions-matching
left                                             lib::util::generate-password
lib::array::complain-unless-includes             lib::util::i-to-ver
lib::array::contains-element                     lib::util::install-direnv
lib::array::exit-unless-includes                 lib::util::is-a-function
lib::array::join                                 lib::util::is-numeric
lib::array::join-piped                           lib::util::is-variable-defined
lib::brew::cache-reset                           lib::util::lines-in-folder
lib::brew::cache-reset::delayed                  lib::util::remove-from-init-files
lib::brew::cask::is-installed                    lib::util::shell-init-files
lib::brew::cask::list                            lib::util::shell-name
lib::brew::install                               lib::util::ver-to-i
lib::brew::install::cask                         lib::util::whats-installed
lib::brew::install::package                      long-pause
lib::brew::install::packages                     millis
lib::brew::package::is-installed                 odie
lib::brew::package::list                         ok
lib::brew::reinstall::package                    ok:
lib::brew::reinstall::packages                   okay
lib::brew::relink                                onoe
lib::brew::setup                                 pause
lib::brew::uninstall::package                    puts
lib::brew::uninstall::packages                   red
lib::brew::upgrade                               reset-color
lib::cache-or-command                            reset-color:
lib::color::disable                              run
lib::color::enable                               run::inspect
lib::db::datetime                                run::set-all
lib::db::dump                                    run::set-all::list
lib::db::psql-args                               run::set-next
lib::db::psql::args::                            run::set-next::list
lib::db::psql::args::default                     screen-width
lib::db::psql::args::maint                       short-pause
lib::db::rails::schema::checksum                 shortish-pause
lib::db::rails::schema::file                     shutdown
lib::db::restore                                 stderr
lib::db::top                                     stdout
lib::db::wait-until-db-online                    strikethrough
lib::deploy::slack                               success
lib::deploy::slack-ding                          sym::hb::configure
lib::deploy::validate-vpn                        sym::hb::files
lib::dir::count-slashes                          sym::hb::import
lib::dir::expand-dir                             sym::hb::install-shell-helpers
lib::dir::is-a-dir                               sym::install::symit
lib::docker::actions::build                      today
lib::docker::actions::clean                      txt-err
lib::docker::actions::pull                       txt-info
lib::docker::actions::push                       txt-warn
lib::docker::actions::setup                      underline
lib::docker::actions::start                      warn
lib::docker::actions::stop                       warning
lib::docker::actions::tag                        warning:
lib::docker::actions::up                         with-bundle-exec
lib::docker::actions::update                     with-bundle-exec-and-output
lib::docker::build::container                    with-min-duration

```

### Naming Conventions

We use the following naming conventions:

 1. Namespaces are separated by `::`
 2. Private functions are prefixed with `__`, eg `__lib::output::hr1`
 3. Public functions do not need to be name-spaced, or be prefixed with `__`

## Unit Testing

The framework comes with a bunch of automated unit tests based on the fantastic framework [`bats`](https://github.com/sstephenson/bats.git).

To run all tests:

```bash
cd ~/.bashmatic
bin/specs
```

While not every single function is tested (far from it), we do try to add tests to the critical ones.

Please see [existing tests](https://github.com/kigster/bashmatic/tree/master/test) for the examples.

## How To?

### How To Change Underscan or Overscan for Old Monitors

If you are stuck working on a monitor that does not support switching digit input from TV to PC, NOR does OS-X show the "underscan" slider in the Display Preferences, you may be forced to change the underscan manually. The process is a bit tricky, but we have a helpful script to do that:

```bash
$ source lib/Loader.bash
$ change-underscan 5
```

This will reduce underscan by 5% compared to the current value. The total value is 10000, and is stored in the file `/var/db/.com.apple.iokit.graphics`. The tricky part is determining which of the display entries map to your problem monitor. This is what the script helps with.

Do not forget to restart after the change.

Acknowledgements: the script is an automation of the method offered on [this blog post](http://ishan.co/external-monitor-underscan).

### Contributing

Submit a pull request!
