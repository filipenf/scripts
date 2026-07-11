# profile-soft-switch

Soft switch between **work** (default) and **personal** tool configs in a single
shell, via XDG and a few app-specific env vars.

Only affects that shell and processes it starts. Desktop/session apps keep their
normal paths.

## Setup

1. Source it from your interactive shell rc (e.g. `~/.bashrc`):

```bash
source "$HOME/scripts/profile-soft-switch/profile-soft-switch.sh"
```

1. Optionally show the active profile in the prompt:
   - **Starship** (this machine): `custom.soft_profile` reading `$SOFT_PROFILE`
     (🦉 work / 🏄 personal)
   - **PS1**: prepend something based on `$SOFT_PROFILE` if you don’t use
     Starship

## Usage

| Command       | Effect                         |
| ------------- | ------------------------------ |
| _(new shell)_ | applies **work**               |
| `work`        | switch this shell to work      |
| `personal`    | switch this shell to personal  |
| `profile`     | print active profile and paths |

## Layout

| Profile  | Config root                                       |
| -------- | ------------------------------------------------- |
| work     | `~/.profiles/work/.config` (and matching `XDG_*`) |
| personal | normal home XDG (`~/.config`, …)                  |

App overrides today: `GH_CONFIG_DIR`, `GIT_CONFIG_GLOBAL`, pinned `STARSHIP_CONFIG`.

## Notes

- Migrate per-app configs into the work tree as needed (e.g. `gh`, `opencode`).
- Don’t put OpenCode settings in `~/.opencode/` — OpenCode always merges that
  from `$HOME` and it overrides every profile. Use `$XDG_CONFIG_HOME/opencode/`
  instead.
- Git: `GIT_CONFIG_GLOBAL` points at `$XDG_CONFIG_HOME/git/config`, so
  `git config --global user.email=...` is per-profile. Set the work email once
  while in work mode.
- SSH keys stay in `~/.ssh`; use host aliases (e.g. `github-personal`) rather
  than splitting `~/.ssh`.
