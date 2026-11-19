#!/usr/bin/env bats

load helpers

setup() {
  command -v zsh >/dev/null || skip "zsh is not installed"
  setup_stubs
}
teardown() { teardown_stubs; }

@test "sourcing the zsh plugin puts devcontainer-sh on PATH" {
  run env PATH="$STUB_DIR:/usr/bin:/bin:$(dirname "$(command -v zsh)")" zsh -f -c "
    source '$PLUGIN_ROOT/devcontainer-sh.plugin.zsh'
    command -v devcontainer-sh
  "
  [ "$status" -eq 0 ]
  [[ "$output" == */devcontainer-sh ]]
}

@test "sourcing the zsh plugin registers the completions" {
  run zsh -f -c "
    source '$PLUGIN_ROOT/devcontainer-sh.plugin.zsh'
    print -rl -- \$fpath
  "
  [ "$status" -eq 0 ]
  [[ "$output" == *"/completions"* ]]
}
