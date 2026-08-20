#!/usr/bin/env zsh
#
# ~/.zshenv — sourced by every zsh, including non-interactive ones.
# Keep this minimal; anything interactive belongs in rc.zsh.

# rust
[[ -r "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
