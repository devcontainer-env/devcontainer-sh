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

@test "down on a compose dev container removes the whole compose project" {
  DEVCONTAINER_SH_TEST_DOCKER_PS_OUT="abc123" DEVCONTAINER_SH_TEST_COMPOSE_PROJECT="myproj" \
    run devcontainer-sh down
  [ "$status" -eq 0 ]
  [[ "$output" == *"docker compose -p myproj down --remove-orphans"* ]]
  [[ "$output" != *"docker rm"* ]]
}

@test "down keeps named volumes unless -v is given" {
  DEVCONTAINER_SH_TEST_DOCKER_PS_OUT="abc123" DEVCONTAINER_SH_TEST_COMPOSE_PROJECT="myproj" \
    run devcontainer-sh down
  [[ "$output" != *"--volumes"* ]]
}

@test "down -v also removes the compose volumes" {
  DEVCONTAINER_SH_TEST_DOCKER_PS_OUT="abc123" DEVCONTAINER_SH_TEST_COMPOSE_PROJECT="myproj" \
    run devcontainer-sh down -v
  [ "$status" -eq 0 ]
  [[ "$output" == *"docker compose -p myproj down --remove-orphans --volumes"* ]]
}

@test "down brings a compose project down once however many containers match" {
  DEVCONTAINER_SH_TEST_DOCKER_PS_OUT=$'abc123\ndef456' DEVCONTAINER_SH_TEST_COMPOSE_PROJECT="myproj" \
    run devcontainer-sh down
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c 'docker compose')" -eq 1 ]
}

@test "down fails when docker compose fails" {
  DEVCONTAINER_SH_TEST_DOCKER_PS_OUT="abc123" DEVCONTAINER_SH_TEST_COMPOSE_PROJECT="myproj" \
    DEVCONTAINER_SH_TEST_COMPOSE_EXIT=3 run devcontainer-sh down
  [ "$status" -eq 3 ]
}

@test "down --help mentions compose and volumes" {
  run devcontainer-sh down --help
  [[ "$output" == *"compose"* ]]
  [[ "$output" == *"--volumes"* ]]
}
