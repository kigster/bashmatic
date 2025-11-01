# install-direnv

## Overview

Add direnv hook to shell RC files

## Index

* [direnv.register()](#direnvregister)

### direnv.register()

Add direnv hook to shell RC files









## Index

* [get.version.from.file()](#getversionfromfile)
* [main()](#main)

### get.version.from.file()

: Get the version of the psqlrc file

### main()

: Main function to install the psqlrc file if it is not installed

# regen-usage-docs

## Overview

Regenerates USAGE.adoc && USAGE.pdf









## Index

* [pdf.do.shrink()](#pdfdoshrink)

### pdf.do.shrink()

shrinkgs PDF

## Index

* [rb.ruby.report()](#rbrubyreport)
* [rb.ruby.describe()](#rbrubydescribe)
* [rb.jemalloc.detect-or-exit()](#rbjemallocdetect-or-exit)
* [rb.jemalloc.stats()](#rbjemallocstats)
* [rb.jemalloc.detect-quiet()](#rbjemallocdetect-quiet)
* [rb.jemalloc.detect-loud()](#rbjemallocdetect-loud)
* [usage()](#usage)

### rb.ruby.report()

prints the info about current version of ruby

### rb.ruby.describe()

Prints ruby version under test

### rb.jemalloc.detect-or-exit()

detects jemalloc or exits

### rb.jemalloc.stats()

prints jemalloc statistics if jemalloc is available

### rb.jemalloc.detect-quiet()

returns 0 if jemalloc was detected or 1 otherwise

### rb.jemalloc.detect-loud()

detects if jemalloc is linked and if so prints the info to output

### usage()

Prints the help screen and exits







## Index

* [manual-install()](#manual-install)

### manual-install()

Manually Download and Install ShellCheck









## Index

* [ruby.detect-version()](#rubydetect-version)
* [ruby.install()](#rubyinstall)

### ruby.detect-version()

This is perhaps the main function that attempts to guess which version 
we should be installing, assuming one wasn't provided as an CLI argument.
The functions scans the current and all of the parent directories for
the file .ruby-version

### ruby.install()

Actually install Ruby, invoking OS-specific pre-install configurations.

## Index

* [version-of()](#version-of)

### version-of()

This function attempts to deal with various arbitrary 
strings that various programs produce when asked for
their versions. Extracting an actual version out of \
of it is not a simple task. This function covers perhaps
high 90% of all executables, and returns just the version
without any additional text.

#### Example

```bash
* $ ruby --version
    ruby 3.3.6 (2024-11-05 revision 75015d4c1f) [arm64-darwin24]
```





























