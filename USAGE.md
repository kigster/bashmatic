
## Module **array**

* [array.has-element()](#arrayhas-element)
* [array.includes()](#arrayincludes)
* [array.join()](#arrayjoin)
* [array.sort()](#arraysort)
* [array.sort-numeric()](#arraysort-numeric)
* [array.min()](#arraymin)
* [array.max()](#arraymax)
* [array.uniq()](#arrayuniq)


### array.has-element()


    Returns "true" if the first argument is a member of the array
    passed as the second argument:

#### Example

```bash
  $ declare -a array=("a string" test2000 moo)
  if [[ $(array.has-element "a string" "${array[@]}") == "true" ]]; then
    ...
  fi
```

### array.includes()


    Similar to array.has-elements, but does not print anything, just
    returns 0 if includes, 1 if not.

### array.join()


    Joins a given array with a custom character

#### Example

```bash
  $ declare -a array=(one two three)
  $ array.join "," "${array[@]}"
  one,two,three
```

### array.sort()

Sorts the array alphanumerically and prints it to STDOUT

#### Example

```bash
  declare -a unsorted=(hello begin again again)
  local sorted="$(array.sort "${unsorted[@]}")"
```

### array.sort-numeric()

Sorts the array numerically and prints it to STDOUT

#### Example

```bash
  declare -a unsorted=(1 2 34 45 6)
  local sorted="$(array.sort-numeric "${unsorted[@]}")"
```

### array.min()


    Returns a minimum integer from an array.
    Non-numeric elements are ignored and skipped over.
    Negative numbers are supported, but non-integers are not.

#### Example

```bash
  $ declare -a array=(10 20 30 -5 5)
  $ array.min "," "${array[@]}"
  -5
```

### array.max()


    Returns a maximum integer from an array.
    Non-numeric elements are ignored and skipped over.
    Negative numbers are supported, but non-integers are not.

#### Example

```bash
  $ declare -a array=(10 20 30 -5 5)
  $ array.min "," "${array[@]}"
  30
```

### array.uniq()

Sorts and uniqs the array and prints it to STDOUT

#### Example

```bash
  declare -a unsorted=(hello hello hello goodbye)
  local uniqued="$(array.sort-numeric "${unsorted[@]}")"
```


## Module **db**

* [db.config.parse()](#dbconfigparse)
* [db.psql.connect()](#dbpsqlconnect)
* [db.psql.connect.just-data()](#dbpsqlconnectjust-data)
* [db.psql.db-settings()](#dbpsqldb-settings)
* [db.psql.connect.settings-table()](#dbpsqlconnectsettings-table)
* [db.psql.connect.settings-ini()](#dbpsqlconnectsettings-ini)


### db.config.parse()

Returns a space-separated values of db host, db name, username and password

#### Example

```bash
 db.config.set-file ~/.db/database.yml
 db.config.parse development
 #=> hostname dbname dbuser dbpass
 declare -a params=($(db.config.parse development))
 echo ${params[0]} # host
```

### db.psql.connect()

Connect to one of the databases named in the YAML file, and 
             optionally pass additional arguments to psql.
             Informational messages are sent to STDERR.

#### Example

```bash
 db.psql.connect production 
 db.psql.connect production -c 'show all'
```

### db.psql.connect.just-data()

Similar to the db.psql.connect, but outputs
             just the raw data with no headers.

#### Example

```bash
 db.psql.connect.just-data production -c 'select datname from pg_database;'
```

### db.psql.db-settings()

Print out PostgreSQL settings for a connection specified by args

#### Example

```bash
 db.psql.db-settings -h localhost -U postgres appdb
```

### db.psql.connect.settings-table()

Print out PostgreSQL settings for a named connection

#### Arguments

* # @arg1 dbname database entry name in ~/.db/database.yml

#### Example

```bash
 db.psql.connect.settings-table primary
```

### db.psql.connect.settings-ini()

Print out PostgreSQL settings for a named connection using TOML/ini
             format.

#### Arguments

* # @arg1 dbname database entry name in ~/.db/database.yml

#### Example

```bash
 db.psql.connect.settings-ini primary > primary.ini
```


## Module **git**
# Bashmatic Utilities and aliases for Git revision control system.

Lots of useful utilities and helpers.

* [git.open()](#gitopen)


### git.open()

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


## Module **is**
# is.sh


* [__is.validation.error()](#isvalidationerror)
* [is-validations()](#is-validations)
* [__is.validation.ignore-error()](#isvalidationignore-error)
* [__is.validation.report-error()](#isvalidationreport-error)
* [whenever()](#whenever)
* [unless()](#unless)


### __is.validation.error()

     Invoke a validation on the value, and process
                  the invalid case using a customizable error handler.

#### Arguments

* # @arg1 func        Validation function name to invoke
* # @arg2 var         Value under the test
* # @arg4 error_func  Error function to call when validation fails

#### Exit codes

* **0**: if validation passes

### is-validations()

Returns the list of validation functions available

### __is.validation.ignore-error()

Private function that ignores errors

### __is.validation.report-error()

Private function that ignores errors

### whenever()

a convenient DSL for validating things

#### Example

```bash
   whenever /var/log/postgresql.log is.an-empty-file && {
      touch /var/log/postgresql.log
   }
```

### unless()

a convenient DSL for validating things

#### Example

```bash
   unless /var/log/postgresql.log is.an-non-empty-file && {
      touch /var/log/postgresql.log
   }
```


## Module **openssl**

* [.openssl.certs.print-generated()](#opensslcertsprint-generated)


### .openssl.certs.print-generated()

Generate a CSR for NGINX domain


## Module **osx**
# osx.sh

OSX Specific Helpers and Utilities

* [osx.app.is-installed()](#osxappis-installed)


### osx.app.is-installed()

@description
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


## Module **output**

* [section()](#section)
* [is-dbg()](#is-dbg)
* [dbg()](#dbg)


### section()

Prints a "arrow-like" line using powerline characters

#### Arguments

* # @arg1 Width (optional) — only intepretered as width if the first argument is a number.
* # @args Text to print

### is-dbg()

Checks if we have debug mode enabled

### dbg()

Local debugging helper, activate it with DEBUG=1


## Module **path**

* [path.add()](#pathadd)
* [path.append()](#pathappend)
* [PATH_add()](#pathadd)


### path.add()

Adds valid directories to those in the PATH and prints
             to the output. DOES NOT MODIFY $PATH

### path.append()

Appends valid directories to those in the PATH, and 
             exports the new value of the PATH

### PATH_add()

This function exists within direnv, but since we
             are sourcing in .envrc we need to have this defined
             to avoid errors.


## Module **pdf**
# Bashmatic Utilities for PDF file handling

Install and uses GhostScript to manipulate PDFs.

* [pdf.combine()](#pdfcombine)


### pdf.combine()

Combine multiple PDFs into a single one using ghostscript.

#### Example

```bash
pdf.combine ~/merged.pdf 'my-book-chapter*'
```

#### Arguments

* **$1** (pathname): to the merged file
* **...** (the): rest of the PDF files to combine


## Module **array**

* [array.has-element()](#arrayhas-element)
* [array.includes()](#arrayincludes)
* [array.join()](#arrayjoin)
* [array.sort()](#arraysort)
* [array.sort-numeric()](#arraysort-numeric)
* [array.min()](#arraymin)
* [array.max()](#arraymax)
* [array.uniq()](#arrayuniq)


### array.has-element()


    Returns "true" if the first argument is a member of the array
    passed as the second argument:

#### Example

```bash
  $ declare -a array=("a string" test2000 moo)
  if [[ $(array.has-element "a string" "${array[@]}") == "true" ]]; then
    ...
  fi
```

### array.includes()


    Similar to array.has-elements, but does not print anything, just
    returns 0 if includes, 1 if not.

### array.join()


    Joins a given array with a custom character

#### Example

```bash
  $ declare -a array=(one two three)
  $ array.join "," "${array[@]}"
  one,two,three
```

### array.sort()

Sorts the array alphanumerically and prints it to STDOUT

#### Example

```bash
  declare -a unsorted=(hello begin again again)
  local sorted="$(array.sort "${unsorted[@]}")"
```

### array.sort-numeric()

Sorts the array numerically and prints it to STDOUT

#### Example

```bash
  declare -a unsorted=(1 2 34 45 6)
  local sorted="$(array.sort-numeric "${unsorted[@]}")"
```

### array.min()


    Returns a minimum integer from an array.
    Non-numeric elements are ignored and skipped over.
    Negative numbers are supported, but non-integers are not.

#### Example

```bash
  $ declare -a array=(10 20 30 -5 5)
  $ array.min "," "${array[@]}"
  -5
```

### array.max()


    Returns a maximum integer from an array.
    Non-numeric elements are ignored and skipped over.
    Negative numbers are supported, but non-integers are not.

#### Example

```bash
  $ declare -a array=(10 20 30 -5 5)
  $ array.min "," "${array[@]}"
  30
```

### array.uniq()

Sorts and uniqs the array and prints it to STDOUT

#### Example

```bash
  declare -a unsorted=(hello hello hello goodbye)
  local uniqued="$(array.sort-numeric "${unsorted[@]}")"
```


## Module **db**

* [db.config.parse()](#dbconfigparse)
* [db.psql.connect()](#dbpsqlconnect)
* [db.psql.connect.just-data()](#dbpsqlconnectjust-data)
* [db.psql.db-settings()](#dbpsqldb-settings)
* [db.psql.connect.settings-table()](#dbpsqlconnectsettings-table)
* [db.psql.connect.settings-ini()](#dbpsqlconnectsettings-ini)


### db.config.parse()

Returns a space-separated values of db host, db name, username and password

#### Example

```bash
 db.config.set-file ~/.db/database.yml
 db.config.parse development
 #=> hostname dbname dbuser dbpass
 declare -a params=($(db.config.parse development))
 echo ${params[0]} # host
```

### db.psql.connect()

Connect to one of the databases named in the YAML file, and 
             optionally pass additional arguments to psql.
             Informational messages are sent to STDERR.

#### Example

```bash
 db.psql.connect production 
 db.psql.connect production -c 'show all'
```

### db.psql.connect.just-data()

Similar to the db.psql.connect, but outputs
             just the raw data with no headers.

#### Example

```bash
 db.psql.connect.just-data production -c 'select datname from pg_database;'
```

### db.psql.db-settings()

Print out PostgreSQL settings for a connection specified by args

#### Example

```bash
 db.psql.db-settings -h localhost -U postgres appdb
```

### db.psql.connect.settings-table()

Print out PostgreSQL settings for a named connection

#### Arguments

* # @arg1 dbname database entry name in ~/.db/database.yml

#### Example

```bash
 db.psql.connect.settings-table primary
```

### db.psql.connect.settings-ini()

Print out PostgreSQL settings for a named connection using TOML/ini
             format.

#### Arguments

* # @arg1 dbname database entry name in ~/.db/database.yml

#### Example

```bash
 db.psql.connect.settings-ini primary > primary.ini
```


## Module **git**
# Bashmatic Utilities and aliases for Git revision control system.

Lots of useful utilities and helpers.

* [git.open()](#gitopen)


### git.open()

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


## Module **is**
# is.sh


* [__is.validation.error()](#isvalidationerror)
* [is-validations()](#is-validations)
* [__is.validation.ignore-error()](#isvalidationignore-error)
* [__is.validation.report-error()](#isvalidationreport-error)
* [whenever()](#whenever)
* [unless()](#unless)


### __is.validation.error()

     Invoke a validation on the value, and process
                  the invalid case using a customizable error handler.

#### Arguments

* # @arg1 func        Validation function name to invoke
* # @arg2 var         Value under the test
* # @arg4 error_func  Error function to call when validation fails

#### Exit codes

* **0**: if validation passes

### is-validations()

Returns the list of validation functions available

### __is.validation.ignore-error()

Private function that ignores errors

### __is.validation.report-error()

Private function that ignores errors

### whenever()

a convenient DSL for validating things

#### Example

```bash
   whenever /var/log/postgresql.log is.an-empty-file && {
      touch /var/log/postgresql.log
   }
```

### unless()

a convenient DSL for validating things

#### Example

```bash
   unless /var/log/postgresql.log is.an-non-empty-file && {
      touch /var/log/postgresql.log
   }
```


## Module **openssl**

* [.openssl.certs.print-generated()](#opensslcertsprint-generated)


### .openssl.certs.print-generated()

Generate a CSR for NGINX domain


## Module **osx**
# osx.sh

OSX Specific Helpers and Utilities

* [osx.app.is-installed()](#osxappis-installed)


### osx.app.is-installed()

@description
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

