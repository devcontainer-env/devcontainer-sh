_dcsh::exec() {
  emulate -L zsh

  local -a args
  local arg
  local has_ws=0
  for arg in "$@"; do
    case "$arg" in
      --workspace-folder|--workspace-folder=*) has_ws=1 ;;
    esac
    args+=("$arg")
  done

  if (( ! has_ws )); then
    local ws; ws="$(_dcsh_resolve_workspace)"
    args=(--workspace-folder "$ws" $args)
  fi

  command devcontainer exec $args
}
