#!/usr/bin/env bash

# Sexy bash prompt by twolfson
# https://github.com/twolfson/sexy-bash-prompt
# Forked from gf3, https://gist.github.com/gf3/306785
# Some portions from Paul Irish
# https://github.com/paulirish/dotfiles/blob/master/.bash_prompt

set_prompts() {

  # If we are on a colored terminal
  if tput setaf 1 &> /dev/null; then
    # Reset the shell from our `if` check
    tput sgr0 &> /dev/null

    # If you would like to customize your colors, use
    # # Attribution: http://linuxtidbits.wordpress.com/2008/08/11/output-color-on-bash-scripts/
    # https://upload.wikimedia.org/wikipedia/en/1/15/Xterm_256color_chart.svg
    # for i in $(seq 0 $(tput colors)); do
    #   echo " $(tput setaf $i)Text$(tput sgr0) $(tput bold)$(tput setaf $i)Text$(tput sgr0) $(tput sgr 0 1)$(tput setaf $i)Text$(tput sgr0)  \$(tput setaf $i)"
    # done

    # Save common color actions
    sbp_bold="$(tput bold)"
    sbp_reset="$(tput sgr0)"

    # If the terminal supports at least 256 colors, write out our 256 color based set
    if [[ "$(tput colors)" -ge 256 ]] &> /dev/null; then
      sbp_blue="$sbp_bold$(tput setaf 27)" # BOLD BLUE
      sbp_white="$sbp_bold$(tput setaf 7)" # BOLD WHITE
      sbp_cyan="$sbp_bold$(tput setaf 39)" # BOLD CYAN
      sbp_green="$sbp_bold$(tput setaf 76)" # BOLD GREEN
      sbp_yellow="$sbp_bold$(tput setaf 154)" # BOLD YELLOW
      sbp_red="$sbp_bold$(tput setaf 9)" # BOLD RED

      black=$(tput setaf 0)
      blue=$(tput setaf 33)
      cyan=$(tput setaf 37)
      green=$(tput setaf 190)
      orange=$(tput setaf 172)
      purple=$(tput setaf 141)
      red=$(tput setaf 124)
      violet=$(tput setaf 61)
      magenta=$(tput setaf 9)
      white=$(tput setaf 8)
      yellow=$(tput setaf 136)
    else
    # Otherwise, use colors from our set of 8
      sbp_blue="$sbp_bold$(tput setaf 4)" # BOLD BLUE
      sbp_white="$sbp_bold$(tput setaf 7)" # BOLD WHITE
      sbp_cyan="$sbp_bold$(tput setaf 6)" # BOLD CYAN
      sbp_green="$sbp_bold$(tput setaf 2)" # BOLD GREEN
      sbp_yellow="$sbp_bold$(tput setaf 3)" # BOLD YELLOW
      sbp_red="$sbp_bold$(tput setaf 1)" # BOLD RED
    fi

    symbol_color="$sbp_bold" # BOLD

  else
  # Otherwise, use ANSI escape sequences for coloring
    # If you would like to customize your colors, use
    # DEV: 30-39 lines up 0-9 from `tput`
    # for i in $(seq 0 109); do
    #   echo -n -e "\033[1;${i}mText$(tput sgr0) "
    #   echo "\033[1;${i}m"
    # done

    sbp_reset="\033[m"
    sbp_blue="\033[1;34m" # BLUE
    sbp_white="\033[1;37m" # WHITE
    sbp_cyan="\033[1;36m" # CYAN
    sbp_green="\033[1;32m" # GREEN
    sbp_yellow="\033[1;33m" # YELLOW
    sbp_red="\033[1;31m" # RED
    symbol_color="" # NORMAL

    bold=""
    reset="\e[0m"

    black="\e[1;30m"
    blue="\e[1;34m"
    cyan="\e[1;36m"
    green="\e[1;32m"
    orange="\e[1;33m"
    purple="\e[1;35m"
    red="\e[1;31m"
    magenta="\e[1;31m"
    violet="\e[1;35m"
    white="\e[1;37m"
    yellow="\e[1;33m"
  fi

  # Define the default prompt terminator character '$'
  if [[ "$UID" == 0 ]]; then
    symbol="#"
  else
    symbol="\$"
  fi

  # Apply any color overrides that have been set in the environment
  if [[ -n "$PROMPT_sbp_blue" ]]; then sbp_blue="$PROMPT_sbp_blue"; fi
  if [[ -n "$PROMPT_sbp_white" ]]; then sbp_white="$PROMPT_sbp_white"; fi
  if [[ -n "$PROMPT_sbp_cyan" ]]; then sbp_cyan="$PROMPT_sbp_cyan"; fi
  if [[ -n "$PROMPT_sbp_green" ]]; then sbp_green="$PROMPT_sbp_green"; fi
  if [[ -n "$PROMPT_sbp_yellow" ]]; then sbp_yellow="$PROMPT_sbp_yellow"; fi
  if [[ -n "$PROMPT_sbp_red" ]]; then sbp_red="$PROMPT_sbp_red"; fi
  if [[ -n "$PROMPT_SYMBOL" ]]; then symbol="$PROMPT_SYMBOL"; fi
  if [[ -n "$PROMPT_SYMBOL_COLOR" ]]; then symbol_color="$PROMPT_SYMBOL_COLOR"; fi

  # Set up symbols
  synced_symbol=""
  dirty_synced_symbol="*"
  unpushed_symbol="△"
  dirty_unpushed_symbol="▲"
  unpulled_symbol="▽"
  dirty_unpulled_symbol="▼"
  unpushed_unpulled_symbol="⬡"
  dirty_unpushed_unpulled_symbol="⬢"

  # Apply symbol overrides that have been set in the environment
  # DEV: Working unicode symbols can be determined via the following gist
  #   **WARNING: The following gist has 64k lines and may freeze your browser**
  #   https://gist.github.com/twolfson/9cc7968eb6ee8b9ad877
  if [[ -n "$PROMPT_SYNCED_SYMBOL" ]]; then synced_symbol="$PROMPT_SYNCED_SYMBOL"; fi
  if [[ -n "$PROMPT_DIRTY_SYNCED_SYMBOL" ]]; then dirty_synced_symbol="$PROMPT_DIRTY_SYNCED_SYMBOL"; fi
  if [[ -n "$PROMPT_UNPUSHED_SYMBOL" ]]; then unpushed_symbol="$PROMPT_UNPUSHED_SYMBOL"; fi
  if [[ -n "$PROMPT_DIRTY_UNPUSHED_SYMBOL" ]]; then dirty_unpushed_symbol="$PROMPT_DIRTY_UNPUSHED_SYMBOL"; fi
  if [[ -n "$PROMPT_UNPULLED_SYMBOL" ]]; then unpulled_symbol="$PROMPT_UNPULLED_SYMBOL"; fi
  if [[ -n "$PROMPT_DIRTY_UNPULLED_SYMBOL" ]]; then dirty_unpulled_symbol="$PROMPT_DIRTY_UNPULLED_SYMBOL"; fi
  if [[ -n "$PROMPT_UNPUSHED_UNPULLED_SYMBOL" ]]; then unpushed_unpulled_symbol="$PROMPT_UNPUSHED_UNPULLED_SYMBOL"; fi
  if [[ -n "$PROMPT_DIRTY_UNPUSHED_UNPULLED_SYMBOL" ]]; then dirty_unpushed_unpulled_symbol="$PROMPT_DIRTY_UNPUSHED_UNPULLED_SYMBOL"; fi

  function get_git_branch() {
    # On branches, this will return the branch name
    # On non-branches, (no branch)
    ref="$(git symbolic-ref HEAD 2> /dev/null | sed -e 's/refs\/heads\///')"
    if [[ "$ref" != "" ]]; then
      echo "$ref"
    else
      echo "(no branch)"
    fi
  }

  function get_git_progress() {
    # Detect in-progress actions (e.g. merge, rebase)
    # https://github.com/git/git/blob/v1.9-rc2/wt-status.c#L1199-L1241
    git_dir="$(git rev-parse --git-dir)"

    # git merge
    if [[ -f "$git_dir/MERGE_HEAD" ]]; then
      echo " [merge]"
    elif [[ -d "$git_dir/rebase-apply" ]]; then
      # git am
      if [[ -f "$git_dir/rebase-apply/applying" ]]; then
        echo " [am]"
      # git rebase
      else
        echo " [rebase]"
      fi
    elif [[ -d "$git_dir/rebase-merge" ]]; then
      # git rebase --interactive/--merge
      echo " [rebase]"
    elif [[ -f "$git_dir/CHERRY_PICK_HEAD" ]]; then
      # git cherry-pick
      echo " [cherry-pick]"
    fi
    if [[ -f "$git_dir/BISECT_LOG" ]]; then
      # git bisect
      echo " [bisect]"
    fi
    if [[ -f "$git_dir/REVERT_HEAD" ]]; then
      # git revert --no-commit
      echo " [revert]"
    fi
  }

  is_branch1_behind_branch2 () {
    # $ git log origin/master..master -1
    # commit 4a633f715caf26f6e9495198f89bba20f3402a32
    # Author: Todd Wolfson <todd@twolfson.com>
    # Date:   Sun Jul 7 22:12:17 2013 -0700
    #
    #     Unsynced commit

    # Find the first log (if any) that is in branch1 but not branch2
    first_log="$(git log $1..$2 -1 2> /dev/null)"

    # Exit with 0 if there is a first log, 1 if there is not
    [[ -n "$first_log" ]]
  }

  branch_exists () {
    # List remote branches           | # Find our branch and exit with 0 or 1 if found/not found
    git branch --remote 2> /dev/null | grep --quiet "$1"
  }

  parse_git_ahead () {
    # Grab the local and remote branch
    branch="$(get_git_branch)"
    remote_branch="origin/$branch"

    # $ git log origin/master..master
    # commit 4a633f715caf26f6e9495198f89bba20f3402a32
    # Author: Todd Wolfson <todd@twolfson.com>
    # Date:   Sun Jul 7 22:12:17 2013 -0700
    #
    #     Unsynced commit

    # If the remote branch is behind the local branch
    # or it has not been merged into origin (remote branch doesn't exist)
    if (is_branch1_behind_branch2 "$remote_branch" "$branch" ||
        ! branch_exists "$remote_branch"); then
      # echo our character
      echo 1
    fi
  }

  parse_git_behind () {
    # Grab the branch
    branch="$(get_git_branch)"
    remote_branch="origin/$branch"

    # $ git log master..origin/master
    # commit 4a633f715caf26f6e9495198f89bba20f3402a32
    # Author: Todd Wolfson <todd@twolfson.com>
    # Date:   Sun Jul 7 22:12:17 2013 -0700
    #
    #     Unsynced commit

    # If the local branch is behind the remote branch
    if is_branch1_behind_branch2 "$branch" "$remote_branch"; then
      # echo our character
      echo 1
    fi
  }

  function parse_git_dirty() {
    # If the git status has *any* changes (e.g. dirty), echo our character
    if [[ -n "$(git status --porcelain 2> /dev/null)" ]]; then
      echo 1
    fi
  }

  function is_on_git() {
    git rev-parse 2> /dev/null
  }

  function get_git_status() {
    # Grab the git dirty and git behind
    dirty_branch="$(parse_git_dirty)"
    branch_ahead="$(parse_git_ahead)"
    branch_behind="$(parse_git_behind)"

    # Iterate through all the cases and if it matches, then echo
    if [[ "$dirty_branch" == 1 && "$branch_ahead" == 1 && "$branch_behind" == 1 ]]; then
      echo "$dirty_unpushed_unpulled_symbol"
    elif [[ "$branch_ahead" == 1 && "$branch_behind" == 1 ]]; then
      echo "$unpushed_unpulled_symbol"
    elif [[ "$dirty_branch" == 1 && "$branch_ahead" == 1 ]]; then
      echo "$dirty_unpushed_symbol"
    elif [[ "$branch_ahead" == 1 ]]; then
      echo "$unpushed_symbol"
    elif [[ "$dirty_branch" == 1 && "$branch_behind" == 1 ]]; then
      echo "$dirty_unpulled_symbol"
    elif [[ "$branch_behind" == 1 ]]; then
      echo "$unpulled_symbol"
    elif [[ "$dirty_branch" == 1 ]]; then
      echo "$dirty_synced_symbol"
    else # clean
      echo "$synced_symbol"
    fi
  }

  get_git_info () {
    # Grab the branch
    branch="$(get_git_branch)"

    # If there are any branches
    if [[ "$branch" != "" ]]; then
      # Echo the branch
      output="$branch"

      # Add on the git status
      output="$output$(get_git_status)"

      # Echo our output
      echo "$output"
    fi
  }

  # Define the sexy-bash-prompt
  PS1="\[$sbp_yellow\]\u\[$sbp_reset\]"
  PS1+="\[$white\] at \[$sbp_reset\]"
  PS1+="\[$sbp_green\]\h\[$sbp_reset\]"
  PS1+="\[$white\] in \[$sbp_reset\]"
  PS1+="\[$sbp_cyan\]\w\[$sbp_reset\]"
  PS1+="\$( is_on_git && \
    echo -n \"\[$white\] on\[$sbp_reset\] \" && \
    echo -n \"\[$sbp_blue\]\$(get_git_info)\" && \
    echo -n \"\[$purple\]\$(get_git_progress)\" && \
    echo -n \"\[$white\]\")\n\[$sbp_reset\]"
  PS1+="\[$white\]$symbol \[$sbp_reset\]"

  export PS1

  export PS2="⚡ "

  export PS4='+ \011\e[1;30m\t\011\e[1;34m${BASH_SOURCE}\e[0m:\e[1;36m${LINENO}\e[0m \011 ${FUNCNAME[0]:+\e[0;35m${FUNCNAME[0]}\e[1;30m()\e[0m:\011\011 }'

}

