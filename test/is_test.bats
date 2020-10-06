#!/usr/bin/env bats
load test_helper

source lib/is.sh
source lib/output.sh

set -e
export not_blank_var="blah"
export blank_var=

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


# @test "is.non-empty-file" {
  
# }
