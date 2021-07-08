

---


## File `lib/file.sh`



* [file.temp()](#filetemp)
* [file.normalize-files()](#filenormalize-files)
* [file.ask.if-exists()](#fileaskif-exists)
* [file.install-with-backup()](#fileinstall-with-backup)

### `file.temp()`

Creates a temporary file and returns it as STDOUT
shellcheck disable=SC2120

### `file.normalize-files()`

This function will rename all files passed to it as follows: spaces
are replaced by dashes, non printable characters are removed,
and the filename is lower cased. 

#### Example

```bash
file.normalize-files "My Word Document.docx" 
# my-word-document.docx
       
```

### `file.ask.if-exists()`

Ask the user whether to overwrite the file

### `file.install-with-backup()`

Installs a given file into a provided destination, while
making a copy of the destination if it already exists.

#### Example

```bash
file.install-with-backup conf/.psqlrc ~/.psqlrc backup-strategy-function
```

#### Arguments

* @arg1 File to backup
* @arg2 Destination
* @arg3 [optional] Shortname of the optional backup strategy: 'bak' or 'folder'. 



---


## File `lib/pids.sh`



* [pids.stop-by-listen-tcp-ports()](#pidsstop-by-listen-tcp-ports)
* [pid.stop-if-listening-on-port()](#pidstop-if-listening-on-port)

### `pids.stop-by-listen-tcp-ports()`

Finds any PID listening on one of the provided ports and stop thems.

#### Example

```bash
pids.stop-by-listen-tcp-ports 4232 9578 "${PORT}"
```

### `pid.stop-if-listening-on-port()`

Finds any PID listening the one port and an optional protocol (tcp/udp)

#### Example

```bash
pid.stop-if-listening-on-port 3000 tcp
pid.stop-if-listening-on-port 8126 udp
```



---


## File `lib/bashit.sh`



* [bashit-prompt-terraform()](#bashit-prompt-terraform)
* [bashit-install()](#bashit-install)

### `bashit-prompt-terraform()`

Possible Bash It Powerline Prompt Modules

aws_profile
battery
clock
command_number
cwd
dirstack
gcloud
go
history_number
hostname
in_toolbox
in_vim
k8s_context
last_status
node
python_venv
ruby
scm
shlvl
terraform
user_info
wd

### `bashit-install()`

Installs Bash-It Framework



---


## File `lib/array.sh`



* [array.has-element()](#arrayhas-element)
* [array.includes()](#arrayincludes)
* [array.join()](#arrayjoin)
* [array.sort()](#arraysort)
* [array.sort-numeric()](#arraysort-numeric)
* [array.min()](#arraymin)
* [array.force-range()](#arrayforce-range)
* [array.max()](#arraymax)
* [array.uniq()](#arrayuniq)
* [array.from.command()](#arrayfromcommand)

### `array.has-element()`

Returns "true" if the first argument is a member of the array
passed as the second argument:

#### Example

```bash
$ declare -a array=("a string" test2000 moo)
if [[ $(array.has-element "a string" "${array[@]}") == "true" ]]; then
  ...
fi
```

### `array.includes()`

Similar to array.has-elements, but does not print anything, just
returns 0 if includes, 1 if not.

### `array.join()`

Joins a given array with a custom string.

#### Example

```bash
$ declare -a array=(one two three)
$ array.join "," "${array[@]}"
$ array.join " —> " true "${array[@]}"
—> one
—> two
—> three
```

#### Arguments

* @arg1 
* @arg2 
* @arg3 .

### `array.sort()`

Sorts the array alphanumerically and prints it to STDOUT

#### Example

```bash
declare -a unsorted=(hello begin again again)
local sorted="$(array.sort "${unsorted[@]}")"
```

### `array.sort-numeric()`

Sorts the array numerically and prints it to STDOUT

#### Example

```bash
declare -a unsorted=(1 2 34 45 6)
local sorted="$(array.sort-numeric "${unsorted[@]}")"
```

### `array.min()`

Returns a minimum integer from an array.
Non-numeric elements are ignored and skipped over.
Negative numbers are supported, but non-integers are not.

#### Example

```bash
$ declare -a array=(10 20 30 -5 5)
$ array.min "," "${array[@]}"
-5
```

### `array.force-range()`

Given a numeric argument, and an additional array of numbers,
determines the min/max range of the array and prints out the
number if it's within the range of array's min and max.
Otherwise prints out either min or max.

#### Example

```bash
$ array.force-range 26 0 100
# => 26
$ array.force-range 26 60 100
# => 60
```

### `array.max()`

Returns a maximum integer from an array.
Non-numeric elements are ignored and skipped over.
Negative numbers are supported, but non-integers are not.

#### Example

```bash
$ declare -a array=(10 20 30 -5 5)
$ array.min "," "${array[@]}"
30
```

### `array.uniq()`

Sorts and uniqs the array and prints it to STDOUT

#### Example

```bash
declare -a unsorted=(hello hello hello goodbye)
local uniqued="$(array.sort-numeric "${unsorted[@]}")"
```

### `array.from.command()`

Creates an array variable, where each element is a line from a command output,
which includes any spaces.

#### Example

```bash
      array.from.command music_files "find . -type f -name '*.mp3'"
      echo "You have ${#music[@]} music files."

```



---


## File `lib/asciidoc.sh`



Provides helper functions for dealing with asciidoc format.



* [asciidoc.rouge-themes()](#asciidocrouge-themes)

### `asciidoc.rouge-themes()`

Installs gem "rouge" and prints all available themes



---


## File `lib/output-utils.sh`



* [is-dbg()](#is-dbg)
* [dbg()](#dbg)

### `is-dbg()`

Checks if we have debug mode enabled

### `dbg()`

Local debugging helper, activate it with DEBUG=1



---


## File `lib/audio.sh`

# lib/audio.sh


Audio conversions routines.



* [audio.file.frequency()](#audiofilefrequency)
* [audio.make.mp3s()](#audiomakemp3s)
* [audio.make.mp3()](#audiomakemp3)
* [audio.file.mp3-to-wav()](#audiofilemp3-to-wav)
* [audio.dir.mp3-to-wav()](#audiodirmp3-to-wav)
* [.audio.karaoke.format()](#audiokaraokeformat)
* [audio.dir.rename-wavs()](#audiodirrename-wavs)
* [audio.dir.rename-karaoke-wavs()](#audiodirrename-karaoke-wavs)

### `audio.file.frequency()`

Given a music audio file, determine its frequency.

### `audio.make.mp3s()`

Given a folder of MP3 files, and an optional KHz specification, 
perform a sequential conversion from AIF/WAV format to MP3.

#### Example

```bash
audio.wav-to-mp3 [ file.wav | file.aif | file.aiff ] [ file.mp3 ]
```

### `audio.make.mp3()`

Converts one AIF/WAV file to high-rez 320 Kbps MP3

### `audio.file.mp3-to-wav()`

Decodes a folder with MP3 files back into WAV

### `audio.dir.mp3-to-wav()`

assume a folder with a bunch of MP3s in subfolders

#### Example

```bash
same folder structure but under /Volumes/SDCARD.
```

### `.audio.karaoke.format()`

Rename function for one filename to another.
This particular function deals with files of this format:
Downloaded from karaoke-version.com:

#### Example

```bash
.audio.karaoke.format "Michael_Jackson_Billie_Jean(Drum_Backing_Track_(Drum_only))_248921.wav"
=> michael_jackson_billie_jean——drum_backing_track-drum_only.wav
```

### `audio.dir.rename-wavs()`

This function receives a format specification, and an optional
directory as a second argument. Format specification is meant to 
map to a function .audio.<format>.format that's used as follows:
.audio.<format>.format "file-name" => "new file name" 

#### Example

```bash
audio.dir.rename-wavs karaoke ~/Karaoke
```

### `audio.dir.rename-karaoke-wavs()`

Renames wav files in the current folder (or the folder 
passed as an argument, based on the naming scheme downloaded
from karaoke-version.com

#### Example

```bash
audio.dir.rename-karaoke-wavs "~/Karaoke"
```



---


## File `lib/brew.sh`



* [package.is-installed()](#packageis-installed)

### `package.is-installed()`

For each passed argument checks if it's installed.



---


## File `lib/output.sh`



* [section()](#section)

### `section()`

Prints a "arrow-like" line using powerline characters

#### Arguments

* @arg1 Width (optional) — only intepretered as width if the first argument is a number.
* @args Text to print



---


## File `lib/file-helpers.sh`



* [.file.make_executable()](#filemake_executable)

### `.file.make_executable()`

Makes a file executable but only if it already contains
a "bang" line at the top.



---


## File `lib/video.sh`

# lib/video.sh


Video conversions routines.



* [.video.install-deps()](#videoinstall-deps)
* [.video.convert.compress-shrinkwrap()](#videoconvertcompress-shrinkwrap)
* [.video.convert.compress-11()](#videoconvertcompress-11)
* [.video.convert.compress-12()](#videoconvertcompress-12)
* [.video.convert.compress-13()](#videoconvertcompress-13)
* [.video.convert.compress-21()](#videoconvertcompress-21)
* [.video.convert.compress-22()](#videoconvertcompress-22)
* [.video.convert.compress-23()](#videoconvertcompress-23)
* [.video.convert.compress-3()](#videoconvertcompress-3)
* [video.convert.compress()](#videoconvertcompress)

### `.video.install-deps()`

Installs ffmpeg

### `.video.convert.compress-shrinkwrap()`

Named after the author of a similar tool that does this:

### `.video.convert.compress-11()`

Given two arguments (from), (to), performs a video recompression

### `.video.convert.compress-12()`

Given two arguments (from), (to), performs a video recompression

### `.video.convert.compress-13()`

Given two arguments (from), (to), performs a video recompression

### `.video.convert.compress-21()`

Given two arguments (from), (to), performs a video recompression

### `.video.convert.compress-22()`

Given two arguments (from), (to), performs a video recompression

### `.video.convert.compress-23()`

Given two arguments (from), (to), performs a video recompression

### `.video.convert.compress-3()`

Given two arguments (from), (to), performs a video recompression

### `video.convert.compress()`

Given two arguments (from), (to), performs a video recompression
according to the algorithm in the second argument.

#### Example

```bash
video.convert.compress bigfile.mov 13
```



---


## File `lib/path.sh`



Utilities for managing the $PATH variable



* [path.strip-slash()](#pathstrip-slash)
* [path.dirs()](#pathdirs)
* [path.dirs.size()](#pathdirssize)
* [path.dirs.uniq()](#pathdirsuniq)
* [path.dirs.delete()](#pathdirsdelete)
* [path.uniq()](#pathuniq)
* [path.append()](#pathappend)
* [path.prepend()](#pathprepend)
* [path.mutate.uniq()](#pathmutateuniq)
* [path.mutate.delete()](#pathmutatedelete)
* [path.mutate.append()](#pathmutateappend)
* [path.mutate.prepend()](#pathmutateprepend)
* [PATH_add()](#path_add)

### `path.strip-slash()`

Removes a trailing slash from an argument path

### `path.dirs()`

Prints a new-line separated list of paths in PATH

#### Arguments

* @arg1 A path to split, defaults to $PATH

### `path.dirs.size()`

Prints the tatal number of paths in the path argument,
which defaults to $PATH

### `path.dirs.uniq()`

Prints all folders in $PATH, one per line, removing any duplicates,
Does not mutate the $PATH

### `path.dirs.delete()`

Deletes any number of folders from the PATH passed as the first 
string argument (defaults to $PATH). Does not mutate the $PATH, 
just prints the result to STDOUT

#### Arguments

* @arg1 String representation of a PATH, eg "/bin:/usr/bin:/usr/local/bin"
* @arg2 An array of paths to be removed from the PATH

### `path.uniq()`

Removes duplicates from the $PATH (or argument) and prints the
results in the PATH format (column-joined). DOES NOT mutate the actual $PATH

### `path.append()`

Appends a new directory to the $PATH and prints the result to STDOUT,
Does NOT mutate the actual $PATH

### `path.prepend()`

Prepends a new directory to the $PATH and prints to STDOUT,
If one of the arguments already in the PATH its moved to the front.
DOES NOT mutate the actual $PATH

### `path.mutate.uniq()`

Removes any duplicates from $PATH and exports it.

### `path.mutate.delete()`

Deletes paths from the PATH provided on the command line

### `path.mutate.append()`

Appends valid directories to those in the PATH, and
exports the new value of the PATH

### `path.mutate.prepend()`

Prepends valid directories to those in the PATH, and
exports the new value of the PATH

### `PATH_add()`

This function exists within direnv, but since we
are sourcing in .envrc we need to have this defined
to avoid errors.



---


## File `lib/osx.sh`



OSX Specific Helpers and Utilities



* [osx.app.is-installed()](#osxappis-installed)

### `osx.app.is-installed()`

Checks if a given parameter matches any of the installed applications
under /Applications and ~/Applications

By the default prints the matched application. Pass `-q` as a second
argument to disable output.

#### Example

```bash
❯ osx.app.is-installed safari
Safari.app
❯ osx.app.is-installed safari -q && echo installed
installed
❯ osx.app.is-installed microsoft -c
6
```

#### Arguments

* **$1** (a): string value to match (case insentively) for an app name
* $2.. additional arguments to the last invocation of `grep`

#### Exit codes

* **0**: if match was found
* **1**: if not



---


## File `lib/db.sh`



* [db.config.parse()](#dbconfigparse)
* [db.psql.connect()](#dbpsqlconnect)
* [db.psql.connect.just-data()](#dbpsqlconnectjust-data)
* [db.psql.connect.table-settings-set()](#dbpsqlconnecttable-settings-set)
* [db.psql.db-settings()](#dbpsqldb-settings)
* [db.psql.connect.db-settings-pretty()](#dbpsqlconnectdb-settings-pretty)
* [db.psql.connect.db-settings-toml()](#dbpsqlconnectdb-settings-toml)
* [db.actions.run-multiple()](#dbactionsrun-multiple)
* [db.actions.pga()](#dbactionspga)

### `db.config.parse()`

Returns a space-separated values of db host, db name, username and password

#### Example

```bash
db.config.set-file ~/.db/database.yml
db.config.parse development
#=> hostname dbname dbuser dbpass
declare -a params=($(db.config.parse development))
echo ${params[0]} # host
```

### `db.psql.connect()`

Connect to one of the databases named in the YAML file, and
optionally pass additional arguments to psql.
Informational messages are sent to STDERR.

#### Example

```bash
db.psql.connect production
db.psql.connect production -c 'show all'
```

### `db.psql.connect.just-data()`

Similar to the db.psql.connect, but outputs
just the raw data with no headers.a

#### Example

```bash
db.psql.connect.just-data production -c 'select datname from pg_database;'
```

### `db.psql.connect.table-settings-set()`

Set per-table settings, such as autovacuum, eg:

#### Example

```bash
db.psql.connect.table-settings-set prod users autovacuum_analyze_threshold 1000000
db.psql.connect.table-settings-set prod users autovacuum_analyze_scale_factor 0
```

### `db.psql.db-settings()`

Print out PostgreSQL settings for a connection specified by args

#### Example

```bash
db.psql.db-settings -h localhost -U postgres appdb
```

### `db.psql.connect.db-settings-pretty()`

Print out PostgreSQL settings for a named connection

#### Example

```bash
db.psql.connect.db-settings-pretty primary
```

#### Arguments

* @arg1 dbname database entry name in ~/.db/database.yml

### `db.psql.connect.db-settings-toml()`

Print out PostgreSQL settings for a named connection using TOML/ini
format.

#### Example

```bash
db.psql.connect.db-settings-toml primary > primary.ini
```

#### Arguments

* @arg1 dbname database entry name in ~/.db/database.yml

### `db.actions.run-multiple()`

Executes multiple commands by passing them to psql each with -c flag. This
allows, for instance, setting session values, and running commands such as VACUUM which 
can not run within an implicit transaction started when joining multiple statements with ";"

#### Example

```bash
$ db -q run my_database 'set default_statistics_target to 10; show default_statistics_target; vacuum users'
ERROR:  VACUUM cannot run inside a transaction block
```

### `db.actions.pga()`

Installs (if needed) pg_activity and starts it up against the connection



---


## File `lib/shdoc.sh`

# lib/shdoc.sh

Helpers to install gawk and shdoc properly.0


see `${BASHMATIC_HOME}/lib/shdoc.md` for an example of how to use SHDOC.
and also [project's github page](https://github.com/reconquest/shdoc).



* [gawk.install()](#gawkinstall)

### `gawk.install()`

Installs gawk into /usr/local/bin/gawk



---


## File `lib/git.sh`



* [git.cfgu()](#gitcfgu)
* [git.open()](#gitopen)

### `git.cfgu()`

Sets or gets user values from global gitconfig.

#### Example

```bash
git.cfgu email
git.cfgu email kigster@gmail.com
git.cfgu
```

### `git.open()`

Reads the remote of a repo by name provided as
an argument (or defaults to "origin") and opens it in the browser.

#### Example

```bash
git clone git@github.com:kigster/bashmatic.git
cd bashmatic
source init.sh
git.open
git.open origin # same thing
```

#### Arguments

* **$1** (optional): name of the remote to open, defaults to "orogin"



---


## File `lib/package.sh`



* [package.ensure.is-installed()](#packageensureis-installed)
* [package.ensure.commmand-available()](#packageensurecommmand-available)

### `package.ensure.is-installed()`

fr

### `package.ensure.commmand-available()`

#### Example

```bash
In this example we skip installation if `gem` exists and in the PATH.
Oherwise we install the package and retry, and return if not found
```



---


## File `lib/time.sh`



* [time.with-duration.start()](#timewith-durationstart)

### `time.with-duration.start()`

Starts a time for a given name space

#### Example

```bash
time.with-duration.start moofie
# ... time passes
time.with-duration.end   moofie 'Moofie is now this old: '
# ... time passes
time.with-duration.end   moofie 'Moofie is now very old: '
time.with-duration.clear moofie
```



---


## File `lib/shasum.sh`


SHA Functions


SHASUM related functions, that compute SHA for a single file,  
collection of files, or entire directories.



* [shasum.set-command()](#shasumset-command)
* [shasum.set-algo()](#shasumset-algo)
* [shasum.sha()](#shasumsha)
* [shasum.sha-only()](#shasumsha-only)
* [shasum.sha-only-stdin()](#shasumsha-only-stdin)
* [shasum.to-hash()](#shasumto-hash)
* [shasum.all-files()](#shasumall-files)
* [shasum.all-files-in-dir()](#shasumall-files-in-dir)

### `shasum.set-command()`

Override the default SHA command and alogirthm
Default is shasum -a 256

### `shasum.set-algo()`

Override the default SHA algorithm

#### Example

```bash
$ shasum.set-algo 256
```

### `shasum.sha()`

Compute SHA for all given files, ignore STDERR
NOTE: first few arguments will be passed to the
shasum command, or whatever you set via shasum.set-command.

### `shasum.sha-only()`

Print SHA ONLY removing the file components

### `shasum.sha-only-stdin()`

Print SHA ONLY removing the file components

### `shasum.to-hash()`

This function populates a pre-declare associative array with
filenames mapped to their SHAs, but only in the current directory
Call `dbg-on` to enable additional debugging info.

#### Example

```bash
    $ declare -A file_shas
    $ shasum.to-hash file_shas $(find . -type f -maxdepth 2)
    $ echo "Total of ${#file_shas[@]} files in the hash"

```

### `shasum.all-files()`

For a given array of files, sort them, take a SHA of each file,
and return a single SHA finger-printing this set of files. #
NOTE: the files are sorted prior to hashing, so the return SHA
should ONLY change when files are either changed, or added/removed.
Only computes SHA of the files provided, does not recurse into folders

#### Example

```bash
$ shasum.all-files *.cpp
```

### `shasum.all-files-in-dir()`

For a given directory and an optional file pattern, 
use `find` to grab every single file (that matches optional pattern)
and return a single SHA

#### Example

```bash
$ shasum.all-files-in-dir . '*.pdf'
cc35aad389e61942c75e111f1eddbe634d74b4b1
```



---


## File `lib/color.sh`



* [color.current-background()](#colorcurrent-background)

### `color.current-background()`

Prints the background color of the terminal, assuming terminal responds
to the escape sequence. More info: 
https://stackoverflow.com/questions/2507337/how-to-determine-a-terminals-background-color



---


## File `lib/pg.sh`



* [pg.is-running()](#pgis-running)
* [pg.running.server-binaries()](#pgrunningserver-binaries)
* [pg.running.data-dirs()](#pgrunningdata-dirs)
* [pg.server-in-path.version()](#pgserver-in-pathversion)

### `pg.is-running()`

Returns true if PostgreSQL is running locally

### `pg.running.server-binaries()`

if one or more PostgreSQL instances is running locally,
prints each server's binary +postgres+ file path

### `pg.running.data-dirs()`

For each running server prints the data directory

### `pg.server-in-path.version()`

Grab the version from `postgres` binary in the PATH and remove fractional sub-version



---


## File `lib/dir.sh`



* [dir.short-home()](#dirshort-home)

### `dir.short-home()`

Replaces the first part of the directory that matches ${HOME} with '~/'



---


## File `lib/config.sh`



* [config.get-format()](#configget-format)
* [config.set-file()](#configset-file)
* [config.get-file()](#configget-file)
* [config.dig()](#configdig)
* [config.dig.pretty()](#configdigpretty)

### `config.get-format()`

Get current format

### `config.set-file()`

Set the default config file

### `config.get-file()`

Get the file name

### `config.dig()`

Reads the value from a two-level configuration hash

#### Arguments

* @arg1 hash key
* @arg2 hash sub-key

### `config.dig.pretty()`

Uses `jq` utility to format JSON with color, supports partial



---


## File `lib/net.sh`



* [net.is-host-port-protocol-open()](#netis-host-port-protocol-open)

### `net.is-host-port-protocol-open()`

Uses pingless connection to check if a remote port is open
Requires sudo for UDP

#### Arguments

* @arg1 host
* @arg2 port
* @arg3 [optional] protocol (defaults to "tcp", supports also "udp")



---


## File `lib/is.sh`



Various validations and asserts that can be chained
and be explicit in a DSL-like way.



* [__is.validation.error()](#__isvalidationerror)
* [is-validations()](#is-validations)
* [__is.validation.ignore-error()](#__isvalidationignore-error)
* [__is.validation.report-error()](#__isvalidationreport-error)
* [whenever()](#whenever)

### `__is.validation.error()`

Invoke a validation on the value, and process
the invalid case using a customizable error handler.

#### Arguments

* @arg1 func        Validation function name to invoke
* @arg2 var         Value under the test
* @arg4 error_func  Error function to call when validation fails

#### Exit codes

* **0**: if validation passes

### `is-validations()`

Returns the list of validation functions available

### `__is.validation.ignore-error()`

Private function that ignores errors

### `__is.validation.report-error()`

Private function that ignores errors

### `whenever()`

a convenient DSL for validating things

#### Example

```bash
whenever /var/log/postgresql.log is.an-empty-file && {
   touch /var/log/postgresql.log
}
```



---


## File `lib/util.sh`



Miscellaneous utilities.





---


## File `lib/runtime.sh`



* [run.inspect-vars()](#runinspect-vars)

### `run.inspect-vars()`

Prints values of all variables starting with prefixes in args



---


## File `lib/pdf.sh`

# Bashmatic Utilities for PDF file handling


Install and uses GhostScript to manipulate PDFs.



* [pdf.combine()](#pdfcombine)

### `pdf.combine()`

Combine multiple PDFs into a single one using ghostscript.

#### Example

```bash
pdf.combine ~/merged.pdf 'my-book-chapter*'
```

#### Arguments

* **$1** (pathname): to the merged file
* **...** (the): rest of the PDF files to combine



---


## File `bin/install-direnv`



Add direnv hook to shell RC files



* [direnv.register()](#direnvregister)

### `direnv.register()`

Add direnv hook to shell RC files



---


## File `bin/regen-usage-docs`



Regenerates USAGE.adoc && USAGE.pdf





---


## File `bin/pdf-reduce`



* [pdf.do.shrink()](#pdfdoshrink)

### `pdf.do.shrink()`

shrinkgs PDF



---


## File `bin/scheck`



* [manual-install()](#manual-install)

### `manual-install()`

Manually Download and Install ShellCheck

## Copyright & License

 * Copyright © 2017-2021 Konstantin Gredeskoul, All rights reserved.
 * Distributed under the MIT License.