set_prompts
unset set_prompts

############################################
#  Navigation - Movement & Manipulation
############################################

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias -- -="cd -"

# cd into whatever is the forefront Finder window.
function cdf() {  # short for cdfinder
  cd "`osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)'`"
}

# Create a new directory and enter it
function md() {
	mkdir -p "$@" && cd "$@"
}

alias mv='mv -v'
alias rm='rm -i -v'
alias cp='cp -v'

############################################
#  Navigation - Search & Display
############################################

# `cat` with beautiful colors. requires: sudo easy_install -U Pygments
alias c='pygmentize -O style=monokai -f console256 -g'

# brew install the_silver_searcher
alias ag='ag -f --hidden'

alias tre="tree -CshDL 1" # -L one level deep
alias tre2="tree -CshDL 2" # -L two levels deep
alias tre3="tree -CshDL 3" # -L two levels deep
alias tred="tree -CshDd" # -d directories only
alias trea="tree -CshDaL 1" # -L one level deep, including '.' files
alias trea2="tree -CshDaL 2" # -L two levels deep, including '.' files
alias trea3="tree -CshDaL 3" # -L two levels deep, including '.' files
alias treaa="tree -CshDa" # -a all including '.' files
alias tree="tree -CshD" # Color, size, date
alias treee="tree"

