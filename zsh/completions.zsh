#!/usr/bin/env zsh
#
# Completions. The old config called compinit twice (once for a Vagrant
# completion directory that no longer exists, once for Docker) and added an
# fpath entry pointing at a deleted directory. Collect fpath first, then run
# compinit exactly once.

# Personal completions
[[ -d "$HOME/.zsh/completions" ]] && fpath=("$HOME/.zsh/completions" $fpath)

# Docker Desktop
[[ -d "$HOME/.docker/completions" ]] && fpath=("$HOME/.docker/completions" $fpath)

# Homebrew-installed completions
if command -v brew >/dev/null 2>&1; then
  [[ -d "$(brew --prefix)/share/zsh/site-functions" ]] &&
    fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
fi

autoload -Uz compinit
# -C skips the security check against a cache newer than 20h, which is the
# single largest chunk of compinit's cost.
compinit -C

# fzf key bindings and completion
command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)

# z — jump to frequently used directories. https://github.com/rupa/z
[[ -r /opt/homebrew/etc/profile.d/z.sh ]] && source /opt/homebrew/etc/profile.d/z.sh

# bun
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# peon-ping
[[ -f "$HOME/.claude/hooks/peon-ping/completions.bash" ]] &&
  source "$HOME/.claude/hooks/peon-ping/completions.bash"
