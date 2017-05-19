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

# brew install the_silver_searcher
alias ag='ag -f --hidden'
alias agc='ag --color-line-number "2;39" --color-match "30;42" --color-path "1;4;37"'

alias tre="tree -CshDL 1" # -L one level deep
alias tre2="tree -CshDLI 2 'node_modules'" # -L two levels deep excluding node_modules
alias tre3="tree -CshDLI 3 'node_modules'" # -L two levels deep
alias tred="tree -CshDd" # -d directories only
alias trea="tree -CshDaL 1" # -L one level deep, including '.' files
alias trea2="tree -CshDaLI 2" # -L two levels deep, including '.' files
alias trea3="tree -CshDaL 3" # -L two levels deep, including '.' files
alias treaa="tree -CshDa" # -a all including '.' files
alias tree="tree -CshD" # Color, size, date
alias treee="tree"

# fzf command line fuzzy finder https://github.com/junegunn/fzf
export FZF_DEFAULT_OPTS='--color=16 --height 40% --reverse'

# fzf shorthand
function f() {
  ag --hidden --ignore .git -g "" | fzf $1
}

# `cat` with beautiful colors. requires: sudo easy_install -U Pygments
# alias c='pygmentize -O style=solarizedlight -f console256 -g'
# hicat https://github.com/rstacruz/hicat
alias c='hicat'

# Pipe Highlight to less
export LESSOPEN="| $(which highlight) %s --out-format xterm256 --line-numbers --quiet --force --style solarized-light"
export LESS=" -R"
alias less='less -m -N -g -i --line-numbers --underline-special'

# feed output of fzf to less, creates mini file browser
alias cf='ag --hidden --ignore .git -g "" | fzf --bind "enter:execute(less {})"'

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

alias gba="git branch -a"
alias gch="git checkout"
alias gcb="git checkout -b"

alias gd="git diff"
alias gdc="git diff --cached"

alias ga="git add"
alias gs="git status"
alias gco="git commit"
alias gcoa="git commit --amend"
alias gcm="git commit -m"
alias gpom="git push origin master"
alias go="git-open"

alias gbdm="git branch --merged | egrep -v '(^\*|master|dev)' | xargs git branch -d"

alias gl="git log --all --oneline --graph --decorate"
alias gla='git log --all --decorate --graph --pretty=format:"%C(yellow)%h%Creset %C(auto)%d%Creset %Cblue%ar%Creset %Cred%an%Creset %n%w(72,1,2)%s"'
alias gpr="git log --pretty=format:'%Cblue%h%Creset %Cgreen%ad%Creset | %s%C(yellow)%d%Creset [%an]' --graph --date=short --decorate"

# github-email <user> https://github.com/paulirish/github-email
# diffshot https://github.com/RobertAKARobin/diffshot

# git clone & then cd
function gc {
  reponame=${1##*/}
  reponame=${reponame%.git}
  git clone "$1" "$reponame";
  cd "$reponame";
}

function gitsearch(){
  git rev-list --all | xargs git grep -i $1
}

##############################
#  Other Aliases
##############################

alias obash="cd ~/dev/dotfiles; atom ."
alias cbash="c ~/dev/dotfiles/shell/aliases.sh"
alias rbash="source ~/.bash_profile"

alias rspecc="rspec -c"
alias rspecf="rspec -c -fd"

alias rakestart="bundle; rake db:drop db:create db:migrate db:seed"

alias chro="open -a 'Google Chrome'"
alias a="atom"
alias typora="open -a 'Typora'"

alias oops='$(thefuck $(fc -ln -1))'

alias v='vim'

function w() {
  curl wttr.in/$1
}

alias colortest="~/dev/dotfiles/colortest"

function colors() {
  e="\033["
  for f in 0 7 `seq 6`; do
    no="" bo=""
    for b in n 7 0 `seq 6`; do
      co="3$f"; p="  "
      [ $b = n ] || { co="$co;4$b";p=""; }
      no="${no}${e}${co}m   ${p}${co} ${e}0m"
      bo="${bo}${e}1;${co}m ${p}1;${co} ${e}0m"
    done
    echo -e "$no\n$bo"
  done
}

##############################
#  Network Aliases
##############################

alias jn="jupyter notebook"
# Networking. IP address, dig, DNS
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias dig="dig +nocmd any +multiline +noall +answer"
# wget sucks with certificates. Let's keep it simple.
alias wget="curl -O"

# "http" user-friendly curl alternative https://github.com/jakubroztocil/httpie

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