# find shorthand
function f() {
	find . -name "$1" 2>&1 | grep -v 'Permission denied'
}

# use coreutils `ls` if possible…
hash gls >/dev/null 2>&1 || alias gls="ls"

# always use color, even when piping (to awk,grep,etc)
if gls --color > /dev/null 2>&1; then colorflag="--color"; else colorflag="-G"; fi;
export CLICOLOR_FORCE=1

# ls options: A = include hidden (but not . or ..), F = put `/` after folders, h = byte unit suffixes
alias ls='gls -AFh ${colorflag} --group-directories-first'
alias lsd='ls -l | grep "^d"' # only directories
alias lsl="ls -lhF" # long format, human readable, classify
alias lss="ls -GhF" # no group, human readable, classify

# List all files, long format, colorized, permissions in octal
function la(){
 	ls -l  "$@" | awk '
    {
      k=0;
      for (i=0;i<=8;i++)
        k+=((substr($1,i+2,1)~/[rwx]/) *2^(8-i));
      if (k)
        printf("%0o ",k);
      printf(" %9s  %3s %2s %5s  %6s  %s %s %s\n", $3, $6, $7, $8, $5, $9,$10, $11);
    }'
}

##############################
#  Git Aliases
##############################

alias g="git"
alias ga="git add"
alias gs="git status"
alias gcm="git commit -m"
alias gpo="git push origin"
alias gpom="git push origin master"
alias gphm="git push heroku master"
alias go="git-open"

