
[![Build Status](https://travis-ci.org/kigster/bashmatic.svg?branch=master)](https://travis-ci.org/kigster/bashmatic)

# BashMatic

> BashMatic is an ever-growing framework of Bash Script runners, auto-retrying, repeatable, DSL-controlled
> functions for every occasion, from drawing boxes and yelling at the user, to running complicated setup flows.
> Start exploring by installing it, and then running `bashmatic.functions` function, to see all available
> BASH functions added to your Shell by the framework.

<!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->
* [Bootstrap Install](#bootstrap-install)
* [Manual Install](#manual-install)
* [Reusable BASH Components for UI, Runtime, Ruby, Database and More](#reusable-bash-components-for-ui-runtime-ruby-database-and-more)
	* [Whats Included?](#whats-included)
		* [Runtime Framework](#runtime-framework)
		* [Examples of Runtime Framework](#examples-of-runtime-framework)
		* [UI Drawing / Output functions](#ui-drawing--output-functions)
		* [Other Utilities](#other-utilities)
* [Usage](#usage)
	* [Integrating With Your Project](#integrating-with-your-project)
	* [Installation](#installation)
	* [Detecting If Your Script is &quot;Sourced In&quot; or &quot;Ran&quot;](#detecting-if-your-script-is-quotsourced-inquot-or-quotranquot)
	* [The List of Available Functions](#the-list-of-available-functions)
	* [Naming Conventions](#naming-conventions)
* [Unit Testing](#unit-testing)
* [How To?](#how-to)
	* [How To Change Underscan or Overscan for Old Monitors](#how-to-change-underscan-or-overscan-for-old-monitors)
	* [Contributing](#contributing)

<!-- /TOC -->

## Bootstrap Install

Perhaps the easiest way to install BashMatic is using this bootstrapper:

First, make sure you have Curl installed. Then:

```bash
eval "$(curl -fsSL http://bit.ly/bashmatic-v0-1-0)"
```

This not only will check out bashmatic into ~/.bashmatic, but will also add the enabling hook to your ~/.bashrc file.

After running the above, run `bashmatic.functions` function to see all available functions.


## Manual Install

For the impatient, here is how to install BashMatic very quickly and easily:

```bash
cd ~/
git clone https://github.com/kigster/bashmatic .bashmatic
source ~/.bashmatic/init.sh
bashmatic.load-at-login
```

When you run the `bashmatic.load-at-login` function, it will add a bashmatic hook to one of your BASH initialization files, so all of its functions are available in your shell.

The output of this function may look like this:

```
┌──────────────────────────────────
│ Adding BashMatic auto-loader to /Users/<your-username>/.bashrc...  │
└──────────────────────────────────
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

...afp.servers                                    lib::docker::actions::push
...http.servers                                   lib::docker::actions::setup
...https.servers                                  lib::docker::actions::start
...net.fast-scan                                  lib::docker::actions::stop
...net.local-subnet                               lib::docker::actions::tag
...ssh.servers                                    lib::docker::actions::up
...stack.frame                                    lib::docker::actions::update
7z.a                                              lib::docker::build::container
7z.x                                              lib::docker::last-version
abort                                             lib::docker::next-version
ansi                                              lib::file::exists_and_newer_than
array-bullet-list                                 lib::file::gsub
array-contains-element                            lib::file::install_with_backup
array-csv                                         lib::file::last-modified-date
array-join                                        lib::file::last-modified-year
array-piped                                       lib::gem::cache-installed
ascii-clean                                       lib::gem::cache-refresh
aws.rds::hostname                                 lib::gem::configure-cache
aws.s3.upload                                     lib::gem::ensure-gem-version
bashmatic-set-fqdn                                lib::gem::gemfile::version
bashmatic-term                                    lib::gem::global::latest-version
bashmatic-term-program                            lib::gem::global::versions
bashmatic.functions                               lib::gem::install
bashmatic.load-at-login                           lib::gem::is-installed
bashmatic.reload                                  lib::gem::uninstall
bashmatic::detect-subshell                        lib::gem::version
bashmatic::validate-sourced-in                    lib::git::remotes
bashmatic::validate-subshell                      lib::git::repo-is-clean
bold                                              lib::json::begin-array
box::blue-in-green                                lib::json::begin-hash
box::blue-in-yellow                               lib::json::begin-key
box::green-in-cyan                                lib::json::end-array
box::green-in-green                               lib::json::end-hash
box::green-in-magenta                             lib::json::file-to-array
box::green-in-yellow                              lib::osx::cookie-dump
box::magenta-in-blue                              lib::osx::env-print
box::magenta-in-green                             lib::osx::local-servers
box::red-in-magenta                               lib::osx::ramdisk::mount
box::red-in-red                                   lib::osx::ramdisk::unmount
box::red-in-yellow                                lib::osx::scutil-print
box::yellow-in-blue                               lib::osx::set-fqdn
box::yellow-in-red                                lib::output::color::off
box::yellow-in-yellow                             lib::output::color::on
br                                                lib::output::is_pipe
center                                            lib::output::is_redirect
change-underscan                                  lib::output::is_ssh
cookie-dump                                       lib::output::is_terminal
cursor.at.x                                       lib::output::is_tty
cursor.at.y                                       lib::progress::bar
cursor.down                                       lib::psql::db-settings
cursor.left                                       lib::ruby::install-ruby-with-deps
cursor.rewind                                     lib::run
cursor.right                                      lib::run::ask
cursor.up                                         lib::run::inspect
debug                                             lib::run::inspect-variable
decrypt.secrets                                   lib::run::inspect-variables
duration                                          lib::run::inspect-variables-that-are
epoch                                             lib::run::inspect::set-skip-false-or-blank
err                                               lib::run::print-variable
error                                             lib::run::print-variables
error-text                                        lib::run::variables-ending-with
error:                                            lib::run::variables-starting-with
file::list::filter-existing                       lib::run::with-min-duration
file::list::filter-non-empty                      lib::ssh::load-keys
file::size                                        lib::time::date-from-epoch
file::size::mb                                    lib::time::duration::humanize
file::stat                                        lib::time::epoch-to-iso
ftrace-in                                         lib::time::epoch-to-local
ftrace-off                                        lib::time::epoch::minutes-ago
ftrace-on                                         lib::trap-setup
ftrace-out                                        lib::trap-was-fired
g-i                                               lib::trapped
g-u                                               lib::url::downloader
gem.clear-cache                                   lib::url::http-code
gvim.off                                          lib::url::is-valid
gvim.on                                           lib::url::shorten
h1                                                lib::url::valid-status
h1::blue                                          lib::user
h1::green                                         lib::user::finger::name
h1::purple                                        lib::user::first
h1::red                                           lib::user::gitconfig::email
h1::yellow                                        lib::user::gitconfig::name
h2                                                lib::user::host
h2::green                                         lib::user::my::ip
h3                                                lib::user::my::reverse-ip
h::black                                          lib::user::username
h::blue                                           lib::util::append-to-init-files
h::green                                          lib::util::arch
h::red                                            lib::util::call-if-function
h::yellow                                         lib::util::checksum::files
hb::crypt::chef                                   lib::util::checksum::stdin
hb::decrypt::file                                 lib::util::functions-matching
hb::decrypt::str                                  lib::util::generate-password
hb::edit::file                                    lib::util::i-to-ver
hb::encrypt::file                                 lib::util::install-direnv
hb::encrypt::str                                  lib::util::is-a-function
hb::sym                                           lib::util::is-numeric
hbsed                                             lib::util::is-variable-defined
hdr                                               lib::util::lines-in-folder
hl::blue                                          lib::util::remove-from-init-files
hl::desc                                          lib::util::shell-init-files
hl::green                                         lib::util::shell-name
hl::orange                                        lib::util::ver-to-i
hl::subtle                                        lib::util::whats-installed
hl::white-on-orange                               lib::vim::gvim-off
hl::white-on-salmon                               lib::vim::gvim-on
hl::yellow                                        lib::vim::setup
hl::yellow-on-gray                                lib::yaml::diff
hl::yellow-on-gray                                lib::yaml::dump
hr::colored                                       lib::yaml::expand-aliases
inf                                               long-pause
info                                              millis
info:                                             not_ok
is_ask_on_error                                   not_ok:
is_detail                                         odie
is_verbose                                        ok
italic                                            ok:
jm::jemalloc::detect-loud                         okay
jm::jemalloc::detect-quiet                        onoe
jm::jemalloc::stats                               pall
jm::ruby::detect                                  pause
jm::ruby::report                                  pid::alive
jm::usage                                         pid::sig
kind_of_ok                                        pid::stop
kind_of_ok:                                       pids-with-args
left                                              pids::all
lib::7z::install                                  pids::for-each
lib::7z::unzip                                    pids::matching
lib::7z::zip                                      pids::matching::regexp
lib::array::complain-unless-includes              pids::normalize::search-string
lib::array::contains-element                      pids::stop
lib::array::exit-unless-includes                  ppids
lib::array::from-command-output                   press-any-key-to-continue
lib::array::join                                  pstop
lib::array::piped                                 puts
lib::audio::wav-to-mp3                            red
lib::audio::wave-file-frequency                   reset-color
lib::brew::cache-reset                            reset-color:
lib::brew::cache-reset::delayed                   run
lib::brew::cask::is-installed                     run::inspect
lib::brew::cask::list                             run::set-all
lib::brew::cask::tap                              run::set-all::list
lib::brew::install                                run::set-next
lib::brew::install::cask                          run::set-next::list
lib::brew::install::package                       safe_cd
lib::brew::install::packages                      screen-width
lib::brew::package::is-installed                  screen.height
lib::brew::package::list                          screen.width
lib::brew::reinstall::package                     set-e-restore
lib::brew::reinstall::packages                    set-e-save
lib::brew::relink                                 set-e-status
lib::brew::setup                                  short-pause
lib::brew::uninstall::package                     shortish-pause
lib::brew::uninstall::packages                    shutdown
lib::brew::upgrade                                sig::is-valid
lib::cache-or-command                             sig::list
lib::caller::stack                                stderr
lib::color::disable                               stdout
lib::color::enable                                strikethrough
lib::db::datetime                                 success
lib::db::dump                                     sym::hb::configure
lib::db::num_procs                                sym::hb::files
lib::db::psql-args                                sym::hb::have_key
lib::db::psql::args::                             sym::hb::import
lib::db::psql::args::default                      sym::hb::install-shell-helpers
lib::db::psql::args::maint                        sym::install::symit
lib::db::rails::schema::checksum                  today
lib::db::rails::schema::file                      txt-err
lib::db::restore                                  txt-info
lib::db::top                                      txt-warn
lib::db::wait-until-db-online                     underline
lib::deploy::slack                                warn
lib::deploy::slack-ding                           warning
lib::deploy::validate-vpn                         warning:
lib::dir::count-slashes                           watch-ls-al
lib::dir::expand-dir                              with-bundle-exec
lib::dir::is-a-dir                                with-bundle-exec-and-output
lib::docker::abort_if_down                        with-min-duration
lib::docker::actions::build                       yaml-diff
lib::docker::actions::clean                       yaml-dump
lib::docker::actions::pull
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
