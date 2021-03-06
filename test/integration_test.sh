#!/usr/bin/env bash

NAVI_BIN="${NAVI_HOME}/navi"
TEST_DIR="${NAVI_HOME}/test"

_navi() {
   "$NAVI_BIN" "$@"
}

fzf_mock() {
   head -n1 | sed 's/\x1b\[[0-9;]*m//g'
}

assert_version() {
   local -r version="$(cat "$NAVI_BIN" | grep VERSION | cut -d'=' -f2 | tr -d '"')"

   _navi --version \
      | test::equals "$version"
}

assert_help() {
   _navi --help \
      | grep -q 'Options:'
}

assert_home() {
   _navi home \
      | grep -q '/'
}

assert_best() {
   _navi best constant --path "$TEST_DIR" \
      | test::equals 42
}

assert_query() {
   NAVI_ENV="test" _navi --path "$TEST_DIR" \
      | test::equals "2 12"
}

export HAS_FZF="$(command_exists fzf && echo true || echo false)"

test::fzf() {
   if $HAS_FZF; then
      test::run "$@"
   else
      test::skip "$@"
   fi
}

test::set_suite "integration"
export -f fzf_mock
test::run "version" assert_version
test::run "help" assert_help
test::run "home" assert_home
test::fzf "best" assert_best # FZF setup needed in CircleCI
test::fzf "query" assert_query # FZF setup needed in CircleCI
