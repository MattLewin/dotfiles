# TODO

- replace `direnv`, `virtualenv`, `nvm`, etc. with `asdf`?
- implement a git post-merge hook to determine whether the umbrella `Brewfile` or this host or architecture's specific ones have changed, and if so, performa a `brew file install`
- similar to above, if a submodule checksum has been updated, trigger `git submodule update`
- clone all submodules upon initial install instead of relying upon the cloner to do it
- replace `brew file` with Homebrew's `brew bundle`
- move AWS credentials and API tokens into secure GitHub storage?
