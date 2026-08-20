#!/usr/bin/env zsh
#
# Aliases. Functions live in functions.zsh.

############################################
#  Navigation - Movement & Manipulation
############################################

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias -- -="cd -"

alias mv='mv -v'
alias rm='rm -i -v'
alias cp='cp -v'

############################################
#  Listing - eza
############################################

# eza replaces the old coreutils `gls` setup: hidden files, trailing type
# indicators, and directories first are all built in, so the CLICOLOR_FORCE and
# `hash gls || alias gls=ls` dance is gone. Add --icons to any of these if you
# want glyphs; MesloLGS NF is installed, so they will render.
alias ls='eza --all --classify --group-directories-first'
alias ll='eza --all --long --classify --group-directories-first --git'
alias lsl='eza --long --header --group-directories-first'
alias lsd='eza --all --only-dirs'
alias lss='eza --all --classify --oneline'

# Tree views. --level replaces tree's -L; --git-ignore honours .gitignore, which
# is usually what the old 'node_modules|.git|.venv' ignore list was reaching for.
alias tre="eza --tree --level=1 --all"
alias tre2="eza --tree --level=2 --all --git-ignore --ignore-glob='.git|node_modules|.venv'"
alias tre3="eza --tree --level=3 --all --git-ignore --ignore-glob='.git|node_modules|.venv'"
alias tred="eza --tree --only-dirs --level=2"

############################################
#  Search & Display - ripgrep, fzf, bat
############################################

# fzf https://github.com/junegunn/fzf
export FZF_DEFAULT_OPTS='--color=16 --height 40% --reverse'
export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git/*"'

# ripgrep, hidden files included but not .git internals
alias rgh='rg --hidden --glob "!.git/*"'

# `cat` with syntax highlighting. Replaces hicat, and bat pipes through less
# itself, which is what the old LESSOPEN/highlight pair was doing.
alias c='bat'
alias less='less -m -N -g -i --underline-special'
export LESS=" -R"

##############################
#  Git Aliases
##############################

alias g="git"

alias gb="git branch"
alias gba="git branch -a"
# all branches sorted by date
alias gbad="git for-each-ref --sort='-authordate:iso8601' --color=auto --format=' %(authordate:relative)%09%1B[0;32m%(refname:short)%1B[m' refs/heads; git for-each-ref --sort='-authordate:iso8601' --color=auto --format=' %(authordate:relative)%09%1B[0;33m%(refname:short)%1B[m' refs/remotes"

# all branches sorted by date with author
alias gband="git for-each-ref --sort='-authordate:iso8601' --format='%(authordate:relative)    %(align:25,left)%(color:green)%(authorname)%(end) %(color:reset)%(refname:short)' refs/heads"

# all branches sorted by date with author, local and remote
alias gbanda="git for-each-ref --sort='-authordate:iso8601' --format='%(authordate:relative)    %(align:25,left)%(color:green)%(authorname)%(end) %(color:reset)%(refname:short)' refs/heads; git for-each-ref --sort='-authordate:iso8601' --format='%(authordate:relative)    %(align:25,left)%(color:yellow)%(authorname)%(end) %(color:reset)%(refname:short)' refs/remotes"

alias gch="git checkout"
alias gcb="git checkout -b"

alias gd="git diff"
alias gdc="git diff --cached"

alias ga="git add"
alias gs="git status"
alias gco="git commit"
alias gcoa="git commit --amend"
alias gcoan="git commit --amend --no-edit"
alias gcm="git commit -m"
alias gpom="git push origin master"

alias gbdm="git branch --merged | egrep -v '(^\*|master|dev)' | xargs git branch -d"

alias gl="git log --all --oneline --graph --decorate --date=relative --pretty=format:'%C(bold blue)%h%C(reset)%C(auto)%d%C(reset) %<(50,trunc)%s%C(reset) %C(green)(%ar)%C(reset) %C(dim white)- %an%C(reset)'"
alias glg="git log --all --oneline --graph --decorate"
alias gla='git log --all  --graph --decorate --pretty=format:"%C(yellow)%h%Creset %C(auto)%d%Creset %Cblue%ar%Creset %Cred%an%Creset %n%w(72,1,2)%s"'
alias gpr="git log --pretty=format:'%Cblue%h%Creset %Cgreen%ad%Creset | %s%C(yellow)%d%Creset [%an]' --graph --date=short --decorate"

##############################
#  Docker Aliases
##############################

alias dps="docker ps --format 'table {{.ID}}\t{{.Image}}\t{{.Status}}'"

##############################
#  Node / JS
##############################

alias nrn="npm run"
alias y="yarn"
alias yrun="cat package.json | jq .scripts"

alias pj="NODE_ENV=production jest"
alias jnw="jest --no-coverage --watch"
alias jcov="jest --coverage --coverageReporters=lcov"

##############################
#  Other Aliases
##############################

alias chro="open -a 'Google Chrome'"
alias chrd="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222"

alias oops='$(thefuck $(fc -ln -1))'

alias v='vim'

alias cleanmd="pbpaste | $DOTFILES/bin/md_tidy.py /dev/stdin | pbcopy && echo 'Markdown cleaned & copied! ✨'"

alias colortest="$DOTFILES/bin/colortest"

# peon-ping quick controls
alias peon="bash $HOME/.claude/hooks/peon-ping/peon.sh"

##############################
#  Colors
##############################

# generic colouriser — brew install grc
GRC=$(command -v grc)
if [ "$TERM" != dumb ] && [ -n "$GRC" ]; then
  alias colourify="$GRC -es --colour=auto"
  alias configure='colourify ./configure'
  for app in {diff,make,gcc,g++,ping,traceroute}; do
    alias "$app"='colourify '$app
  done
fi

# highlighting inside manpages and elsewhere
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

##############################
#  Network Aliases
##############################

alias jn="jupyter notebook"

# Networking. IP address, dig, DNS
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias dig="dig +nocmd any +multiline +noall +answer"

alias hs-o="http-server -o"
