#!/usr/bin/env bats
load test_helper
source lib/is.sh
source lib/memory.sh

set -e

@test "memory.size-to-bytes(2 Tb)" {
  local bytes=$(memory.size-to-bytes "2 Tb")
  local n=$((1024 * 1024 * 1024 * 1024 * 2))
  [[ ${bytes} -eq ${n} ]]
}

@test "memory.size-to-bytes(32 GB)" {
  local bytes=$(memory.size-to-bytes "32 GB")
  local n=$((1024 * 1024 * 1024 * 32))
  [[ ${bytes} -eq ${n} ]]
}

@test "memory.size-to-bytes(12M)" {
  local bytes=$(memory.size-to-bytes "12M")
  local n=$((1024 * 1024 * 12))
  [[ ${bytes} -eq ${n} ]]
}

@test "memory.size-to-bytes(400 Kb)" {
  local bytes=$(memory.size-to-bytes "400 Kb")
  local n=$((1024 * 400))
  [[ ${bytes} -eq ${n} ]]
}

##################################################################

@test "memory.bytes-to-units(1024)" {
  local ram=$(memory.bytes-to-units 1024 '%.0f')
  [[ ${ram} == "1Kb" ]]
}

@test "memory.bytes-to-units(1024 * 1024)" {
  local ram=$(memory.bytes-to-units $((1024 * 1024)) '%.0f')
  [[ ${ram} == "1Mb" ]]
}

@test "memory.bytes-to-units(1024 * 1024 * 1024)" {
  local ram=$(memory.bytes-to-units $((1024 * 1024 * 1024)) '%.0f')
  [[ ${ram} == "1Gb" ]]
}

@test "memory.bytes-to-units(23041000144)" {
  local ram=$(memory.bytes-to-units 23041000144 '%.0f' 'B')
  [[ ${ram} == "22GB" ]]
}

@test "memory.bytes-to-units(1293904049809234)" {
  local ram=$(memory.bytes-to-units 1293904049809234 '%.9f')
  [[ ${ram} == "1.149217655Pb" ]]
}
