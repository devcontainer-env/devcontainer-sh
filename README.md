# devcontainer-sh

> A thin wrapper around the devcontainer CLI — one command, workspace auto-detection, tab completion, and a GitHub Action for CI. Stop typing `--workspace-folder`.

[![CI](https://github.com/devcontainer-env/devcontainer-sh/actions/workflows/ci.yml/badge.svg)](https://github.com/devcontainer-env/devcontainer-sh/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/devcontainer-env/devcontainer-sh)](https://github.com/devcontainer-env/devcontainer-sh/releases/latest)
[![Shell: bash](https://img.shields.io/badge/shell-bash-4EAA25.svg?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

The upstream [`@devcontainers/cli`](https://github.com/devcontainers/cli) is powerful but verbose — nearly every invocation needs `--workspace-folder`, there's no first-class "shell into the container" verb, and rebuild-and-recreate is a stack of flags. This tool smooths those edges without hiding the underlying CLI: unknown flags pass straight through.

It is one bash script, so the same commands work in your terminal and in CI.

## Installation

### GitHub Actions

```yaml
steps:
  - uses: actions/checkout@v7
  - uses: devcontainer-env/devcontainer-sh@v1
  - run: devcontainer-sh up
  - run: devcontainer-sh exec -- make test
```

The action puts `devcontainer-sh` on `PATH` and installs the `devcontainer` CLI when it isn't already there. It doesn't start anything, so you choose when to `up`. GitHub-hosted runners are discarded after the job, so no cleanup is needed there. On self-hosted runners, add a step that always runs:

```yaml
  - run: devcontainer-sh down
    if: always()
```

| Input         | Description                                           | Default  |
| ------------- | ----------------------------------------------------- | -------- |
| `cli-version` | `@devcontainers/cli` version, if none is on `PATH`    | `latest` |

### Nix

```bash
nix run github:devcontainer-env/devcontainer-sh -- up
nix profile install github:devcontainer-env/devcontainer-sh
```

The package includes the zsh completions. It doesn't bundle the `devcontainer` CLI or Docker.

### Any shell

Put the `devcontainer-sh` script on your `PATH`:

```bash
git clone https://github.com/devcontainer-env/devcontainer-sh ~/.devcontainer-sh
echo 'export PATH="$HOME/.devcontainer-sh:$PATH"' >> ~/.bashrc
```

### zsh plugin managers

The plugin puts the script on `PATH` and registers the completions.

```bash
# oh-my-zsh
git clone https://github.com/devcontainer-env/devcontainer-sh \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/devcontainer-sh"
# then add devcontainer-sh to plugins=(...) in ~/.zshrc
```

```zsh
# zinit
zinit light devcontainer-env/devcontainer-sh
```

```text
# antidote (.zsh_plugins.txt)
devcontainer-env/devcontainer-sh
```

## Requirements

- bash 3.2+ (the macOS system bash is enough)
- [`@devcontainers/cli`](https://github.com/devcontainers/cli) on `$PATH` (`npm i -g @devcontainers/cli`)
- Docker (for the `down` command)

## Usage

```text
Usage: devcontainer-sh <command> [args...]

Commands:
  up          Create and start the dev container for this workspace
  shell, sh   Open an interactive shell inside the container
  exec        Run a one-off command in the container
  build       Build the dev container image
  down        Stop and remove the container associated with this workspace
  help        Show usage
  version     Wrapper version + upstream CLI version
```

**devcontainer-sh up** — Create and start the dev container. Auto-detects `--workspace-folder` by walking up from `$PWD` to find `.devcontainer/devcontainer.json` or `.devcontainer.json`.

```bash
devcontainer-sh up -R    # rebuild and recreate (-r remove + -n no-cache)
devcontainer-sh up -s    # skip post-create commands
```

Shortcut flags: `-r` → `--remove-existing-container`, `-n` → `--build-no-cache`, `-R` → both, `-s` → `--skip-post-create`.

**devcontainer-sh shell** — Open an interactive shell inside the running container. With no argument, picks the best available shell (`zsh` > `bash` > `sh`); pass a name to override.

```bash
devcontainer-sh shell           # auto-pick
devcontainer-sh shell bash      # force bash
devcontainer-sh sh fish         # short form
```

**devcontainer-sh exec** — Run a one-off command in the container. Everything is forwarded to `devcontainer exec`, and its exit status is passed through.

```bash
devcontainer-sh exec -- bash -lc 'pnpm test'
```

**devcontainer-sh build** — Build the dev container image.

```bash
devcontainer-sh build -n                       # --no-cache
devcontainer-sh build -p linux/amd64           # --platform linux/amd64
```

**devcontainer-sh down** — Stop and remove the container associated with the current workspace. Resolves the same `devcontainer.local_folder` label the CLI infers from `--workspace-folder`, then runs `docker rm -f`.

A compose-based dev container goes as a whole: the CLI labels only the workspace container, so `down` reads the compose project from it and runs `docker compose -p <project> down --remove-orphans`. Every service and the project's network are removed. Named volumes are kept, since they may hold data; pass `-v` to remove them too.

```bash
devcontainer-sh down        # keeps named volumes
devcontainer-sh down -v     # also removes them
```

If the same compose file is also run outside the dev container under the same project name, `down` stops that stack too.

## Configuration

### Workspace auto-detection

All commands walk up from `$PWD` looking for `.devcontainer/devcontainer.json` or `.devcontainer.json` and pass that directory as `--workspace-folder`. Pass `--workspace-folder` yourself to override. A `--workspace-folder` after a bare `--` belongs to the command you're running and is left alone.

### Pass-through

Unknown flags are forwarded to the upstream CLI untouched, so anything documented in `devcontainer up --help` / `exec --help` / `build --help` still works (`--log-level`, `--remote-env`, `--mount`, `--id-label`, `--secrets-file`, …).

### Tab completion

Zsh completions ship for `devcontainer-sh` and for the upstream `devcontainer` binary (`completions/_devcontainer-sh` and `completions/_devcontainer`). The zsh plugin and the Nix package both put them on `$fpath`; make sure `compinit` has been called in your `.zshrc`.

## License

[MIT](LICENSE) — Copyright (c) 2026 devcontainer-env

<!-- markdownlint-disable-file MD013 -->
