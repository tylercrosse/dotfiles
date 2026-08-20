#!/usr/bin/env zsh
#
# ~/.zprofile — login shells only. Homebrew has to be set up here so that
# everything rc.zsh does can find brew-installed tools.

eval "$(/opt/homebrew/bin/brew shellenv)"

# OrbStack CLI integration
[[ -r "$HOME/.orbstack/shell/init.zsh" ]] && source "$HOME/.orbstack/shell/init.zsh"

# Obsidian CLI
[[ -d "/Applications/Obsidian.app/Contents/MacOS" ]] &&
  export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"
