#!/usr/bin/env sh

set -eu

if command -v brew >/dev/null 2>&1; then
  echo "Homebrew already installed."
  exit 0
fi

echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
