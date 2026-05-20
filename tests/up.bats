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

@test "up injects --workspace-folder when missing" {
  dcsh_run "cd '$WS_ROOT'; devcontainer-sh up"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--workspace-folder $(realpath "$WS_ROOT")"* ]]
}

@test "up -R expands to --remove-existing-container --build-no-cache" {
  dcsh_run "cd '$WS_ROOT'; devcontainer-sh up -R"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--remove-existing-container"* ]]
  [[ "$output" == *"--build-no-cache"* ]]
}

@test "up -r expands only to --remove-existing-container" {
  dcsh_run "cd '$WS_ROOT'; devcontainer-sh up -r"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--remove-existing-container"* ]]
  [[ "$output" != *"--build-no-cache"* ]]
}

@test "up -s expands to --skip-post-create" {
  dcsh_run "cd '$WS_ROOT'; devcontainer-sh up -s"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--skip-post-create"* ]]
}

@test "up respects user-provided --workspace-folder" {
  dcsh_run "cd '$WS_ROOT'; devcontainer-sh up --workspace-folder /elsewhere"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--workspace-folder /elsewhere"* ]]
  [[ "$output" != *"$(realpath "$WS_ROOT")"* ]]
}

@test "up passes through unknown flags" {
  dcsh_run "cd '$WS_ROOT'; devcontainer-sh up --log-level=debug"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--log-level=debug"* ]]
}
