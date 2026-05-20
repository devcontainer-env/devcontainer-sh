# devcontainer-sh

A zsh plugin that wraps the [`@devcontainers/cli`](https://github.com/devcontainers/cli)
with a single dispatcher command, workspace auto-detection, and tab completion.

The upstream CLI is powerful but verbose — nearly every invocation needs
`--workspace-folder`, there's no first-class "shell into the container" verb,
and rebuild-and-recreate is a stack of flags. This plugin smooths those edges
without hiding the underlying CLI: unknown flags pass straight through.

## Usage

```
devcontainer-sh <subcommand> [args...]
```

| Subcommand            | What it does                                                                 |
|-----------------------|------------------------------------------------------------------------------|
| `up`                  | `devcontainer up`, with `--workspace-folder` auto-detected                   |
| `shell`, `sh`         | Open an interactive shell inside the container (picks zsh > bash > sh)       |
| `exec`, `x`           | Run a one-off command in the container                                       |
| `build`, `b`          | `devcontainer build`                                                         |
| `down`                | Stop and remove the container associated with this workspace                 |
| `help`                | Show usage                                                                   |
| `version`             | Plugin version + upstream CLI version                                        |

### Shortcut flags

For `up`:

- `-r` → `--remove-existing-container`
- `-n` → `--build-no-cache`
- `-R` → both of the above
- `-s` → `--skip-post-create`

For `build`:

- `-n` → `--no-cache`
- `-p PLATFORM` → `--platform PLATFORM`

### Workspace auto-detection

All subcommands walk up from `$PWD` looking for `.devcontainer/devcontainer.json`
or `.devcontainer.json`, and pass that directory as `--workspace-folder`. Pass
`--workspace-folder` yourself to override.

### Examples

```sh
# Recreate the container and rebuild from scratch
devcontainer-sh up -R

# Drop into a shell inside the container
devcontainer-sh shell

# Run a command
devcontainer-sh exec -- bash -lc 'pnpm test'

# Tear it down
devcontainer-sh down
```

## Install

### oh-my-zsh

```sh
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

```
devcontainer-env/devcontainer-sh
```

### Manual

```zsh
git clone https://github.com/devcontainer-env/devcontainer-sh ~/.zsh/devcontainer-sh
echo 'source ~/.zsh/devcontainer-sh/devcontainer-sh.plugin.zsh' >> ~/.zshrc
```

## Requirements

- zsh 5.0+
- [`@devcontainers/cli`](https://github.com/devcontainers/cli) on `$PATH`
  (`npm i -g @devcontainers/cli`)
- Docker (for the `down` subcommand)

## License

MIT
