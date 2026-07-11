# shellcheck shell=bash
# Soft profile switch: work (default) vs personal via XDG + app-specific overrides.
#
# Usage (from ~/.bashrc, after interactive guard):
#   source ~/Sync/scripts/profile-soft-switch/profile-soft-switch.sh
#
# Commands:
#   work       # switch this shell to the work profile (default on source)
#   personal   # switch this shell to the personal profile
#   profile    # print the active profile and key paths
#
# Only affects this shell and processes it starts. GUI apps launched from the
# desktop/session keep the session XDG paths.

: "${SOFT_PROFILES_ROOT:=$HOME/.profiles}"
: "${SOFT_PROFILE_DEFAULT:=work}"

# Keep the prompt theme on the real home config even when XDG_CONFIG_HOME moves.
: "${SOFT_PROFILE_STARSHIP_CONFIG:=$HOME/.config/starship.toml}"

_soft_profile_mkdirs() {
  mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"
}

_soft_profile_app_overrides() {
  # gh honors GH_CONFIG_DIR over XDG; set it explicitly either way.
  export GH_CONFIG_DIR="$XDG_CONFIG_HOME/gh"
  mkdir -p "$GH_CONFIG_DIR"

  # ~/.gitconfig always wins over XDG; pin an explicit global file per profile
  # so `git config --global` only touches the active one.
  local gitconfig="$XDG_CONFIG_HOME/git/config"
  mkdir -p "$(dirname "$gitconfig")"
  if [[ ! -f "$gitconfig" ]]; then
    if [[ -f "$HOME/.config/git/config" && "$gitconfig" != "$HOME/.config/git/config" ]]; then
      cp "$HOME/.config/git/config" "$gitconfig"
    elif [[ -f "$HOME/.gitconfig" ]]; then
      cp "$HOME/.gitconfig" "$gitconfig"
    else
      : >"$gitconfig"
    fi
  fi
  export GIT_CONFIG_GLOBAL="$gitconfig"
}

_soft_profile_apply() {
  local name="${1:-$SOFT_PROFILE_DEFAULT}"

  case "$name" in
    work)
      export SOFT_PROFILE=work
      export XDG_CONFIG_HOME="$SOFT_PROFILES_ROOT/work/.config"
      export XDG_DATA_HOME="$SOFT_PROFILES_ROOT/work/.local/share"
      export XDG_STATE_HOME="$SOFT_PROFILES_ROOT/work/.local/state"
      export XDG_CACHE_HOME="$SOFT_PROFILES_ROOT/work/.cache"
      ;;
    personal)
      export SOFT_PROFILE=personal
      export XDG_CONFIG_HOME="${HOME}/.config"
      export XDG_DATA_HOME="${HOME}/.local/share"
      export XDG_STATE_HOME="${HOME}/.local/state"
      export XDG_CACHE_HOME="${HOME}/.cache"
      ;;
    *)
      echo "Unknown profile: $name (use work or personal)" >&2
      return 1
      ;;
  esac

  # Desktop/session tools that must not follow the profile redirect.
  export STARSHIP_CONFIG="$SOFT_PROFILE_STARSHIP_CONFIG"

  _soft_profile_mkdirs
  _soft_profile_app_overrides

  # OpenCode always merges ~/.opencode/ from $HOME (ignores XDG). That bleeds
  # across profiles; keep config under $XDG_CONFIG_HOME/opencode instead.
  if [[ -e "$HOME/.opencode" ]]; then
    echo "soft-profile: warning: $HOME/.opencode exists and overrides OpenCode profile configs" >&2
  fi
}

work() {
  _soft_profile_apply work
  echo "profile: work"
}

personal() {
  _soft_profile_apply personal
  echo "profile: personal"
}

profile() {
  printf 'profile: %s\n' "${SOFT_PROFILE:-unset}"
  printf '  XDG_CONFIG_HOME=%s\n' "${XDG_CONFIG_HOME:-}"
  printf '  XDG_DATA_HOME=%s\n' "${XDG_DATA_HOME:-}"
  printf '  XDG_STATE_HOME=%s\n' "${XDG_STATE_HOME:-}"
  printf '  XDG_CACHE_HOME=%s\n' "${XDG_CACHE_HOME:-}"
  printf '  GH_CONFIG_DIR=%s\n' "${GH_CONFIG_DIR:-}"
  printf '  GIT_CONFIG_GLOBAL=%s\n' "${GIT_CONFIG_GLOBAL:-}"
  printf '  STARSHIP_CONFIG=%s\n' "${STARSHIP_CONFIG:-}"
}

# Apply on source: inherit existing SOFT_PROFILE (e.g. nested shell), else work.
_soft_profile_apply "${SOFT_PROFILE:-$SOFT_PROFILE_DEFAULT}"
