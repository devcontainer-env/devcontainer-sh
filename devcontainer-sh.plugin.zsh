# devcontainer-sh — zsh plugin entry.
#
# The tool is the bash executable in bin/; this file only puts it on PATH and
# registers the zsh completions, so oh-my-zsh, zinit, antidote or a plain
# `source` keep working.

0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

() {
  emulate -L zsh

  local plugin_dir="${1:A:h}"

  path=("$plugin_dir/bin" $path)
  fpath=("$plugin_dir/completions" $fpath)
} "$0"
