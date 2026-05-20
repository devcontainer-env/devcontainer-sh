_devcontainer_sh::down() {
  emulate -L zsh

  local ws=""
  local arg
  local -a rest
  while (( $# )); do
    arg="$1"
    case "$arg" in
      --workspace-folder)         ws="$2"; shift 2 ;;
      --workspace-folder=*)       ws="${arg#--workspace-folder=}"; shift ;;
      -h|--help)
        print -r -- "Usage: devcontainer-sh down [--workspace-folder PATH]"
        print -r -- "Stops and removes the dev container associated with the workspace."
        return 0
        ;;
      *)                          rest+=("$arg"); shift ;;
    esac
  done

  [[ -z "$ws" ]] && ws="$(_devcontainer_sh_resolve_workspace)"

  local label; label="$(_devcontainer_sh_id_label "$ws")"

  local -a ids
  ids=("${(@f)$(command docker ps -aq --filter "label=${label}")}")
  ids=(${ids:#})

  if (( ${#ids} == 0 )); then
    print -ru2 -- "devcontainer-sh down: no container found for label ${label}"
    return 1
  fi

  command docker rm -f $ids
}
