<!-- vim: ft=markdown  -->

# `shdocument`

This is the wrapper around the [`shdoc`](https://github.com/reconquest/shdoc) tool that gets around the fact that `shdoc` has some dependencies that must be installed.

`shdoc` utility is distributed as an AWK script, however it uses some relatively advanced features of AWK, that are not supported by the plain old `awk` installed on most OS-X systems, therefore this script ensures you have `gawk` installed.

## Using `shdocument`

This is a short example showing various options you can use with `shdocument`:

```bash
shdocument ~/.bashmatic/lib/shdoc.sh > /tmp/shdoc.md
```

## An example of documenting a SHELL function using `shdocument`:

```bash
# @file libexample
# @description A library that solves some common problems.
# @description
#     The project solves lots of problems:
#      * a
#      * b
#      * c
#      * etc
# @description My super function.
# Not thread-safe.
#
# @example
#    echo "test: $(say-hello World)"
#
# @arg $1 string A value to print
#
# @exitcode 0 If successful.
# @exitcode 1 If an empty string passed.
#
# @see validate()
```
