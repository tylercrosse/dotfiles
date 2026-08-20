#!/usr/bin/env zsh
#
# ~/.zshrc — symlinked from ~/dev/dotfiles/zsh/rc.zsh
#
# Installers append `export PATH=...` and `source ...` lines to the bottom of
# ~/.zshrc. That still happens, but because this file is tracked, the change
# shows up in `git -C ~/dev/dotfiles status`. When it does: move the line into
# path.zsh (for PATH) or completions.zsh (for completions), then revert here.
# That review step is the whole point of the symlink.

export DOTFILES="${DOTFILES:-$HOME/dev/dotfiles}"

source "$DOTFILES/zsh/path.zsh"
source "$DOTFILES/zsh/aliases.zsh"
source "$DOTFILES/zsh/functions.zsh"
source "$DOTFILES/zsh/completions.zsh"
source "$DOTFILES/zsh/prompt.zsh"

# Machine-specific settings that should not be tracked: work credentials,
# one-off PATH entries, per-machine overrides.
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# ---- installer additions land below; triage them into the files above ----
