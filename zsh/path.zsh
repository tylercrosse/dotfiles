#!/usr/bin/env zsh
#
# PATH and language/tool version managers.
#
# Every PATH entry on this machine belongs in this file. Installers like to
# append `export PATH=...` to ~/.zshrc; when that happens, move the line here
# and delete it from rc.zsh so there stays exactly one place to look.

# Keep $PATH unique. zsh dedupes on assignment with this set, which is why the
# old config could accumulate three copies of the same directory without notice.
typeset -U path PATH

# Prepend a directory to PATH, but only if it actually exists. The `-d` guard is
# what keeps a fresh machine from carrying PATH entries for uninstalled tools.
path_prepend() {
  [[ -d "$1" ]] && path=("$1" $path)
}

##############################
#  User binaries
##############################

path_prepend "$HOME/.local/bin"
path_prepend "$DOTFILES/bin"

##############################
#  Language runtimes
##############################

# python — pyenv
# `pyenv init -` costs ~150ms, almost all of it building a shell function that
# only `pyenv shell` needs. Put the shims on PATH directly (which is what makes
# python/pip resolve correctly) and defer the rest until `pyenv` is first run.
export PYENV_ROOT="$HOME/.pyenv"
path_prepend "$PYENV_ROOT/bin"
path_prepend "$PYENV_ROOT/shims"
if command -v pyenv >/dev/null 2>&1; then
  pyenv() {
    unfunction pyenv
    eval "$(command pyenv init -)"
    pyenv "$@"
  }
fi

# node — fnm
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env)"
fi

# node — pnpm
export PNPM_HOME="$HOME/Library/pnpm"
path_prepend "$PNPM_HOME"

# node — bun
export BUN_INSTALL="$HOME/.bun"
path_prepend "$BUN_INSTALL/bin"

# ruby — chruby
if [[ -r /opt/homebrew/opt/chruby/share/chruby/chruby.sh ]]; then
  source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
  source /opt/homebrew/opt/chruby/share/chruby/auto.sh
  chruby ruby-3.3.5 2>/dev/null
fi

# rust — cargo. Sourced from ~/.zshenv so non-interactive shells get it too.

# java — Spark/Hadoop need a JDK 17
if [[ -x /usr/libexec/java_home ]]; then
  export JAVA_HOME="$(/usr/libexec/java_home -v 17 2>/dev/null)"
  path_prepend "$JAVA_HOME/bin"
fi

##############################
#  Tools
##############################

# postgres — keg-only, so brew does not link it into PATH
path_prepend "/opt/homebrew/opt/postgresql@18/bin"

# TeX — https://tug.org/mactex/BasicTeX.pdf
path_prepend "/Library/TeX/texbin"
if [[ -d /Library/TeX/Distributions/.DefaultTeX/Contents/Man ]]; then
  export MANPATH="/Library/TeX/Distributions/.DefaultTeX/Contents/Man:$MANPATH"
fi

# AI coding CLIs
path_prepend "$HOME/.opencode/bin"
path_prepend "$HOME/.antigravity/antigravity/bin"
path_prepend "$HOME/.antigravity-ide/antigravity-ide/bin"
path_prepend "$HOME/.codeium/windsurf/bin"
