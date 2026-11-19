#!/usr/bin/env bats

load helpers

setup() { setup_stubs; }
teardown() { teardown_stubs; }

@test "no command prints help and exits 1" {
  run devcontainer-sh
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "unknown command exits 1 with hint" {
  run devcontainer-sh bogus
  [ "$status" -eq 1 ]
  [[ "$output" == *"unknown command: bogus"* ]]
}

@test "help command exits 0" {
  run devcontainer-sh help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Commands:"* ]]
}

@test "version command prints wrapper and upstream versions" {
  run devcontainer-sh version
  [ "$status" -eq 0 ]
  [[ "$output" == *"devcontainer-sh"* ]]
  [[ "$output" == *"devcontainer --version"* ]]
}

@test "version fails when the devcontainer CLI is missing" {
  rm "$STUB_DIR/devcontainer"
  PATH="$PLUGIN_ROOT:$STUB_DIR:/usr/bin:/bin" run devcontainer-sh version
  [ "$status" -eq 1 ]
  [[ "$output" == *"CLI not found"* ]]
}

@test "runs without a login or interactive shell" {
  run env -i PATH="$PATH" HOME="$HOME" bash -c 'devcontainer-sh help'
  [ "$status" -eq 0 ]
}
