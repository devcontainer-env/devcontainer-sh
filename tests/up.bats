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

@test "up injects --workspace-folder when missing" {
  run devcontainer-sh up
  [ "$status" -eq 0 ]
  [[ "$output" == *"--workspace-folder $(realpath "$WS_ROOT")"* ]]
}

@test "up -R expands to --remove-existing-container --build-no-cache" {
  run devcontainer-sh up -R
  [ "$status" -eq 0 ]
  [[ "$output" == *"--remove-existing-container"* ]]
  [[ "$output" == *"--build-no-cache"* ]]
}

@test "up -r expands only to --remove-existing-container" {
  run devcontainer-sh up -r
  [ "$status" -eq 0 ]
  [[ "$output" == *"--remove-existing-container"* ]]
  [[ "$output" != *"--build-no-cache"* ]]
}

@test "up -n expands to --build-no-cache" {
  run devcontainer-sh up -n
  [ "$status" -eq 0 ]
  [[ "$output" == *"--build-no-cache"* ]]
}

@test "up -s expands to --skip-post-create" {
  run devcontainer-sh up -s
  [ "$status" -eq 0 ]
  [[ "$output" == *"--skip-post-create"* ]]
}

@test "up respects user-provided --workspace-folder" {
  run devcontainer-sh up --workspace-folder /elsewhere
  [ "$status" -eq 0 ]
  [[ "$output" == *"--workspace-folder /elsewhere"* ]]
  [[ "$output" != *"$(realpath "$WS_ROOT")"* ]]
}

@test "up respects --workspace-folder=PATH" {
  run devcontainer-sh up --workspace-folder=/elsewhere
  [ "$status" -eq 0 ]
  [[ "$output" == *"--workspace-folder=/elsewhere"* ]]
  [[ "$output" != *"$(realpath "$WS_ROOT")"* ]]
}

@test "up passes through unknown flags" {
  run devcontainer-sh up --log-level=debug
  [ "$status" -eq 0 ]
  [[ "$output" == *"--log-level=debug"* ]]
}
