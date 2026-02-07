#!/usr/bin/env sh

set -eu

if command -v brew >/dev/null 2>&1; then
  echo "Homebrew already installed."
  exit 0
fi

os=$(uname -s | tr '[:upper:]' '[:lower:]')
if [ "$os" = "linux" ] && command -v apt-get >/dev/null 2>&1; then
  echo "Ensuring Linux prerequisites for Homebrew..."
  sudo apt-get update
  sudo apt-get install -y \
    build-essential \
    ca-certificates \
    curl \
    file \
    git \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    pkg-config \
    procps \
    xz-utils \
    zlib1g-dev
fi

echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
