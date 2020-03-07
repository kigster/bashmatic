
[![Build Status](https://travis-ci.org/kigster/bashmatic.svg?branch=master)](https://travis-ci.org/kigster/bashmatic)

# BashMatic

> BashMatic is an ever-growing framework of Bash Script runners, auto-retrying, repeatable, DSL-controlled
> functions for every occasion, from drawing boxes and yelling at the user, to running complicated setup flows.
> Start exploring by installing it, and then running `bashmatic.functions` function, to see all available
> BASH functions added to your Shell by the framework.

<!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->
* [DAFAQ is BashMatic?](#dafaq-is-bashmatic)
* [Installing](#installing)
	* [Bootstrapping Bashmatic](#bootstrapping-bashmatic)
	* [Installing Manually](#installing-manually)
* [Usage](#usage)
	* [Function Naming Convention Unpacked](#function-naming-convention-unpacked)
	* [Seeing All Functions](#seeing-all-functions)
	* [Seeing Specific Functions](#seeing-specific-functions)
	* [Various Modules](#various-modules)
	* [Key Modules Explained](#key-modules-explained)
		* [1. Runtime](#1-runtime)
			* [Runtime Framework in Depth](#runtime-framework-in-depth)
			* [Examples of Runtime Framework](#examples-of-runtime-framework)
		* [2. Output Modules](#2-output-modules)
			* [Output Components](#output-components)
			* [Output Helpers](#output-helpers)
		* [3. Package management: Brew and RubyGems](#3-package-management-brew-and-rubygems)
		* [4. Shortening URLs](#4-shortening-urls)
		* [5. File Helpers](#5-file-helpers)
		* [6. Array Helpers](#6-array-helpers)
		* [7. Utilities](#7-utilities)
		* [8. Additional Helpers](#8-additional-helpers)
* [How To ... Guide.](#how-to--guide)
	* [How to integrate Bashmatic with an existing project?](#how-to-integrate-bashmatic-with-an-existing-project)
	* [How can I test if the function was ran as part of a script, or "sourced-in"?](#how-can-i-test-if-the-function-was-ran-as-part-of-a-script-or-sourced-in)
	* [How do I run unit tests for BashMatic?](#how-do-i-run-unit-tests-for-bashmatic)
	* [How can I change the underscan or overscan for an old monitor?](#how-can-i-change-the-underscan-or-overscan-for-an-old-monitor)
	* [Contributing](#contributing)
<!-- /TOC -->

## DAFAQ is BashMatic?

BashMatic is a collection of BASH convenience functions that make BASH programming fun (again? forever? always?).

I mean, check this out — given this tiny four-line script:

```bash
h2 "Installing ruby gem sym and brew package curl..." \
   "Please standby..."
gem.install "sym" && brew.install.package "curl"
success "installed sym ruby gem, version $(gem.version sym)"
```

yields this  functionality and the gorgeous output:

![example](.bashmatic-example.png)

Tell me you are not at all excited to start writing complex installation flows in BASH right away?

Not only you get pretty output, but you can each executed command, it's exit status, whether it's been successful (green/red), as well each command's bloody duration in milliseconds. What's not to like?!? 😂

## Installing

Perhaps the easiest way to install BashMatic is using this boot-strapping script.

### Bootstrapping Bashmatic

First, make sure that you have Curl installed, run `which curl` to see. Then copy/paste this command into your Terminal:

```bash
❯ eval "$(curl -fsSL http://bit.ly/bashmatic-v0-1-0)"
```

This not only will check out bashmatic into `~/.bashmatic`, but will also add the enabling hook to your `~/.bashrc` file.

Restart your shell, and make sure that when you type `bashmatic.version` in the command line (and press Enter) you see the version number printed like so:

```bash
❯ bashmatic.version
0.2.0
```

If you get an error, perhaps Bashmatic did not properly install.

### Installing Manually

For the impatient, here is how to install BashMatic very quickly and easily:

```bash
❯ git clone git@//github.com:kigster/bashmatic ~/.bashmatic
❯ source ~/.bashmatic/init.sh
❯ bashmatic.load-at-login
```

When you run the `bashmatic.load-at-login` function, it will add a bashmatic hook to one of your BASH initialization files, so all of its functions are available in your shell.

The output of this function may look like this:

```
┌──────────────────────────────────
│ Adding BashMatic auto-loader to /Users/<your-username>/.bashrc...  │
└──────────────────────────────────
```

You can always reload BashMatic with `bashmatic.reload` function.

## Usage

Welcome to **BashMatic** — an ever growing collection of scripts and mini-bash frameworks for doing all sorts of things quickly and efficiently.

We have adopted the [Google Bash Style Guide](https://google.github.io/styleguide/shell.xml), and it's recommended that anyone committing to this repo reads the guides to understand the conventions, gotchas and anti-patterns.

### Function Naming Convention Unpacked

Bashmatic provides a large number of functions, which are all loaded in your current shell. The functions are split into two fundamental groups:

 * Functions with names beginning with a `.` are considered "private" functions, for example `.run.env` and `.run.initializer`
 * All other functions are considered public.

The following conventions apply to all functions:

 * We use the "dot" for separating namespaces, hence `git.sync` and `gem.install`.
 * Function names should be self-explanatory and easy to read.
 * DO NOT abbreviate words.
 * All public functions must be written defensively: i.e. if the function is called from the Terminal without any arguments, and it requires arguments, the function *must print its usage info* and a meaningful error message.

For instance:

```bash
❯ gem.install
┌─────────────────────────────────────────────────────────────────────────────┐
│  « ERROR »  Error — gem name is required as an argument                     │
└─────────────────────────────────────────────────────────────────────────────┘
❯ gem.install simple-feed
       installing simple-feed (latest)...
  ✔︎    ❯ gem install simple-feed   ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪〔   5685 ms 〕    0
  ✔︎    ❯ gem list > /tmp/.bashmatic/.gem/gem.list ▪▪▪▪▪▪〔    503 ms 〕    0
```


The naming convention we use is a derivative of Google's Bash StyleGuide, using `.` to separate BASH function namespaces instead of much more verbose `::`.

### Seeing All Functions

After running the above, run `bashmatic.functions` function to see all available functions. You can also open the [FUNCTIONS.md](FUNCTIONS.md) file to see the alphabetized list of all 422 functions.

### Seeing Specific Functions

To get a list of module or pattern-specific functions installed by the framework, run the following:

```bash
❯ bashmatic.functions-from pattern [ columns ]
```
For instance:

```bash
❯ bashmatic.functions-from docker 2
docker.abort-if-down                    docker.build.container
docker.actions.build                    docker.containers.clean
.......
docker.actions.update
```

### Various Modules

You can list various modules by listing the `lib` sub-directory of the `~/.bashmatic` folder.

Note how we use Bashmatic helper `columnize [ columns ]` to display a long list in five columns.

```bash
❯ ls -1 ~/.bashmatic/lib | sed 's/\.sh//g' | columnize 5
7z                deploy            jemalloc          runtime-config    time
array             dir               json              runtime           trap
audio             docker            net               set               url
aws               file              osx               set               user
bashmatic         ftrace            output            settings          util
brew              gem               pids              shell-set         vim
caller            git-recurse-updat progress-bar      ssh               yaml
color             git               ruby              subshell
db                hbsed             run               sym
```

### Key Modules Explained

At a high level, the following modules are provided, in order of importance:

#### 1. Runtime

The following files provide this functionality:

 * `lib/run.sh`
 * `lib/runtime.sh`
 * `lib/runtime-config.sh`.

These collectively offer the following functions:

```bash
❯ bashmatic.functions-from 'run*'

run                                         run.set-all
run.config.detail-is-enabled                run.set-all.list
run.config.verbose-is-enabled               run.set-next
run.inspect                                 run.set-next.list
run.inspect-variable                        run.ui.ask
run.inspect-variables                       run.ui.press-any-key
run.inspect-variables-that-are              run.variables-ending-with
run.inspect.set-skip-false-or-blank         run.variables-starting-with
run.on-error.ask-is-enabled                 run.with.minimum-duration
run.print-variable                          run.with.ruby-bundle
run.print-variables                         run.with.ruby-bundle-and-output
```

Using these functions you can write powerful shell scripts that display each command they run, it's status, duration, and can abort on various conditions. You can ask the user to confirm, and you can show a user message and wait for any key pressed to continue.

To learn more about this key module, please go to the [Runtime Framework](#runtime-framework) section.

##### Runtime Framework in Depth

One of the core tenets of this library is it's "runtime" framework, which offers a way to run and display commands as they run, while having a fine-grained control over the following:

 * What happens when one of the commands fails? Options include:
   * Ignore and continue (default) — *continue-on-error*
   * Ask the user if she wants to proceed — *ask-on-error*
   * Abort the entire run — *abort-on-error*.
 * How is command output displayed?
   * Is it swallowed for compactness, and only shown if there is an error? (default) — *show-output-off*
   * Or is it shown regardless? — *show-output-on*
 * Should commands actually run (*dry-run-off*), or simply be printed? (*dry-run-on*).

##### Examples of Runtime Framework

> NOTE, in the following examples we assume you installed the library into your project's folder as `.bashmatic` (a "hidden" folder starting with a dot).

Programming style used in this project lends itself nicely to using a DSL-like approach to shell programming.  For example, in order to configure the behavior of the run-time framework (see below) you would run the following command:

```bash
#!/usr/bin/env bash

# (See below on the location of .bashmatic and ways to install it)
source ~/.bashmatic/init.sh

# configure global behavior of all run() invocations
run.set-all abort-on-error show-output-off

run "git clone https://gthub.com/user/rails-repo rails"
run "cd rails"
run "bundle check || bundle install"

# the following configuration only applies to the next invocation of `run()`
# and then resets back to `off`
run.set-next show-output-on
run "bundle exec rspec"
```

And most importantly, you can use our fancy UI drawing routines to communicate with the user, which are based on familiar HTML constructs, such as `h1`, `h2`, `hr`, etc.

#### 2. Output Modules

The `lib/output.sh` module does all of the heavy lifting with providing many UI elements, such as frames, boxes, lines, headers, and many more.

Here is the list of functions in this module:

```bash
❯ bashmatic.functions-from output 3
abort                          error:                         left-prefix
ascii-clean                    h.black                        ok
box.blue-in-green              h.blue                         okay
box.blue-in-yellow             h.green                        output.color.off
box.green-in-cyan              h.red                          output.color.on
box.green-in-green             h.yellow                       output.is_pipe
box.green-in-magenta           h1                             output.is_redirect
box.green-in-yellow            h1.blue                        output.is_ssh
box.magenta-in-blue            h1.green                       output.is_terminal
box.magenta-in-green           h1.purple                      output.is_tty
box.red-in-magenta             h1.red                         puts
box.red-in-red                 h1.yellow                      reset-color
box.red-in-yellow              h2                             reset-color:
box.yellow-in-blue             h2.green                       screen-width
box.yellow-in-red              h3                             screen.height
box.yellow-in-yellow           hdr                            screen.width
br                             hl.blue                        shutdown
center                         hl.desc                        stderr
columnize                      hl.green                       stdout
command-spacer                 hl.orange                      success
cursor.at.x                    hl.subtle                      test-group
cursor.at.y                    hl.white-on-orange             ui.closer.kind-of-ok
cursor.down                    hl.white-on-salmon             ui.closer.kind-of-ok:
cursor.left                    hl.yellow                      ui.closer.not-ok
cursor.rewind                  hl.yellow-on-gray              ui.closer.not-ok:
cursor.right                   hr                             ui.closer.ok:
cursor.up                      hr.colored                     warn
debug                          inf                            warning
duration                       info                           warning:
err                            info:
error                          left
```

Note that some function names end with `:` — this indicates that the function outputs a new-line in the end. These functions typically exist together with their non-`:`-terminated counter-parts.  If you use one, eg, `inf`, you are then supposed to finish the line by providing an additional output call, most commonly it will be one of `ok:`, `ui.closer.not-ok:` and `ui.closer.kind-of-ok:`.

Here is an example:

```bash
function valid-cask()  { sleep 1; return 0; }
function verify-cask() {
  inf "verifying brew cask ${1}...."
  if valid-cask ${1}; then
    ui.closer.ok:
  else
    ui.closer.not-ok:
  fi
}
```

When you run this, you should see something like this:

```bash
 ❯ verify-cask TextMate
  ✔︎    verifying brew cask TextMate....
```

In the above example, you see the checkbox appear to the left of the text. In fact, it appears a second after, right as `sleep 1` returns. This is because this paradigm is meant for wrapping constructs that might succeed or fail.

If we change the `valid-cask` function to return a failure:

```bash
function valid-cask()  { sleep 1; return 1; }
```

Then this is what we'd see:

```bash
❯ verify-cask TextMate
  ✘    verifying brew cask TextMate....
```

##### Output Components

Components are BASH functions that draw something concrete on the screen. For instance, all functions starting with `box.` are components, as are `h1`, `h2`, `hr`, `br` and more.

```bash
❯ h1 Hello

┌─────────────────────────────────────────────────────────────────────────────────┐
│ Hello                                                                           │
└─────────────────────────────────────────────────────────────────────────────────┘
```

These are often named after HTML elements, such as `hr`, `h1`, `h2`, etc.

##### Output Helpers

Here is another example where we are deciding whether to print something based on whether the output is a proper terminal (and not a pipe or redirect):

```
output.is_tty && h1 "Yay For Terminals!"
```

The above reads more like a high level language like Ruby or Python than Shell. That's because BASH is more powerful than most people think.

There is an [example script](examples/test-ui.sh) that demonstrates the capabilities of BashMatic.

If you ran the script, you should see the output shown [in this screenshot](.bashmatic.png). Your colors may vary depending on what color scheme and font you use for your terminal.

#### 3. Package management: Brew and RubyGems

You can reliably install ruby gems or brew packages with the following syntax:

```bash
#!/usr/bin/env bash

source ~/.bashmatic/init.sh

h2 "Installing ruby gem sym and brew package curl..." \
   "Please standby..."

gem.install sym
brew.install.package curl

success "installed Sym version $(gem.version sym)"
```


When you run the above script, you shyould seee the following output:

![example](.bashmatic-example.png)

#### 4. Shortening URLs

You can shorten URLs on the command line using Bitly, but for this to work, you must set the following environment variables in your shell init:

```bash
export BITLY_LOGIN="<your login>"
export BITLY_API_KEY="<your api key>"
```

Then you can run it like so:

```bash
❯ url.shorten https://raw.githubusercontent.com/kigster/bashmatic/master/bin/install
# http://bit.ly/2IIPNE1
```

#### 5. File Helpers

```bash
❯ bashmatic.functions-from file
file.list.filter-existing                  file.exists_and_newer_than
file.list.filter-non-empty                 file.gsub
file.size                                   file.install_with_backup
file.size.mb                               file.last-modified-date
file.source-if-exists                       file.last-modified-year
file.stat
```

For instance, `file.stat` offers access to the `fstat()` C-function:

```bash
 ❯ file.stat README.md st_size
22799
```

#### 6. Array Helpers

```bash
❯ bashmatic.functions-from array
array-bullet-list                            array.contains-element
array-contains-element                       array.exit-unless-includes
array-csv                                    array.from-command-output
array-join                                   array.join
array-piped                                  array.piped
array.complain-unless-includes
```

For instance:

```bash
❯ declare -a farm_animals=(chicken duck rooster pig)
❯ array-bullet-list ${farm_animals[@]}
 • chicken
 • duck
 • rooster
 • pig
❯ array.contains-element "duck" "${farm_animals[@]}" && echo Yes || echo No
Yes
❯ array.contains-element  "cow" "${farm_animals[@]}" && echo Yes || echo No
No
```

#### 7. Utilities

The utilities module has the following functions:

```bash
❯ bashmatic.functions-from util
is-func                                      util.is-variable-defined
util.append-to-init-files              util.lines-in-folder
util.arch                              util.remove-from-init-files
util.call-if-function                  util.shell-init-files
util.checksum.files                   util.shell-name
util.checksum.stdin                   util.ver-to-i
util.functions-matching                util.whats-installed
util.generate-password                 long-pause
util.i-to-ver                          pause
util.install-direnv                    short-pause
util.is-a-function                     shortish-pause
util.is-numeric                        watch-ls-al
```

For example, version helpers can be very handy in automated version detection, sorting and identifying the latest or the oldest versions:

```bash
❯ util.ver-to-i '12.4.9'
112004009
❯ util.i-to-ver $(util.ver-to-i '12.4.9')
12.4.9

```

#### 8. Additional Helpers

There are plenty more modules, that help with:

 * [Ruby Version Helpers](lib/ruby.sh) and (Ruby Gem Helpers)[lib/gem.sh], that can extract curren gem version from either `Gemfile.lock` or globally installed gem list..
 * [AWS helpers](lib/aws.sh) — requires `awscli` and credentials setup, and offers some helpers to simplify AWS management.

 * [Docker Helpers](lib/docker.sh) — assist with docker image building and pushing/pulling
 * [Sym](lib/sym.sh) — encryption with the gem called [`sym`](https://github.com/kigster/sym)

And many more.

See the full function index with the function implementation body in the [FUNCTIONS.md](FUNCTIONS.md) index.

----

## How To ... Guide.

There are a couple of ways that you can install and use this library.

   1. The simplest way is to use the online bootstrap script.  This method is often used to integrate **BashMatic** with your other projects, so that they can be built upon their own internal BASH tooling using all the goodies in this library.

   1. One is doing a simple manual `git clone`, and then "sourcing" the main `init.sh` file from one of your "dotfiles".

### How to integrate Bashmatic with an existing project?

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

### How can I test if the function was ran as part of a script, or "sourced-in"?

Some bash files exists as libraries to be "sourced in", and others exist as scripts to be run. But users won't always know what is what, and may try to source in a script that should be run, or vice versa — run a script that should be sourced in.

What do you, programmer, do to educate the user about correct usage of your script/library?

BashMatic offers a reliable way to test this:

```bash
#!/usr/bin/env bash
# load library
if [[ -f "${BashMatic__Init}" ]]; then source "${BashMatic__Init}"; else source ~/.bashmatic/init.sh; fi
bashmatic.validate-subshell || return 1
```

If you'd rather require a library to be sourced in, but not run, use the code as follows:

```bash
#!/usr/bin/env bash
# load library
if [[ -f "${BashMatic__Init}" ]]; then source "${BashMatic__Init}"; else source ~/.bashmatic/init.sh; fi
bashmatic.validate-sourced-in || exit 1
```

### How do I run unit tests for BashMatic?

The framework comes with a bunch of automated unit tests based on the fantastic framework [`bats`](https://github.com/sstephenson/bats.git).

To run all tests:

```bash
cd ~/.bashmatic
bin/specs
```

While not every single function is tested (far from it), we do try to add tests to the critical ones.

Please see [existing tests](https://github.com/kigster/bashmatic/tree/master/test) for the examples.

### How can I change the underscan or overscan for an old monitor?

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
