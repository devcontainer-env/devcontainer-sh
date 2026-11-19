#!/usr/bin/env bats

load helpers

setup() {
  setup_stubs
  make_workspace
  mkdir -p "$WS_ROOT/src/nested"
}

teardown() {
  teardown_stubs
  rm -rf "$WS_ROOT"
}

@test "exec forwards the command after --" {
  cd "$WS_ROOT"
  run devcontainer-sh exec -- bash -lc 'make test'
  [ "$status" -eq 0 ]
  [[ "$output" == "devcontainer exec --workspace-folder $(realpath "$WS_ROOT") -- bash -lc make test" ]]
}

@test "exec injects the workspace folder" {
  cd "$WS_ROOT"
  run devcontainer-sh exec -- true
  [ "$status" -eq 0 ]
  [[ "$output" == *"--workspace-folder $(realpath "$WS_ROOT")"* ]]
}

@test "exec respects user-provided --workspace-folder" {
  cd "$WS_ROOT"
  run devcontainer-sh exec --workspace-folder /elsewhere -- true
  [ "$status" -eq 0 ]
  [[ "$output" == *"--workspace-folder /elsewhere"* ]]
  [[ "$output" != *"$(realpath "$WS_ROOT")"* ]]
}

@test "exec does not mistake the command's own --workspace-folder for ours" {
  cd "$WS_ROOT"
  run devcontainer-sh exec -- some-tool --workspace-folder /other
  [ "$status" -eq 0 ]
  [[ "$output" == *"--workspace-folder $(realpath "$WS_ROOT") -- some-tool --workspace-folder /other"* ]]
}

@test "exec passes the command's exit status through" {
  cd "$WS_ROOT"
  printf '#!/bin/sh\nexit 7\n' > "$STUB_DIR/devcontainer"
  run devcontainer-sh exec -- false
  [ "$status" -eq 7 ]
}

@test "exec walks up several levels to find the workspace" {
  cd "$WS_ROOT/src/nested"
  run devcontainer-sh exec -- true
  [ "$status" -eq 0 ]
  [[ "$output" == *"--workspace-folder $(realpath "$WS_ROOT") "* ]]
}

@test "exec falls back to PWD when no devcontainer config is found" {
  local elsewhere
  elsewhere="$(mktemp -d)"
  cd "$elsewhere"
  run devcontainer-sh exec -- true
  [ "$status" -eq 0 ]
  [[ "$output" == *"--workspace-folder $(realpath "$elsewhere") "* ]]
  rm -rf "$elsewhere"
}

@test "exec recognises a top-level .devcontainer.json file" {
  local alt
  alt="$(mktemp -d)"
  echo '{}' > "$alt/.devcontainer.json"
  cd "$alt"
  run devcontainer-sh exec -- true
  [ "$status" -eq 0 ]
  [[ "$output" == *"--workspace-folder $(realpath "$alt") "* ]]
  rm -rf "$alt"
}
