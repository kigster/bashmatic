# Bashmatic Utilities
# © 2017-2020 Konstantin Gredeskoul, All rights reserved.
# Distributed under the MIT LICENSE.
set -e

export Bashmatic__Test=1

source init.sh

[[ -n ${CI} ]] && lib::color::disable

