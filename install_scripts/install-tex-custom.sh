#!/usr/bin/env bash
echo "We are no longer installing LaTex"
exit 0

set -o errexit
set -o nounset

TEX_DIR="$(pwd)/tex"

echo "Setting up local LaTex paths"

ln -sF "${TEX_DIR}/texmf" "${HOME}/Library"
texhash >/dev/null 2>&1
