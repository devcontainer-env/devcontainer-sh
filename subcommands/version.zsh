_dcsh::version() {
  emulate -L zsh
  print -r -- "devcontainer-sh ${DCSH_VERSION:-0.1.0}"
  if (( $+commands[devcontainer] )); then
    print -rn -- "devcontainer "
    command devcontainer --version
  else
    print -ru2 -- "devcontainer CLI not found in PATH"
    return 1
  fi
}
