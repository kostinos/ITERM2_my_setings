#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
MODE=install
SHELL_SETUP=0
usage() {
  cat <<'HELP'
Usage: bash setup.sh [--dry-run | --check] [--shell]
  default     Install Brewfile packages and a separate iTerm2 dynamic profile.
  --shell     Also configure Oh My Zsh (robbyrussell, git) and Homebrew plugins.
  --dry-run   Show the plan without downloading or changing files.
  --check     Check packages and installed profile; do not change files.
HELP
}
for arg in "$@"; do
  case "$arg" in
    --dry-run) MODE=dry-run ;;
    --check) MODE=check ;;
    --shell) SHELL_SETUP=1 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; usage >&2; exit 2 ;;
  esac
done
if [[ "$(uname -s)" != Darwin ]]; then
  echo 'This setup is intended for macOS.' >&2; exit 1
fi
PROFILE_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
PROFILE="$PROFILE_DIR/kostinos.json"
CONFIG_DIR="$HOME/.config/kostinos-mac"
BREW="$(command -v brew || true)"
if [[ -z "$BREW" ]]; then
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$candidate" ]]; then BREW="$candidate"; break; fi
  done
fi
if [[ "$MODE" == dry-run ]]; then
  echo 'Plan: install Homebrew if missing, then Brewfile packages without planned upgrades.'
  echo "Install iTerm2 dynamic profile: $PROFILE"
  echo 'Existing Default profile is preserved; select Kostinos in iTerm2 manually.'
  if [[ "$SHELL_SETUP" == 1 ]]; then
    echo 'Install Oh My Zsh if missing; add a managed shell fragment to .zshrc.'
    echo 'Back up changed files; configure robbyrussell, git, completions and highlighting.'
  fi
  cat "$ROOT/Brewfile"
  exit 0
fi
if [[ "$MODE" == check ]]; then
  result=0
  if [[ -n "$BREW" ]]; then
    "$BREW" bundle check --file="$ROOT/Brewfile" || result=1
  else echo 'Missing Homebrew'; result=1; fi
  if ! cmp -s "$ROOT/iTerm2-Dynamic.json" "$PROFILE"; then
    echo 'iTerm2 managed profile is missing or differs from repository.'; result=1
  fi
  if [[ "$SHELL_SETUP" == 1 ]]; then
    if ! cmp -s "$ROOT/shell.zsh" "$CONFIG_DIR/shell.zsh" ||
       ! grep -Fqx 'source "$HOME/.config/kostinos-mac/shell.zsh"' "${ZDOTDIR:-$HOME}/.zshrc" 2>/dev/null ||
       [[ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
      echo 'Managed shell configuration is missing or differs.'; result=1
    fi
  fi
  exit "$result"
fi
if [[ -z "$BREW" ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  case "$(uname -m)" in
    arm64) BREW=/opt/homebrew/bin/brew ;;
    *) BREW=/usr/local/bin/brew ;;
  esac
fi
eval "$("$BREW" shellenv)"
backup() {
  if [[ -e "$1" || -L "$1" ]]; then
    local saved
    if [[ "$1" == "$PROFILE" ]]; then
      mkdir -p "$HOME/Library/Application Support/iTerm2/ProfileBackups"
      saved="$(mktemp "$HOME/Library/Application Support/iTerm2/ProfileBackups/kostinos.backup.XXXXXX")"
    else
      saved="$(mktemp "$1.backup.XXXXXX")"
    fi
    cp -p "$1" "$saved"
    echo "Backup: $saved"
  fi
}
install_file() {
  if ! cmp -s "$1" "$2"; then backup "$2"; cp "$1" "$2"; fi
}
"$BREW" bundle install --file="$ROOT/Brewfile" --no-upgrade
mkdir -p "$PROFILE_DIR"
install_file "$ROOT/iTerm2-Dynamic.json" "$PROFILE"
if [[ "$SHELL_SETUP" == 1 ]]; then
  if [[ ! -e "$HOME/.oh-my-zsh" ]]; then
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
  fi
  if [[ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
    echo '~/.oh-my-zsh exists but is not a valid Oh My Zsh installation.' >&2; exit 1
  fi
  mkdir -p "$CONFIG_DIR" "${ZDOTDIR:-$HOME}"
  install_file "$ROOT/shell.zsh" "$CONFIG_DIR/shell.zsh"
  ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"
  if ! grep -Fqx 'source "$HOME/.config/kostinos-mac/shell.zsh"' "$ZSHRC" 2>/dev/null; then
    backup "$ZSHRC"
    printf '\n# Managed by kostinos/ITERM2_my_setings\nsource "$HOME/.config/kostinos-mac/shell.zsh"\n' >> "$ZSHRC"
  fi
fi
echo 'Done. Open iTerm2, select the Kostinos profile, and start a new terminal session.'
