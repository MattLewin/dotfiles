#!/usr/bin/env bash
curl -fsSL https://raw.github.com/rcmdnk/homebrew-file/install/install.sh |sh

cat <<"EOF"
Make sure you have added the following to your .zshrc...

if [ -f $(brew --prefix)/etc/brew-wrap ];then
  source $(brew --prefix)/etc/brew-wrap
fi
EOF

