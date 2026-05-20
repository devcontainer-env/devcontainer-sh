# devcontainer-sh — zsh wrapper around the devcontainer CLI.
# Works with oh-my-zsh, zinit, antidote, or plain `source`.

DEVCONTAINER_SH_VERSION="0.1.0"

0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

() {
  emulate -L zsh

  local plugin_dir="${1:A:h}"

  fpath=("$plugin_dir/functions" "$plugin_dir/completions" $fpath)

  autoload -Uz _devcontainer_sh_dispatch _devcontainer_sh_resolve_workspace _devcontainer_sh_pick_shell _devcontainer_sh_id_label

  local f
  for f in "$plugin_dir"/subcommands/*.zsh(N); do
    source "$f"
  done
} "$0"

devcontainer-sh() {
  _devcontainer_sh_dispatch "$@"
}
