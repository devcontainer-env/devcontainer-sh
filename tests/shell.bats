#!/usr/bin/env bats

load helpers

setup() {
  setup_stubs
  make_workspace
  cd "$WS_ROOT"
}

teardown() {
  teardown_stubs
  rm -rf "$WS_ROOT"
}

@test "shell with no arg invokes sh -c with shell-picker expression" {
  run devcontainer-sh shell
  [ "$status" -eq 0 ]
  [[ "$output" == *"sh -c"* ]]
  [[ "$output" == *"command -v zsh"* ]]
  [[ "$output" == *"command -v bash"* ]]
}

@test "shell bash invokes the named shell as login shell" {
  run devcontainer-sh shell bash
  [ "$status" -eq 0 ]
  [[ "$output" == *"bash -l"* ]]
}

@test "shell short form sh works" {
  run devcontainer-sh sh fish
  [ "$status" -eq 0 ]
  [[ "$output" == *"fish -l"* ]]
}

@test "shell injects the workspace folder" {
  run devcontainer-sh shell bash
  [[ "$output" == *"--workspace-folder $(realpath "$WS_ROOT")"* ]]
}
