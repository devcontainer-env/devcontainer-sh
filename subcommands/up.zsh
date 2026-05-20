_devcontainer_sh::up() {
  emulate -L zsh

  local -a args extras
  local arg
  local has_ws=0
  for arg in "$@"; do
    case "$arg" in
      -r) extras+=(--remove-existing-container) ;;
      -n) extras+=(--build-no-cache) ;;
      -R) extras+=(--remove-existing-container --build-no-cache) ;;
      -s) extras+=(--skip-post-create) ;;
      --workspace-folder|--workspace-folder=*)
        has_ws=1
        args+=("$arg")
        ;;
      *) args+=("$arg") ;;
    esac
  done

  if (( ! has_ws )); then
    local ws; ws="$(_devcontainer_sh_resolve_workspace)"
    args=(--workspace-folder "$ws" $args)
  fi

  command devcontainer up $extras $args
}