alias gl="git log --all --oneline --graph --decorate"
alias gpr="git log --pretty=format:'%Cblue%h%Creset %Cgreen%ad%Creset | %s%C(yellow)%d%Creset [%an]' --graph --date=short --decorate"

# github-email user https://github.com/paulirish/github-email

# git clone & then cd
function gc {
  reponame=${1##*/}
  reponame=${reponame%.git}
  git clone "$1" "$reponame";
  cd "$reponame";
}

##############################
#  Other Aliases
##############################

alias obash="atom ~/.bash_profile"
alias rbash="source ~/.bash_profile"

alias rspecc="rspec -c"
alias rspecf="rspec -c -fd"

alias chro="open -a 'Google Chrome'"
alias a="atom"

alias oops='$(thefuck $(fc -ln -1))'

alias w='ansiweather'

##############################
#  Network Aliases
##############################

# Networking. IP address, dig, DNS
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias dig="dig +nocmd any +multiline +noall +answer"
# wget sucks with certificates. Let's keep it simple.
alias wget="curl -O"

alias hs-o="http-server -o"

# Start an HTTP server from a directory, optionally specifying the port
function server() {
	local port="${1:-8000}"
	open "http://localhost:${port}/" &
	# statik is good because it won't expose hidden folders/files by default.
	# npm install -g statik
	statik --port "$port" .
}

# get gzipped size
function gz() {
	echo "orig size    (bytes): "
	cat "$1" | wc -c
	echo "gzipped size (bytes): "
	gzip -c "$1" | wc -c
}

# whois a domain or a URL
function whois() {
	local domain=$(echo "$1" | awk -F/ '{print $3}') # get domain from URL
	if [ -z $domain ] ; then
		domain=$1
	fi
	echo "Getting whois record for: $domain …"

	# avoid recursion
	# this is the best whois server
	# strip extra fluff
	/usr/bin/whois -h whois.internic.net $domain | sed '/NOTICE:/q'
}

function localip(){
	function _localip(){ echo "📶  "$(ipconfig getifaddr "$1"); }
	export -f _localip
	local purple="\x1B\[35m" reset="\x1B\[m"
	networksetup -listallhardwareports | \
		sed -r "s/Hardware Port: (.*)/${purple}\1${reset}/g" | \
		sed -r "s/Device: (en.*)$/_localip \1/e" | \
		sed -r "s/Ethernet Address:/📘 /g" | \
		sed -r "s/(VLAN Configurations)|==*//g"
}

##############################
#  Environments & Settings
##############################

. ~/dev/dotfiles/z.sh

export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
source /usr/local/bin/virtualenvwrapper.sh

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

export GITHUB_USERNAME='tylercrosse'
export PATH="/usr/local/bin:$PATH"
export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/9.4/bin

export NVM_DIR="/Users/tcrosse/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# Setting PATH for Python 3.5
# The orginal version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.5/bin:${PATH}"
export PATH

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
