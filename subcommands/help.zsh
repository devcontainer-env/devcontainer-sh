_devcontainer_sh::help() {
  emulate -L zsh
  cat <<'EOF'
devcontainer-sh — zsh wrapper around the devcontainer CLI

Usage:
  devcontainer-sh <subcommand> [args...]

Subcommands:
  up [opts]              Create and start the dev container for this workspace
                         Shortcuts: -r remove-existing, -n build-no-cache,
                                    -R both, -s skip-post-create
  shell, sh [shell]      Open an interactive shell inside the container
                         (auto-picks zsh > bash > sh, or pass a shell name)
  exec <cmd> [args]      Run a one-off command in the container
  build [opts]           Build the container image  (-n no-cache, -p PLATFORM)
  down                   Stop and remove the container for this workspace
  help                   Show this help
  version                Show plugin and devcontainer CLI versions

All subcommands auto-detect --workspace-folder by walking up from $PWD to find
the nearest .devcontainer/devcontainer.json. Pass --workspace-folder explicitly
to override. Unknown flags are passed straight through to the upstream CLI.
EOF
}
