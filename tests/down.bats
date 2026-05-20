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

@test "down removes containers matching the workspace label" {
  export DEVCONTAINER_SH_TEST_DOCKER_PS_OUT="abc123def456"
  devcontainer_sh_run "cd '$WS_ROOT'; export DEVCONTAINER_SH_TEST_DOCKER_PS_OUT=abc123def456; devcontainer-sh down"
  [ "$status" -eq 0 ]
  [[ "$output" == *"docker rm -f abc123def456"* ]]
}

@test "down exits non-zero when no container matches" {
  devcontainer_sh_run "cd '$WS_ROOT'; devcontainer-sh down"
  [ "$status" -eq 1 ]
  [[ "$output" == *"no container found"* ]]
  [[ "$output" == *"devcontainer.local_folder=$(realpath "$WS_ROOT")"* ]]
}
