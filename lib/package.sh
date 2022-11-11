# @description fr
function package.ensure.is-installed() {
  for pkg in "$@"; do 
    package.is-installed "${pkg}" || package.install
    package.is-installed "${pkg}" || {
      error "Package ${pkg} does not appear installed, broken package or version?"
      return 1
    }
  done
} 

# @descrtipion Verifies that a particular binary was succesfully instealled
#              in cases where it might differenht from the package name.
#
# @example package.ensure-command-available ruby gem
#          In this example we skip installation if `gem` exists and in the PATH.
#          Oherwise we install the package and retry, and return if not found
#
function package.ensure.commmand-available() {
  local package="$1";  shift
  local binary="$1";  shift

  is.a-command "${binary}" && return 0
  package.ensure.is-installed "${package}"
  hash -r 1>/dev/null 2>&1
  is.a-command "${binary}" && return 0

  error "After installing package ${package}, binary ${binary} still is not found."
}



