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

@test "down removes containers matching the workspace label" {
  DEVCONTAINER_SH_TEST_DOCKER_PS_OUT="abc123def456" run devcontainer-sh down
  [ "$status" -eq 0 ]
  [[ "$output" == *"docker rm -f abc123def456"* ]]
}

@test "down removes every matching container" {
  DEVCONTAINER_SH_TEST_DOCKER_PS_OUT=$'abc123\ndef456' run devcontainer-sh down
  [ "$status" -eq 0 ]
  [[ "$output" == *"docker rm -f abc123 def456"* ]]
}

@test "down exits non-zero when no container matches" {
  run devcontainer-sh down
  [ "$status" -eq 1 ]
  [[ "$output" == *"no container found"* ]]
}

@test "down looks up the devcontainer.local_folder label with an absolute path" {
  run devcontainer-sh down
  [[ "$output" == *"devcontainer.local_folder=$(realpath "$WS_ROOT")"* ]]
}

@test "down uses --workspace-folder for the label" {
  run devcontainer-sh down --workspace-folder "$WS_ROOT/.devcontainer/.."
  [[ "$output" == *"devcontainer.local_folder=$(realpath "$WS_ROOT")"* ]]
}

@test "down --help prints usage and exits 0" {
  run devcontainer-sh down --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: devcontainer-sh down"* ]]
}
