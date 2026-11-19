# Shared bats helpers.
#
# Each test runs the real devcontainer-sh with stubbed `devcontainer` and
# `docker` binaries first on PATH. The stubs echo whatever args they receive so
# we can assert what the wrapper dispatches.

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
  ps)      echo "${DEVCONTAINER_SH_TEST_DOCKER_PS_OUT-}" ;;
  inspect) echo "${DEVCONTAINER_SH_TEST_COMPOSE_PROJECT-}" ;;
  compose) echo "docker $*"; exit "${DEVCONTAINER_SH_TEST_COMPOSE_EXIT-0}" ;;
  *)       echo "docker $*" ;;
esac
STUB
  chmod +x "$STUB_DIR/devcontainer" "$STUB_DIR/docker"
  export PATH="$PLUGIN_ROOT:$STUB_DIR:$PATH"
}

teardown_stubs() {
  [ -n "${STUB_DIR-}" ] && rm -rf "$STUB_DIR"
  return 0
}

# A temporary workspace with a .devcontainer/devcontainer.json, in WS_ROOT.
make_workspace() {
  WS_ROOT="$(mktemp -d)"
  mkdir -p "$WS_ROOT/.devcontainer"
  echo '{}' > "$WS_ROOT/.devcontainer/devcontainer.json"
}
