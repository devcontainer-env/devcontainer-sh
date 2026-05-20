_dcsh::build() {
  emulate -L zsh

  local -a args extras
  local arg
  local has_ws=0
  local capture_platform=0
  for arg in "$@"; do
    if (( capture_platform )); then
      extras+=(--platform "$arg")
      capture_platform=0
      continue
    fi
    case "$arg" in
      -n) extras+=(--no-cache) ;;
      -p) capture_platform=1 ;;
      --workspace-folder|--workspace-folder=*)
        has_ws=1
        args+=("$arg")
        ;;
      *) args+=("$arg") ;;
    esac
  done

  if (( ! has_ws )); then
    local ws; ws="$(_dcsh_resolve_workspace)"
    args=(--workspace-folder "$ws" $args)
  fi

  command devcontainer build $extras $args
}
