#!/usr/bin/env bats

load helpers

setup() { setup_stubs; }
teardown() { teardown_stubs; }

@test "id-label uses devcontainer.local_folder with absolute path" {
  local ws
  ws="$(mktemp -d)"
  dcsh_run "_dcsh_id_label '$ws'"
  [ "$status" -eq 0 ]
  [ "$output" = "devcontainer.local_folder=$(realpath "$ws")" ]
  rm -rf "$ws"
}

@test "id-label resolves a relative path to absolute" {
  local ws
  ws="$(mktemp -d)"
  dcsh_run "cd '$ws'; _dcsh_id_label ."
  [ "$status" -eq 0 ]
  [ "$output" = "devcontainer.local_folder=$(realpath "$ws")" ]
  rm -rf "$ws"
}
