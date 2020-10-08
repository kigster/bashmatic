#!/usr/bin/env bats
load test_helper

source lib/is.sh
source lib/output.sh

set -e
export not_blank_var="blah"
export blank_var=

@test "is.a-variable(valid var)" {
  BLERGH=1
  var_name="BLERGH"
  is.a-variable ${var_name}
}

@test "is.a-variable(invalid var)" {
  ! is.a-variable BLERGH123
}

@test "is.a-variable(invalid chars)" {
  ! is.a-variable file/hello.txt
}

@test "is.a-variable(blank)" {
  ! is.a-variable 
}

@test "is.not-blank(not blank)" {
  not_blank="blah"
  is.not-blank "${not_blank}"
}

@test "is.not-blank(blank)" {
  ! is.not-blank ""
}

@test "is.not-a-blank-var(not blank)" {
  is.not-a-blank-var not_blank_var
}

@test "is.not-a-blank-var(blank)" {
  ! is.not-a-blank-var blank_var
}

@test "is.a-non-empty-file()" {
  is.a-non-empty-file "test/is_test.bats"
}

@test "whenever '' is.blank" {
   whenever "" is.blank 
}

@test "whenever test/is_test.bats is.a-non-empty-file" {
  whenever test/is_test.bats is.a-non-empty-file
}

@test "whenever 'blah' is.not-blank" {
   whenever blah is.not-blank 
}

@test "is.integer(integer)" {
  is.integer 123
  is.integer 0
  is.integer 1
  is.integer -3
  is.integer 1235987897
}

@test "is.integer(not integer)" {
  ! is.integer ""
  ! is.integer 123.2
  ! is.integer asdf
  ! is.integer 0x042
}

@test "is.numeric(numeric)" {
  is.numeric 123.4
  is.numeric -1234
  is.numeric 999
  is.numeric 0
}

@test "is.numeric(not numeric)" {
  ! is.numeric ""
  ! is.numeric "asdfg"
  ! is.numeric "0x0234"
  ! is.numeric "1234aaa"
}

# @test "is.non-empty-file" {
  
# }
