# Shared bats helpers.
#
# Each test runs zsh in a clean environment with stubbed `devcontainer` and
# `docker` binaries on PATH. The stubs echo whatever args they receive so we
# can assert what the plugin dispatches.

PLUGIN_ROOT="${BATS_TEST_DIRNAME}/.."

setup_stubs() {
  STUB_DIR="$(mktemp -d)"
  cat > "$STUB_DIR/devcontainer" <<'STUB'
#!/bin/sh
echo "devcontainer $*"
STUB
  cat > "$STUB_DIR/docker" <<'STUB'
#!/bin/sh
case "$1" in
  ps) echo "${DCSH_TEST_DOCKER_PS_OUT-}" ;;
  *)  echo "docker $*" ;;
esac
STUB
  chmod +x "$STUB_DIR/devcontainer" "$STUB_DIR/docker"
  export PATH="$STUB_DIR:$PATH"
}

teardown_stubs() {
  [ -n "${STUB_DIR-}" ] && rm -rf "$STUB_DIR"
}

# Run a zsh snippet with the plugin sourced. Captures stdout via bats `run`.
dcsh_run() {
  run zsh -f -c "
    source '${PLUGIN_ROOT}/devcontainer-sh.plugin.zsh'
    $1
  "
}
