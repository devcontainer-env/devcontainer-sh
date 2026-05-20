_dcsh::shell() {
  emulate -L zsh

  local -a passthru
  local arg requested_shell=""
  local has_ws=0

  for arg in "$@"; do
    case "$arg" in
      --workspace-folder|--workspace-folder=*)
        has_ws=1
        passthru+=("$arg")
        ;;
      -*) passthru+=("$arg") ;;
      *)
        if [[ -z "$requested_shell" ]]; then
          requested_shell="$arg"
        else
          passthru+=("$arg")
        fi
        ;;
    esac
  done

  if (( ! has_ws )); then
    local ws; ws="$(_dcsh_resolve_workspace)"
    passthru=(--workspace-folder "$ws" $passthru)
  fi

  if [[ -n "$requested_shell" ]]; then
    command devcontainer exec $passthru "$requested_shell" -l
  else
    local picker; picker="$(_dcsh_pick_shell)"
    command devcontainer exec $passthru sh -c "exec ${picker} -l"
  fi
}
