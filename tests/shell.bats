#!/usr/bin/env bats

load helpers

setup() {
  setup_stubs
  WS_ROOT="$(mktemp -d)"
  mkdir -p "$WS_ROOT/.devcontainer"
  echo '{}' > "$WS_ROOT/.devcontainer/devcontainer.json"
}

teardown() {
  teardown_stubs
  rm -rf "$WS_ROOT"
}

@test "shell with no arg invokes sh -c with shell-picker expression" {
  dcsh_run "cd '$WS_ROOT'; devcontainer-sh shell"
  [ "$status" -eq 0 ]
  [[ "$output" == *"sh -c"* ]]
  [[ "$output" == *"command -v zsh"* ]]
  [[ "$output" == *"command -v bash"* ]]
}

@test "shell bash invokes the named shell as login shell" {
  dcsh_run "cd '$WS_ROOT'; devcontainer-sh shell bash"
  [ "$status" -eq 0 ]
  [[ "$output" == *"bash -l"* ]]
}

@test "shell short form `sh` works" {
  dcsh_run "cd '$WS_ROOT'; devcontainer-sh sh fish"
  [ "$status" -eq 0 ]
  [[ "$output" == *"fish -l"* ]]
}
