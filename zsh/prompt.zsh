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
# The dirty marker does shell out, once, to `git status`. Measured: 14ms in a
# small repo, 32ms in grpc (9.5k files, 947MB). The flag doing the work is
# --ignore-submodules=all -- without it git recurses into every submodule and
# grpc costs 402ms instead of 32ms. That single flag is the whole reason this
# needs no async machinery, no daemon, and no prompt framework.
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

# Is the working tree dirty? One `git status`, submodules skipped. Set
# PROMPT_NO_GIT_DIRTY=1 in ~/.zshrc.local to drop this and get a prompt that
# never shells out at all.
_prompt_git_dirty() {
  [[ -n $PROMPT_NO_GIT_DIRTY ]] && return 1
  [[ -n $(command git status --porcelain --ignore-submodules=all 2>/dev/null) ]]
}

_prompt_precmd() {
  local REPLY
  _prompt_git_branch
  if [[ -n $REPLY ]]; then
    _PROMPT_GIT=" %F{magenta}${REPLY}%f"
    _prompt_git_dirty && _PROMPT_GIT+=" %F{yellow}✚%f"
  else
    _PROMPT_GIT=
  fi
}
add-zsh-hook precmd _prompt_precmd

# %~       cwd, with $HOME shown as ~
# %(?..X)  X only when the previous command exited non-zero
PROMPT='
%F{blue}%~%f${_PROMPT_GIT}
%(?..%F{red}✗%f )%F{cyan}❯%f '
