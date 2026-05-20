# devcontainer-sh

> Zsh plugin for the devcontainer CLI — one dispatcher command, workspace auto-detection, and tab completion. Stop typing `--workspace-folder`.

[![CI](https://github.com/devcontainer-env/devcontainer-sh/actions/workflows/ci.yml/badge.svg)](https://github.com/devcontainer-env/devcontainer-sh/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/devcontainer-env/devcontainer-sh)](https://github.com/devcontainer-env/devcontainer-sh/releases/latest)
[![Shell: zsh](https://img.shields.io/badge/shell-zsh-1793D1.svg)](https://www.zsh.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

The upstream [`@devcontainers/cli`](https://github.com/devcontainers/cli) is powerful but verbose — nearly every invocation needs `--workspace-folder`, there's no first-class "shell into the container" verb, and rebuild-and-recreate is a stack of flags. This plugin smooths those edges without hiding the underlying CLI: unknown flags pass straight through.

## Installation

### oh-my-zsh

```bash
git clone https://github.com/devcontainer-env/devcontainer-sh \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/devcontainer-sh"
```

Then add `devcontainer-sh` to the `plugins=(...)` line in your `.zshrc`.

### zinit

```zsh
zinit light devcontainer-env/devcontainer-sh
```

### antidote

Add to your `.zsh_plugins.txt`:

```text
devcontainer-env/devcontainer-sh
```

### Manual

```zsh
git clone https://github.com/devcontainer-env/devcontainer-sh ~/.zsh/devcontainer-sh
echo 'source ~/.zsh/devcontainer-sh/devcontainer-sh.plugin.zsh' >> ~/.zshrc
```

## Requirements

- zsh 5.0+
- [`@devcontainers/cli`](https://github.com/devcontainers/cli) on `$PATH` (`npm i -g @devcontainers/cli`)
- Docker (for the `down` subcommand)

## Usage

```text
Usage: devcontainer-sh <subcommand> [args...]

Subcommands:
  up          Create and start the dev container for this workspace
  shell, sh   Open an interactive shell inside the container
  exec        Run a one-off command in the container
  build       Build the dev container image
  down        Stop and remove the container associated with this workspace
  help        Show usage
  version     Plugin version + upstream CLI version
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

**devcontainer-sh exec** — Run a one-off command in the container. Everything is forwarded to `devcontainer exec`.

```bash
devcontainer-sh exec -- bash -lc 'pnpm test'
```

**devcontainer-sh build** — Build the dev container image.

```bash
devcontainer-sh build -n                       # --no-cache
devcontainer-sh build -p linux/amd64           # --platform linux/amd64
```

**devcontainer-sh down** — Stop and remove the container associated with the current workspace. Resolves the same `devcontainer.local_folder` label the CLI infers from `--workspace-folder`, then runs `docker rm -f`.

```bash
devcontainer-sh down
```

## Configuration

### Workspace auto-detection

All subcommands walk up from `$PWD` looking for `.devcontainer/devcontainer.json` or `.devcontainer.json` and pass that directory as `--workspace-folder`. Pass `--workspace-folder` yourself to override.

### Pass-through

Unknown flags are forwarded to the upstream CLI untouched, so anything documented in `devcontainer up --help` / `exec --help` / `build --help` still works (`--log-level`, `--remote-env`, `--mount`, `--id-label`, …).

### Tab completion

The plugin ships `_devcontainer-sh` (dispatcher) and `_devcontainer` (upstream binary) completion files. Both are added to `$fpath` on load — make sure `compinit` has been called in your `.zshrc` (oh-my-zsh / zinit / antidote do this for you).

## License

[MIT](LICENSE) — Copyright (c) 2026 devcontainer-env

<!-- markdownlint-disable-file MD013 -->
