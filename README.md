
[![Build Status](https://travis-ci.org/kigster/bashmatic.svg?branch=master)](https://travis-ci.org/kigster/bashmatic)

# BashMatic

<!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Quick Install](#quick-install)
- [Reusable BASH Components for UI, Runtime, Ruby, Database and More](#reusable-bash-components-for-ui-runtime-ruby-database-and-more)
	- [Whats Included?](#whats-included)
		- [Runtime Framework](#runtime-framework)
		- [Examples of Runtime Framework](#examples-of-runtime-framework)
		- [UI Drawing / Output functions](#ui-drawing-output-functions)
		- [Other Utilities](#other-utilities)
- [Usage](#usage)
	- [Integrating With Your Project](#integrating-with-your-project)
	- [Installation](#installation)
	- [Detecting If Your Script is "Sourced In" or "Ran"](#detecting-if-your-script-is-sourced-in-or-ran)
	- [The List of Available Functions](#the-list-of-available-functions)
	- [Naming Conventions](#naming-conventions)
- [Unit Testing](#unit-testing)
- [How To?](#how-to)
	- [How To Change Underscan or Overscan for Old Monitors](#how-to-change-underscan-or-overscan-for-old-monitors)
	- [Contributing](#contributing)

<!-- /TOC -->

## Quick Install

For the impatient, here is how to install BashMatic very quickly and easily:

```bash
curl -fsSL http://bit.ly/bashmatic-bootstrap | /usr/bin/env bash
source ~/.bashmatic/init.sh
bashmatic.load-at-login
```

When you run the `bashmatic.load-at-login` function, it will add a bashmatic hook to one of your BASH initialization files, so all of its functions are available in your shell.

The output of this function may look like this:

```
┌────────────────────────────────────────────────────────────────────┐
│ Adding BashMatic auto-loader to /Users/<your-username>/.bashrc...  │
└────────────────────────────────────────────────────────────────────┘
```

You can always reload BashMatic with `bashmatic.reload` function.

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
source ~/.bashmatic/init.sh

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
source .bashmatic/init.sh
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

   1. One is doing a simple manual `git clone`, and then "sourcing" the main `init.sh` file from one of your "dotfiles".

### Integrating With Your Project

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

 * At this point you should be able to source the library with `source bin/init.sh` and have all of the tools available to you.

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
	   echo 'source ~/.bashmatic/init.sh' >> ~/.bashrc )
```

### Detecting If Your Script is "Sourced In" or "Ran"

Some bash files exists as libraries to be "sourced in", and others exist as scripts to be run. But users won't always know what is what, and may try to source in a script that should be run, or vice versa — run a script that should be sourced in.

What do you, programmer, do to educate the user about correct usage of your script/library?

BashMatic offers a reliable way to test this:

```bash
#!/usr/bin/env bash
# load library
if [[ -f "${BashMatic__Init}" ]]; then source "${BashMatic__Init}"; else source ~/.bashmatic/init.sh; fi
bashmatic::validate-subshell || return 1
```

If you'd rather require a library to be sourced in, but not run, use the code as follows:

```bash
#!/usr/bin/env bash
# load library
if [[ -f "${BashMatic__Init}" ]]; then source "${BashMatic__Init}"; else source ~/.bashmatic/init.sh; fi
bashmatic::validate-sourced-in || exit 1
```


### The List of Available Functions

You can get the list of functions printed by loading bashmatic as shown above, and then typing:

```bash
$ bashmatic.functions [ COLUMNS ]
```

Where `COLUMNS` is an optional number of columns to split them by.

Here is the comprehensive list of BashMatic public functions you can use:

```
❯ bashmatic.functions 2
7z.a                                     lib::docker::abort_if_down
7z.x                                     lib::docker::actions::build
ansi                                     lib::docker::actions::clean
array-bullet-list                        lib::docker::actions::pull
array-contains-element                   lib::docker::actions::push
array-csv                                lib::docker::actions::setup
array-join                               lib::docker::actions::start
array-join-piped                         lib::docker::actions::stop
ascii-clean                              lib::docker::actions::tag
aws::rds::hostname                       lib::docker::actions::up
aws::s3::upload                          lib::docker::actions::update
bashmatic-set-fqdn                       lib::docker::build::container
bashmatic-term                           lib::docker::last-version
bashmatic-term-program                   lib::docker::next-version
bashmatic.functions                      lib::file::exists_and_newer_than
bashmatic.load-at-login                  lib::file::install_with_backup
bashmatic.reload                         lib::file::last-modified-date
bashmatic::detect-subshell               lib::file::last-modified-year
bashmatic::validate-sourced-in           lib::gem::cache-installed
bashmatic::validate-subshell             lib::gem::cache-refresh
bold                                     lib::gem::ensure-gem-version
box::blue-in-green                       lib::gem::gemfile::version
box::blue-in-yellow                      lib::gem::global::latest-version
box::green-in-green                      lib::gem::global::versions
box::green-in-magenta                    lib::gem::install
box::magenta-in-blue                     lib::gem::is-installed
box::magenta-in-green                    lib::gem::uninstall
box::red-in-magenta                      lib::gem::version
box::red-in-red                          lib::json::begin-array
box::red-in-yellow                       lib::json::begin-hash
box::yellow-in-blue                      lib::json::begin-key
box::yellow-in-red                       lib::json::end-array
box::yellow-in-yellow                    lib::json::end-hash
br                                       lib::json::file-to-array
center                                   lib::osx::cookie-dump
change-underscan                         lib::osx::env-print
cookie-dump                              lib::osx::ramdisk::mount
cursor.at.x                              lib::osx::ramdisk::unmount
cursor.at.y                              lib::osx::scutil-print
cursor.down                              lib::osx::set-fqdn
cursor.left                              lib::output::color::off
cursor.rewind                            lib::output::color::on
cursor.right                             lib::output::is_pipe
cursor.up                                lib::output::is_redirect
debug                                    lib::output::is_ssh
decrypt.secrets                          lib::output::is_terminal
duration                                 lib::output::is_tty
epoch                                    lib::progress::bar
err                                      lib::psql::db-settings
error                                    lib::ruby::bundler-version
error-text                               lib::ruby::gemfile-lock-version
error:                                   lib::ruby::version
file::list::filter-existing              lib::run
file::list::filter-non-empty             lib::run::ask
file::size                               lib::run::inspect
file::size::mb                           lib::run::inspect-variable
file::stat                               lib::run::inspect-variables
ftrace-in                                lib::run::inspect-variables-that-are
ftrace-off                               lib::run::inspect::set-skip-false-or-blank
ftrace-on                                lib::run::print-variable
ftrace-out                               lib::run::print-variables
g-i                                      lib::run::variables-ending-with
g-u                                      lib::run::variables-starting-with
h1                                       lib::run::with-min-duration
h1::blue                                 lib::ssh::load-keys
h1::green                                lib::time::date-from-epoch
h1::purple                               lib::time::duration::humanize
h1::red                                  lib::time::epoch-to-iso
h1::yellow                               lib::time::epoch-to-local
h2                                       lib::time::epoch::minutes-ago
h3                                       lib::url::downloader
h::black                                 lib::url::http-code
h::blue                                  lib::url::is-valid
h::green                                 lib::url::shorten
h::red                                   lib::url::valid-status
h::yellow                                lib::user
hb::crypt::chef                          lib::user::finger::name
hb::decrypt::file                        lib::user::first
hb::decrypt::str                         lib::user::gitconfig::email
hb::edit::file                           lib::user::gitconfig::name
hb::encrypt::file                        lib::user::host
hb::encrypt::str                         lib::user::my::ip
hb::sym                                  lib::user::my::reverse-ip
hbsed                                    lib::user::username
hdr                                      lib::util::append-to-init-files
hl::blue                                 lib::util::arch
hl::desc                                 lib::util::checksum::files
hl::green                                lib::util::functions-matching
hl::subtle                               lib::util::generate-password
hl::yellow                               lib::util::i-to-ver
hr::colored                              lib::util::install-direnv
inf                                      lib::util::is-a-function
info                                     lib::util::is-numeric
info:                                    lib::util::is-variable-defined
is_ask_on_error                          lib::util::lines-in-folder
is_detail                                lib::util::remove-from-init-files
is_verbose                               lib::util::shell-init-files
italic                                   lib::util::shell-name
kind_of_ok                               lib::util::ver-to-i
kind_of_ok:                              lib::util::whats-installed
left                                     long-pause
lib::7z::install                         millis
lib::7z::unzip                           not_ok
lib::7z::unzip                           not_ok:
lib::7z::zip                             odie
lib::array::complain-unless-includes     ok
lib::array::contains-element             ok:
lib::array::exit-unless-includes         okay
lib::array::from-command-output          onoe
lib::array::join                         pause
lib::array::join-piped                   press-any-key-to-continue
lib::brew::cache-reset                   puts
lib::brew::cache-reset::delayed          red
lib::brew::cask::is-installed            reset-color
lib::brew::cask::list                    reset-color:
lib::brew::install                       run
lib::brew::install::cask                 run::inspect
lib::brew::install::package              run::set-all
lib::brew::install::packages             run::set-all::list
lib::brew::package::is-installed         run::set-next
lib::brew::package::list                 run::set-next::list
lib::brew::reinstall::package            safe_cd
lib::brew::reinstall::packages           screen-width
lib::brew::relink                        screen.height
lib::brew::setup                         screen.width
lib::brew::uninstall::package            short-pause
lib::brew::uninstall::packages           shortish-pause
lib::brew::upgrade                       shutdown
lib::cache-or-command                    stderr
lib::color::disable                      stdout
lib::color::enable                       strikethrough
lib::db::datetime                        success
lib::db::dump                            sym::hb::configure
lib::db::num_procs                       sym::hb::files
lib::db::psql-args                       sym::hb::have_key
lib::db::psql::args::                    sym::hb::import
lib::db::psql::args::default             sym::hb::install-shell-helpers
lib::db::psql::args::maint               sym::install::symit
lib::db::rails::schema::checksum         today
lib::db::rails::schema::file             txt-err
lib::db::restore                         txt-info
lib::db::top                             txt-warn
lib::db::wait-until-db-online            underline
lib::deploy::slack                       warn
lib::deploy::slack-ding                  warning
lib::deploy::validate-vpn                warning:
lib::dir::count-slashes                  with-bundle-exec
lib::dir::expand-dir                     with-bundle-exec-and-output
lib::dir::is-a-dir                       with-min-duration
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
$ source init.sh
$ change-underscan 5
```

This will reduce underscan by 5% compared to the current value. The total value is 10000, and is stored in the file `/var/db/.com.apple.iokit.graphics`. The tricky part is determining which of the display entries map to your problem monitor. This is what the script helps with.

Do not forget to restart after the change.

Acknowledgements: the script is an automation of the method offered on [this blog post](http://ishan.co/external-monitor-underscan).

### Contributing

Submit a pull request!
