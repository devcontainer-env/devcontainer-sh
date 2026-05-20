#!/usr/bin/env bats

load helpers

setup() { setup_stubs; }
teardown() { teardown_stubs; }

@test "no subcommand prints help and exits 1" {
  devcontainer_sh_run "devcontainer-sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "unknown subcommand exits 1 with hint" {
  devcontainer_sh_run "devcontainer-sh bogus"
  [ "$status" -eq 1 ]
  [[ "$output" == *"unknown subcommand: bogus"* ]]
}

@test "help subcommand exits 0" {
  devcontainer_sh_run "devcontainer-sh help"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Subcommands:"* ]]
}

@test "version subcommand prints plugin and upstream versions" {
  devcontainer_sh_run "devcontainer-sh version"
  [ "$status" -eq 0 ]
  [[ "$output" == *"devcontainer-sh"* ]]
  [[ "$output" == *"devcontainer --version"* ]]
}
