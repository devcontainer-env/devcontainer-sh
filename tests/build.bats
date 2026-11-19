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

@test "build -n expands to --no-cache" {
  run devcontainer-sh build -n
  [ "$status" -eq 0 ]
  [[ "$output" == *"--no-cache"* ]]
}

@test "build -p captures the next arg as --platform value" {
  run devcontainer-sh build -p linux/amd64
  [ "$status" -eq 0 ]
  [[ "$output" == *"--platform linux/amd64"* ]]
}

@test "build -p without a value fails" {
  run devcontainer-sh build -p
  [ "$status" -eq 1 ]
  [[ "$output" == *"-p requires a platform"* ]]
}

@test "build injects workspace folder" {
  run devcontainer-sh build
  [ "$status" -eq 0 ]
  [[ "$output" == *"--workspace-folder $(realpath "$WS_ROOT")"* ]]
}
