
[![Build Status](https://travis-ci.org/kigster/bashmatic.svg?branch=master)](https://travis-ci.org/kigster/bashmatic)

# BashMatic

<!-- TOC START min:2 max:4 link:true update:true -->
- [Reusable BASH Components for UI, Runtime, Ruby, Database and More](#reusable-bash-components-for-ui-runtime-ruby-database-and-more)
  - [Whats Included?](#whats-included)
    - [Runtime Framework](#runtime-framework)
    - [Examples of Runtime Framework](#examples-of-runtime-framework)
    - [UI Drawing / Output functions](#ui-drawing--output-functions)
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

<!-- TOC END -->

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

Each library will have a set of private functions, typically named `__lib::util::blah`, and public functions, named as `lib::util::foo`, with shortcuts such as `foo` created when makes sense.

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

### 2. Manual Install

```bash
cd ~/workspace
git clone https://github.com/kigster/bashmatic
cd workspace/bashmatic
source lib/Loader.bash
```

#### Custom Installer

Alternatively, you can always do something like this instead:

```bash
git clone https://github.com/kigster/bashmatic .bashmatic
source .bashmatic/lib/Loader.bash
# Now all functions are availble to you.
```

### Some Tips on Writing Shell Scripts

Some bash files exists as libraries to be "sourced in", and others exist as scripts to be run. But users won't always know what is what, and may try to source in a script that shoudl be run, or vice versa — run a script that should be sourced in.

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
array-contains-element              lib::json::begin-key
lib::array::contains-element        lib::json::begin-hash
lib::array::complain-unless-include lib::json::end-hash
lib::array::exit-unless-includes    lib::osx::cookie-dump
lib::array::join                    cookie-dump
array-join                          lib::osx::display::change-underscan
lib::array::join-piped              lib::osx::ramdisk::mount
array-join-piped                    lib::osx::ramdisk::unmount
aws::rds::hostname                  lib::progress::bar
lib::brew::cache-reset              lib::ruby::gemfile-lock-version
lib::brew::cache-reset::delayed     lib::ruby::bundler-version
lib::brew::upgrade                  lib::ruby::version
lib::brew::install                  run
lib::brew::setup                    run::set-next
lib::brew::relink                   run::set-all
lib::brew::package::list            run::set-next::list
lib::brew::cask::list               run::set-all::list
lib::cache-or-command               run::inspect
lib::brew::package::is-installed    lib::run::with-min-duration
lib::brew::cask::is-installed       lib::run::ask
lib::brew::reinstall::package       lib::run::inspect::set-skip-false-o
lib::brew::install::package         lib::run::inspect-variable
lib::brew::install::cask            lib::run::print-variable
lib::brew::uninstall::package       lib::run::inspect-variables
lib::brew::install::packages        lib::run::print-variables
lib::brew::reinstall::packages      lib::run::variables-starting-with
lib::brew::uninstall::packages      lib::run::variables-ending-with
lib::psql::db-settings              lib::run::inspect-variables-that-ar
lib::db::psql::args::               lib::run::inspect
lib::db::psql-args                  lib::run
lib::db::psql::args::default        with-min-duration
lib::db::psql::args::maint          with-bundle-exec
lib::db::wait-until-db-online       with-bundle-exec-and-output
lib::db::datetime                   onoe
lib::db::rails::schema::file        odie
lib::db::rails::schema::checksum    lib::ssh::load-keys
lib::db::top                        sym::hb::install-shell-helpers
lib::db::dump                       sym::install::symit
lib::db::restore                    sym::hb::configure
lib::deploy::validate-vpn           sym::hb::import
lib::deploy::slack                  sym::hb::files
lib::deploy::slack-ding             hb::crypt::chef
lib::docker::last-version           hb::sym
lib::docker::next-version           hb::encrypt::str
lib::docker::build::container       hb::decrypt::str
lib::docker::actions::build         hb::encrypt::file
lib::docker::actions::clean         hb::edit::file
lib::docker::actions::up            hb::decrypt::file
lib::docker::actions::start         lib::time::date-from-epoch
lib::docker::actions::stop          lib::time::epoch-to-iso
lib::docker::actions::pull          lib::time::epoch-to-local
lib::docker::actions::tag           lib::time::epoch::minutes-ago
lib::docker::actions::push          lib::time::duration::humanize
lib::docker::actions::setup         epoch
lib::docker::actions::update        millis
lib::file::last-modified-date       today
lib::file::last-modified-year       lib::url::shorten
file::stat                          lib::url::downloader
file::size                          lib::user::gitconfig::email
file::size::mb                      lib::user::gitconfig::name
file::list::filter-existing         lib::user::finger::name
file::list::filter-non-empty        lib::user::username
ftrace-on                           lib::user
ftrace-off                          lib::user::first
ftrace-in                           lib::user::my::ip
ftrace-out                          lib::user::my::reverse-ip
lib::gem::version                   lib::user::host
lib::gem::global::versions          lib::util::is-variable-defined
lib::gem::global::latest-version    lib::util::generate-password
lib::gem::gemfile::version          lib::util::is-numeric
lib::gem::cache-installed           lib::util::ver-to-i
lib::gem::cache-refresh             lib::util::i-to-ver
lib::gem::ensure-gem-version        lib::util::shell-name
lib::gem::is-installed              lib::util::arch
lib::gem::install                   lib::util::shell-init-files
lib::gem::uninstall                 lib::util::append-to-init-files
g-i                                 lib::util::remove-from-init-files
g-u                                 lib::util::whats-installed
hbsed                               lib::util::lines-in-folder
lib::json::begin-array              lib::util::functions-matching
lib::json::end-array                lib::util::checksum::files
lib::json::file-to-array            lib::util::install-direnv

```

### Naming Conventions

We use the following naming conventions:

 1. Namespaces are separated by `::`
 2. Private functions are prefixed with `__`, eg `__lib::output::hr1`
 3. Public functions do not need to be namespaced, or be prefixed with `__`

### Writing tests

We are using [`bats`](https://github.com/sstephenson/bats.git) for unit testing.

While not every single function is tested (far from it), we do try to add tests to the critical ones.

Please see [existing tests](https://github.com/kigster/bashmatic/tree/master/test) for the examples.

## Helpful Scripts

### Changing OSX Underscan for Old Monitors

If you are stuck working on a monitor that does not support switching digit input from TV to PC, NOR does OS-X show the "underscan" slider in the Display Preferences, you may be forced to change the underscan manually. The process is a bit tricky, but we have a helpful script to do that:

```bash
$ source lib/Loader.bash
$ lib::osx::display::change-underscan 5
```

This will reduce underscan by 5% compared to the current value. The total value is 10000, and is stored in the file `/var/db/.com.apple.iokit.graphics`. The tricky part is determining which of the display entries map to your problem monitor. This is what the script helps with.

Do not forget to restart after the change.

Acknowledgements: the script is an automation of the method offered on [this blog post](http://ishan.co/external-monitor-underscan).

### Contributing

Submit a pull request!
