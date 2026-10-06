#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if ! command -v brew >/dev/null 2>&1; then
  echo "Install Homebrew from https://brew.sh, then rerun this script." >&2
  exit 1
fi
brew bundle install --file="$SCRIPT_DIR/Brewfile" --no-upgrade
