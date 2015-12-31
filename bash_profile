export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/9.4/bin

# COLOR BLOCK

if [[ $COLORTERM = gnome-* && $TERM = xterm ]] && infocmp gnome-256color >/dev/null 2>&1; then
	export TERM=gnome-256color
elif infocmp xterm-256color >/dev/null 2>&1; then
	export TERM=xterm-256color
fi

if tput setaf 1 &> /dev/null; then
	tput sgr0
	if [[ $(tput colors) -ge 256 ]] 2>/dev/null; then
		MAGENTA=$(tput setaf 9)
		ORANGE=$(tput setaf 172)
		GREEN=$(tput setaf 190)
		PURPLE=$(tput setaf 141)
		WHITE=$(tput setaf 256)
	else
		MAGENTA=$(tput setaf 5)
		ORANGE=$(tput setaf 4)
		GREEN=$(tput setaf 2)
		PURPLE=$(tput setaf 1)
		WHITE=$(tput setaf 7)
	fi
	BOLD=$(tput bold)
	RESET=$(tput sgr0)
else
	MAGENTA="\033[1;31m"
	ORANGE="\033[1;33m"
	GREEN="\033[1;32m"
	PURPLE="\033[1;35m"
	WHITE="\033[1;37m"
	BOLD=""
	RESET="\033[m"
fi

function parse_git_dirty() {
	[[ $(git status 2> /dev/null | tail -n1) != "nothing to commit (working directory clean)" ]] && echo "*"
}

function parse_git_branch() {
	git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
}

# END COLOR BLOCK

if  [ -f $(brew --prefix)/etc/bash_completion ]; then
     source $(brew --prefix)/etc/bash_completion
   fi

   if  [ -f $(brew --prefix)/etc/bash_completion.d/git-prompt.sh ]; then
     source $(brew --prefix)/etc/bash_completion.d/git-prompt.sh
     GIT_PS1_SHOWDIRTYSTATE=1 # display the unstaged (*) and staged (+) indicators
     # set your prompt. path: \w, git branch & status: $(__git_ps1), newline: \n, dollar sign delimiter: \$
    #  PS1='\w$(__git_ps1) \n\ :) '
    #  PS1='\u \w $(__git_ps1) :)'
      PS1="\[\e]2;$PWD\[\a\]\[\e]1;\]$(basename "$(dirname "$PWD")")/ \[$WHITE\]in \[$GREEN\]\w\[$WHITE\]\$([[ -n \$(git branch 2> /dev/null) ]] && echo \" on \")\[$PURPLE\]\$(parse_git_branch)\[$WHITE\]\n\$ \[$RESET\]"
    # PS1="\[\e]2;$PWD\[\a\]\[\e]1;\]$(basename "$(dirname "$PWD")")/\W\[\a\]\[${BOLD}${MAGENTA}\]\u \[$WHITE\]at \[$ORANGE\]\h \[$WHITE\]in \[$GREEN\]\w\[$WHITE\]\$([[ -n \$(git branch 2> /dev/null) ]] && echo \" on \")\[$PURPLE\]\$(parse_git_branch)\[$WHITE\]\n\$ \[$RESET\]"
   fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
export GITHUB_USERNAME='tylercrosse'

##############################
#  Bash Aliases
##############################

alias ls="ls -GFh"

alias sandbox="cd ~/wdi/sandbox"
alias exercises="cd ~/wdi/exercises"
alias projects="cd ~/wdi/projects"

alias rspecc="rspec -c"
alias rspecf="rspec -c -fd"

##############################
#  Git Aliases
##############################

alias ga="git add"
alias gs="git status"
alias gc="git commit"
alias gcm="git commit -m"
alias gpo="git push origin"
alias gpom="git push origin master"
alias gphm="git push heroku master"

alias gl="git log --all --oneline --graph --decorate"
alias gpr="git log --pretty=format:'%Cblue%h%Creset %Cgreen%ad%Creset | %s%C(yellow)%d%Creset [%an]' --graph --date=short --decorate"
