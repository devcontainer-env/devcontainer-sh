#!/usr/bin/env bats

load helpers

setup() {
  setup_stubs
  WS_ROOT="$(mktemp -d)"
  mkdir -p "$WS_ROOT/.devcontainer" "$WS_ROOT/src/nested"
  echo '{}' > "$WS_ROOT/.devcontainer/devcontainer.json"
}

teardown() {
  teardown_stubs
  rm -rf "$WS_ROOT"
}

@test "resolves workspace from inside .devcontainer parent" {
  dcsh_run "cd '$WS_ROOT'; _dcsh_resolve_workspace"
  [ "$status" -eq 0 ]
  [ "$(realpath "$output")" = "$(realpath "$WS_ROOT")" ]
}

@test "resolves workspace by walking up several levels" {
  dcsh_run "cd '$WS_ROOT/src/nested'; _dcsh_resolve_workspace"
  [ "$status" -eq 0 ]
  [ "$(realpath "$output")" = "$(realpath "$WS_ROOT")" ]
}

@test "falls back to PWD when no .devcontainer is found" {
  local elsewhere
  elsewhere="$(mktemp -d)"
  dcsh_run "cd '$elsewhere'; _dcsh_resolve_workspace"
  [ "$status" -eq 0 ]
  [ "$(realpath "$output")" = "$(realpath "$elsewhere")" ]
  rm -rf "$elsewhere"
}

@test "recognises a top-level .devcontainer.json file" {
  local alt
  alt="$(mktemp -d)"
  echo '{}' > "$alt/.devcontainer.json"
  dcsh_run "cd '$alt'; _dcsh_resolve_workspace"
  [ "$status" -eq 0 ]
  [ "$(realpath "$output")" = "$(realpath "$alt")" ]
  rm -rf "$alt"
}
