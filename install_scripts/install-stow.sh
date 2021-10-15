#!/usr/bin/env bash

which -s stow && exit 0

if ! which -s brew
then
    echo "Please ensure 'brew' is installed and in your PATH."
    exit 1
fi

brew install stow
