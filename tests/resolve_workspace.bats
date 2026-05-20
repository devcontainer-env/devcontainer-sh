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
  devcontainer_sh_run "cd '$WS_ROOT'; _devcontainer_sh_resolve_workspace"
  [ "$status" -eq 0 ]
  [ "$(realpath "$output")" = "$(realpath "$WS_ROOT")" ]
}

@test "resolves workspace by walking up several levels" {
  devcontainer_sh_run "cd '$WS_ROOT/src/nested'; _devcontainer_sh_resolve_workspace"
  [ "$status" -eq 0 ]
  [ "$(realpath "$output")" = "$(realpath "$WS_ROOT")" ]
}

@test "falls back to PWD when no .devcontainer is found" {
  local elsewhere
  elsewhere="$(mktemp -d)"
  devcontainer_sh_run "cd '$elsewhere'; _devcontainer_sh_resolve_workspace"
  [ "$status" -eq 0 ]
  [ "$(realpath "$output")" = "$(realpath "$elsewhere")" ]
  rm -rf "$elsewhere"
}

@test "recognises a top-level .devcontainer.json file" {
  local alt
  alt="$(mktemp -d)"
  echo '{}' > "$alt/.devcontainer.json"
  devcontainer_sh_run "cd '$alt'; _devcontainer_sh_resolve_workspace"
  [ "$status" -eq 0 ]
  [ "$(realpath "$output")" = "$(realpath "$alt")" ]
  rm -rf "$alt"
}
