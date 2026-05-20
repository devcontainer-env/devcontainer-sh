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

@test "build -n expands to --no-cache" {
  devcontainer_sh_run "cd '$WS_ROOT'; devcontainer-sh build -n"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--no-cache"* ]]
}

@test "build -p captures the next arg as --platform value" {
  devcontainer_sh_run "cd '$WS_ROOT'; devcontainer-sh build -p linux/amd64"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--platform linux/amd64"* ]]
}

@test "build injects workspace folder" {
  devcontainer_sh_run "cd '$WS_ROOT'; devcontainer-sh build"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--workspace-folder $(realpath "$WS_ROOT")"* ]]
}
