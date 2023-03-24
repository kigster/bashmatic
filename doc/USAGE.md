

---


## File `lib/yarn.sh`



* [yarn_install()](#yarn_install)
* [yarn_sha()](#yarn_sha)

### `yarn_install()`

Installs YARN via npm if not found; then runs yarn install
Note that yarn install is skipped if package.json and yarn.lock haven't
changed since the last run of yarn install.

### `yarn_sha()`

Prints to STDOUT the SHA based on package.json and yarn.lock



---


## File `lib/dropbox.sh`



* [function dropbox.ignore {](#function-dropboxignore-)
* [dropbox.unignore()](#dropboxunignore)

### function dropbox.ignore {

Set file to be ignored by Dropbox

#### See also

* [https://help.dropbox.com/files-folders/restore-delete/ignored-files](#httpshelpdropboxcomfiles-foldersrestore-deleteignored-files)

### `dropbox.unignore()`

Set a file or directorhy to be ignored by Dropbox

#### See also

* [https://help.dropbox.com/files-folders/restore-delete/ignored-files](#httpshelpdropboxcomfiles-foldersrestore-deleteignored-files)



---


## File `lib/file.sh`



* [file.temp()](#filetemp)
* [file.normalize-files()](#filenormalize-files)
* [file.first-is-newer-than-second()](#filefirst-is-newer-than-second)
* [file.ask.if-exists()](#fileaskif-exists)
* [file.install-with-backup()](#fileinstall-with-backup)
* [file.last-modified-date()](#filelast-modified-date)
* [file.last-modified-year()](#filelast-modified-year)
* [file.last-modified-millis()](#filelast-modified-millis)
* [file.size()](#filesize)
* [file.size.mb()](#filesizemb)
* [file.size.gb()](#filesizegb)
* [file.list.filter-existing()](#filelistfilter-existing)
* [file.list.filter-non-empty()](#filelistfilter-non-empty)
* [file.count.lines()](#filecountlines)
* [file.count.words()](#filecountwords)
* [file.find()](#filefind)
* [dir.find()](#dirfind)
* [ls.mb()](#lsmb)
* [ls.gb()](#lsgb)

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

### `file.first-is-newer-than-second()`

A super verbose shortcut to [[ file -nt file2 ]]

### `file.ask.if-exists()`

Ask the user whether to overwrite the file

### `file.install-with-backup()`

Installs a given file into a provided destination, while
making a backup of the destination if it already exists.

#### Example

```bash
file.install-with-backup conf/.psqlrc ~/.psqlrc backup-strategy-function
```

#### Arguments

* @arg1 File to backup
* @arg2 Destination
* @arg3 [optional] Shortname of the optional backup strategy: 'bak' or 'folder'. 

### `file.last-modified-date()`

Prints the file's last modified date

### `file.last-modified-year()`

Prints the year of the file's last modified date

### `file.last-modified-millis()`

Prints the file's last modified date expressed as millisecondsd

### `file.size()`

Returns the file size in bytes

### `file.size.mb()`

Prints the file size expressed in Mb (and up to 1 decimal point)

### `file.size.gb()`

Prints the file size expressed in Gb (and up to 1 decimal point)

### `file.list.filter-existing()`

For each argument prints only those that represent existing files

### `file.list.filter-non-empty()`

For each argument prints only those that represent non-emtpy files

### `file.count.lines()`

Prints the number of lines in the file

### `file.count.words()`

Prints the number of lines in the file

### `file.find()`

Invokes UNIX find command searching for files (not folders)
matching the first argument in the name.

### `dir.find()`

Invokes UNIX find command searching for folders (not files)
matching the first argument in the name.

### `ls.mb()`

Prints all folders sorted by size, and size printed in Mb

### `ls.gb()`

Prints all folders sorted by size, and size printed in Gb



---


## File `lib/url.sh`



* [url.cert.is-valid()](#urlcertis-valid)
* [url.cert.domain()](#urlcertdomain)
* [url.host.is-valid()](#urlhostis-valid)
* [url.cert.info()](#urlcertinfo)

### `url.cert.is-valid()`

Returns 0 if the certificate is valid of the domain
passed as an argument.

#### Arguments

* @arg0 domain or a complete https url

### `url.cert.domain()`

Prints the common name for which the SSL certificate is registered

#### Example

```bash
❯ url.cert.domain google.com
*.google.com
```

### `url.host.is-valid()`

Returns 0 when the argument is a valid Internet host
resolvable via DNS. Otherwise returns 255 and prints an error to STDERR.

### `url.cert.info()`

Returns the SSL information about the remote certificate



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

Local debugging helper, activate it with `export BASHMATIC_DEBUG=1`



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



* [output.screen-width.actual()](#outputscreen-widthactual)
* [output.screen-height.actual()](#outputscreen-heightactual)
* [section()](#section)

### `output.screen-width.actual()`

OS-independent way to determine screen width.

### `output.screen-height.actual()`

OS-independent way to determine screen height.

### `section()`

Prints a "arrow-like" line using powerline characters

#### Arguments

* @arg1 Width (optional) — only intepretered as width if the first argument is a number.
* @args Text to print



---


## File `lib/usage.sh`



* [usage-widget()](#usage-widget)

### `usage-widget()`

This is a massive hack and I am ashemed to have written it.
With that out of the way, here we go. This command generates a pretty usage box
for a tool or another command.

#### Example

```bash
usage-widget [-]<width> \                         # box width. If it starts with "-" forces cache wipe.
    "command [flags] <arg1 ... >" \               # <-- USAGE
    "This command is beyond description." \       # <-- DESCRIPTION
    "[®]string" \                                 # <-- This and subsequent lines may optionally start with "®" symbol,
    "[®]string" \                                 #     which will turn them into sub-headings:
    "[®]string" \
    "[®]string"
 usage-widget 90 \
    "command [flags] <arg1 ... >" \
    "This command is beyond description." \
    "®examples" \
    "Some examples will follow" \
    "And others won't."
┌──────────────────────────────────────────────────────────────────────────────────────┐
│  USAGE:           command [flags] <arg1 ... >                                        │
├──────────────────────────────────────────────────────────────────────────────────────┤
│  DESCRIPTION:     This command is beyond description.                                │
├──────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│  EXAMPLES:                                                                           │
│                   Some examples will follow                                          │
│                   And others won't.                                                  │
└──────────────────────────────────────────────────────────────────────────────────────┘
```



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



* [.destination-file-name()](#destination-file-name)
* [.video.convert.compress-shrinkwrap()](#videoconvertcompress-shrinkwrap)
* [.video.convert.compress-11()](#videoconvertcompress-11)
* [.video.convert.compress-12()](#videoconvertcompress-12)
* [.video.convert.compress-13()](#videoconvertcompress-13)
* [.video.convert.compress-21()](#videoconvertcompress-21)
* [.video.convert.compress-22()](#videoconvertcompress-22)
* [.video.convert.compress-23()](#videoconvertcompress-23)
* [.video.convert.compress-3()](#videoconvertcompress-3)
* [video.filename.encoded()](#videofilenameencoded)
* [video.install.dependencies()](#videoinstalldependencies)
* [video.encode()](#videoencode)
* [video.squeeze()](#videosqueeze)

### `.destination-file-name()`

Generate a destination file name for the compressed items.

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

### `video.filename.encoded()`

Given the source file passed as an argument, and the name of the encoding algorithm,
prints the name of the destination file (which will be lower-caseed, no spaces, and contain the algorithm)

### `video.install.dependencies()`

Installs ffmpeg and other dependencies

### `video.encode()`

Given two arguments (from), (to), performs a video recompression
according to the algorithm in the second argument.

#### Example

```bash
             video.encode bigfile.mov 13 smallerfile.mkv
@arg1 File to convert
@arg2 Name of the algorithm, defaults to 11
@arg3 Optional output file
```

### `video.squeeze()`





---


## File `lib/path.sh`



Utilities for managing the $PATH variable



* [path.strip-slash()](#pathstrip-slash)
* [path.dirs()](#pathdirs)
* [path.dirs.size()](#pathdirssize)
* [path.dirs.uniq()](#pathdirsuniq)
* [path.dirs.delete()](#pathdirsdelete)
* [path.uniq()](#pathuniq)
* [PATH.uniqify()](#pathuniqify)
* [path.append()](#pathappend)
* [path.prepend()](#pathprepend)
* [path.mutate.uniq()](#pathmutateuniq)
* [path.mutate.delete()](#pathmutatedelete)
* [path.mutate.append()](#pathmutateappend)
* [path.mutate.prepend()](#pathmutateprepend)
* [path.absolute()](#pathabsolute)

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

### `PATH.uniqify()`

Using sed and tr uniq the PATH without re-sorting it.

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

### `path.absolute()`

Returns an absolute version of a given path



---


## File `lib/osx.sh`



OSX Specific Helpers and Utilities



* [osx.app.is-installed()](#osxappis-installed)
* [osx.detect-cpu()](#osxdetect-cpu)

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

### `osx.detect-cpu()`

This function checks the architecture of the CPU, but
also is able to detect when M1 system is running under Rosetta.

#### Example

```bash
local -a ostype=( $(osx.detect-cpu) )
local cpu=${ostype[0]}
local emulation="${ostype[1]}"
```



---


## File `lib/bashmatic.sh`



* [bashmatic.is-developer()](#bashmaticis-developer)
* [bashmatic.is-installed()](#bashmaticis-installed)

### `bashmatic.is-developer()`

True if .envrc.local file is present. We take it as a sign
you may be developing bashmatic.

### `bashmatic.is-installed()`

This function returns 1 if bashmatic is installed in the 
location pointed to by ${BASHMATIC_HOME} or the first argument.

#### Arguments

* $1      The location to check for bashmatic instead of ${BASHMATIC_HOME}



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
* [git.repo()](#gitrepo)
* [git.repo.current()](#gitrepocurrent)
* [git.cfg.get()](#gitcfgget)

### `git.cfgu()`

Sets or gets user values from global gitconfig.

#### Example

```bash
git.cfgu email
git.cfgu email kigster@gmail.com
git.cfgu
```

### `git.repo()`

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

### `git.repo.current()`

Returns a URL on Github website that points to the
.  README on the current branch.

### `git.cfg.get()`

Prints the value from github config

#### Example

```bash
  git.cfg.get github.token user.name user.email
dsf09098f09ds8f0s98df09809
John Doe
jonny@hotmail.com
```

#### Arguments

* @arg1 [ local | global ] which config to look at (defaults to global)
* @arg2... tokens to print 



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



* [date.now.with-time()](#datenowwith-time)
* [time.with-duration.start()](#timewith-durationstart)
* [time.with-duration()](#timewith-duration)
* [time.a-command()](#timea-command)

### `date.now.with-time()`

Prints the complete date with time up to milliseconds

#### Example

```bash
2022-05-03 14:29:52.302
```

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

### `time.with-duration()`

Runs the given command and prints the time it took

#### Example

```bash
time.with-duration quiet "{ sleep 1; ls -al; sleep 2; date; sleep 1; }"
time.with-duration quiet verbose "{ sleep 1; ls -al; sleep 2; date; sleep 1; }"
```

#### Arguments

* @arg1 [quiet] to silence command output
* @arg2 [verbose] to print the command before running the
* @arg3 [secret] do not print the command before running it (in case sensitive)

### `time.a-command()`

This function receives a command to execute as an argument.
The command is executed as 'eval "$@"'; meanwhile the start/end
times are measured, and the following string is printed at the end:
eg. "4 minutes 24.345 seconds"

#### Arguments

* @args Command to run



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
* [sha()](#sha)

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

### `sha()`

sha256 



---


## File `lib/runtime-config.sh`



* [is.dry-run.on()](#isdry-runon)
* [is.dry-run.off()](#isdry-runoff)
* [set.dry-run.on()](#setdry-runon)
* [set.dry-run.off()](#setdry-runoff)

### `is.dry-run.on()`

Returns 0 when dry-run flag was set, 1 otherwise.

#### Example

```bash
set.dry-run.on
is.dry-run.on || rm -f ${temp}
```

### `is.dry-run.off()`

Returns 0 when dry-run flag was set, 1 otherwise.

#### Example

```bash
set.dry-run.off
is.dry-run.on || rm -f ${temp}
```

### `set.dry-run.on()`

Returns 0 when dry-run flag was set, 1 otherwise.

#### Example

```bash
set.dry-run.on
is.dry-run.on || run "ls -al"
```

### `set.dry-run.off()`

Returns 1 when dry-run flag was set, 0 otherwise.

#### Example

```bash
set.dry-run.on
is.dry-run.on || run "ls -al"
```



---


## File `lib/memory.sh`



* [memory.size-to-bytes()](#memorysize-to-bytes)
* [memory.bytes-to-units()](#memorybytes-to-units)

### `memory.size-to-bytes()`

Pass in a value eg. 32GB or 16M and it returns back the number of bytes

### `memory.bytes-to-units()`

This function receives up to three arguments:

#### Arguments

* @arg1 A number of bytes to convert into a more human-friendly format
* @arg2 An optional printf format string, defaults to '%.1f'
* @arg3 An optional suffix ('b' or "B" or none at all)



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


## File `lib/7z.sh`

# lib/7z.sh


p7zip conversions routines.





---


## File `lib/dir.sh`



* [dir.with-file()](#dirwith-file)
* [dir.short-home()](#dirshort-home)

### `dir.with-file()`

Returns the first folder above the given that contains a file.

#### Arguments

* @arg1 file without the path to search for, eg ".evnrc"
* @arg2 Starting file path to seartch

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


## File `lib/flatten.sh`



* [flatten-file()](#flatten-file)

### `flatten-file()`

Given a long path to a file, possibly with spaces in cluded
and a desintation as a second argument, generates a flat pathname and
copies the first argument there.

#### Example

```bash
    ❯ tree -Q "33 Retro Synth/"
    "33 Retro Synth/"
    ├── "001 Retro Synth - A Synth Primer.en.srt"
    ├── "001 Retro Synth - A Synth Primer.mp4"
    ├── "002 Retro Synth - Oscillator.en.srt"
    └── "002 Retro Synth - Oscillator.mp4"
    ❯
    flatten-file "33 Retro Synth/001 Retro Synth - A Synth Primer.mp4"
@arg1 -n | --dry-run (optional)
@arg2 source path
@arg3 dest paths
```



---


## File `lib/nvm.sh`



* [nvm.is-valid-dir()](#nvmis-valid-dir)
* [nvm.detect()](#nvmdetect)
* [nvm.install()](#nvminstall)
* [nvm.load()](#nvmload)

### `nvm.is-valid-dir()`

Returns true if NVM_DIR is correctly set, OR if
a directory passed as an argument contains nvm.sh

### `nvm.detect()`

Returns success and exports NVM_DIR whenver nvm.sh is found underneath any
of the possible locations tried.

### `nvm.install()`

Installs NVM via Curl if not already installed.

### `nvm.load()`

Loadd



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
* [is.not-blank()](#isnot-blank)
* [is.blank()](#isblank)
* [is.empty()](#isempty)
* [is.not-a-blank-var()](#isnot-a-blank-var)
* [is.a-non-empty-file()](#isa-non-empty-file)
* [is.an-empty-file()](#isan-empty-file)
* [is.a-directory()](#isa-directory)
* [is.an-existing-file()](#isan-existing-file)
* [is.a-function.invoke()](#isa-functioninvoke)
* [is.a-function()](#isa-function)
* [is.a-variable()](#isa-variable)
* [is.a-non-empty-array()](#isa-non-empty-array)
* [is.sourced-in()](#issourced-in)
* [is.a-script()](#isa-script)
* [is.integer()](#isinteger)
* [is.an-integer()](#isan-integer)
* [is.numeric()](#isnumeric)
* [is.command()](#iscommand)
* [is.a-command()](#isa-command)
* [is.missing()](#ismissing)
* [is.alias()](#isalias)
* [is.zero()](#iszero)
* [is.non.zero()](#isnonzero)
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

### `is.not-blank()`

is.not-blank <arg> 

### `is.blank()`

is.blank <arg> 

### `is.empty()`

is.empty <arg> 

### `is.not-a-blank-var()`

is.not-a-blank-var <var-name> 

### `is.a-non-empty-file()`

is.a-non-empty-file <file>

### `is.an-empty-file()`

is.an-empty-file <file>

### `is.a-directory()`

is.a-directory <dir>

### `is.an-existing-file()`

is.an-existing-file <file>

### `is.a-function.invoke()`

if the argument passed is a value function, invoke it

### `is.a-function()`

verifies that the argument is a valid shell function

### `is.a-variable()`

verifies that the argument is a valid and defined variable

### `is.a-non-empty-array()`

verifies that the argument is a non-empty array

### `is.sourced-in()`

verifies that the argument is a valid and defined variable

### `is.a-script()`

returns success if the current script is executing in a subshell

### `is.integer()`

returns success if the argument is an integer

#### See also

* [https://stackoverflow.com/questions/806906/how-do-i-test-if-a-variable-is-a-number-in-bash](#httpsstackoverflowcomquestions806906how-do-i-test-if-a-variable-is-a-number-in-bash)

### `is.an-integer()`

returns success if the argument is an integer

### `is.numeric()`

returns success if the argument is numeric, eg. float

### `is.command()`

returns success if the argument is a valid command found in the $PATH

### `is.a-command()`

returns success if the argument is a valid command found in the $PATH

### `is.missing()`

returns success if the command passed as an argument is not in $PATH

### `is.alias()`

returns success if the argument is a current alias

### `is.zero()`

returns success if the argument is a numerical zero

### `is.non.zero()`

returns success if the argument is not a zero

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



* [system.uname()](#systemuname)
* [util.random-number()](#utilrandom-number)
* [util.generate-password()](#utilgenerate-password)
* [util.random-string.of-length()](#utilrandom-stringof-length)

### `system.uname()`

Finds the exact absolute path of the `uname` utility on a unix file system.

### `util.random-number()`

Generates a random number up to 1000000

### `util.generate-password()`

Generates a password of a given length

### `util.random-string.of-length()`

Generates a random string of a given length



---


## File `lib/runtime.sh`



* [run.print-variables()](#runprint-variables)
* [run.inspect-vars()](#runinspect-vars)

### `run.print-variables()`

Adds a variable to the list of the variables to be obfuscated

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


## File `bin/jemalloc-check`



* [jm.ruby.report()](#jmrubyreport)
* [jm.ruby.describe()](#jmrubydescribe)
* [js.jemalloc.detect-or-exit()](#jsjemallocdetect-or-exit)
* [jm.jemalloc.stats()](#jmjemallocstats)
* [jm.jemalloc.detect-quiet()](#jmjemallocdetect-quiet)
* [jm.jemalloc.detect-loud()](#jmjemallocdetect-loud)
* [usage()](#usage)

### `jm.ruby.report()`

prints the info about current version of ruby

### `jm.ruby.describe()`

Prints ruby version under test

### `js.jemalloc.detect-or-exit()`

detects jemalloc or exits

### `jm.jemalloc.stats()`

prints jemalloc statistics if jemalloc is available

### `jm.jemalloc.detect-quiet()`

returns 0 if jemalloc was detected or 1 otherwise

### `jm.jemalloc.detect-loud()`

detects if jemalloc is linked and if so prints the info to output

### `usage()`

Prints the help screen and exits



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

 * Copyright © 2017-2023 Konstantin Gredeskoul, All rights reserved.
 * Distributed under the MIT License.
