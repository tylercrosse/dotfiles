#!/usr/bin/env zsh
#
# Prompt: path, git branch, exit status. Two lines, so a long path never
# squeezes the command you are typing.
#
#   ~/dev/dotfiles  master
#   ❯
#
# Replaced powerlevel10k (3.5MB, an 1842-line generated config, and one
# background gitstatusd daemon per shell session).

# VS Code shell integration. Checked before the Warp bail-out below; the two
# terminals are mutually exclusive, but this keeps the intent obvious.
if [[ "$TERM_PROGRAM" == "vscode" ]] && command -v code >/dev/null 2>&1; then
  # RPROMPT confuses VS Code's command detection
  unset RPROMPT RPS1
  source "$(code --locate-shell-integration-path zsh)"
fi

# Warp runs with HonorPS1=false: it ignores the shell's prompt and renders its
# own chips. Everything below would be computed and discarded, so stop here.
[[ "$TERM_PROGRAM" == "WarpTerminal" ]] && return

autoload -Uz add-zsh-hook
setopt prompt_subst

# Branch name without spawning git. `git rev-parse` costs ~10ms per prompt and
# `vcs_info` ~33ms before it even looks at the repo; reading .git/HEAD costs
# nothing measurable, and $(<file) is a zsh builtin that does not fork.
#
# Deliberately no dirty (✚/●) marker: computing one means `git status`, which
# is ~12ms in a normal repo but ~450ms in a large one, on every prompt. Warp's
# GitDiffStats chip covers it where it is most used. Doing it properly means
# an async background job with a zle redraw -- worth adding if it is missed.
_prompt_git_branch() {
  local dir=$PWD gitdir head
  REPLY=

  while [[ -n $dir && $dir != / ]]; do
    [[ -e $dir/.git ]] && { gitdir=$dir/.git; break }
    dir=${dir:h}
  done
  [[ -n $gitdir ]] || return

  # For a worktree or submodule, .git is a file holding "gitdir: <path>"
  if [[ -f $gitdir ]]; then
    head=$(<$gitdir)
    gitdir=${head#gitdir: }
  fi

  [[ -r $gitdir/HEAD ]] || return
  head=$(<$gitdir/HEAD)

  if [[ $head == ref:* ]]; then
    # Strip the full prefix, not everything up to the last slash, so that a
    # branch named feature/foo does not display as just "foo".
    REPLY=${head#ref: refs/heads/}
  else
    REPLY=${head[1,7]}   # detached HEAD: short sha
  fi
}

_prompt_precmd() {
  local REPLY
  _prompt_git_branch
  _PROMPT_GIT=${REPLY:+ %F{magenta}${REPLY}%f}
}
add-zsh-hook precmd _prompt_precmd

# %~       cwd, with $HOME shown as ~
# %(?..X)  X only when the previous command exited non-zero
PROMPT='
%F{blue}%~%f${_PROMPT_GIT}
%(?..%F{red}✗%f )%F{cyan}❯%f '
