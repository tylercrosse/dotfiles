#!/usr/bin/env zsh
#
# Shell functions. Aliases live in aliases.zsh.

##############################
#  Navigation
##############################

# cd into whatever is the forefront Finder window
cdf() { # short for cdfinder
  cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')"
}

# Create a new directory and enter it
md() {
  mkdir -p "$@" && cd "$@"
}

# List all files, long format, colorized, permissions in octal
la() {
  command ls -l "$@" | awk '
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
#  Search
##############################

# fuzzy-find a file by name. Was ag -g "" | fzf; ripgrep --files is the same idea.
f() {
  rg --files --hidden --glob '!.git/*' | fzf --preview 'bat --color=always --style=numbers {}'
}

# mini file browser: fuzzy-find, then open the selection in a pager
cf() {
  rg --files --hidden --glob '!.git/*' \
    | fzf --preview 'bat --color=always --style=numbers {}' \
          --bind 'enter:execute(bat --paging=always {})'
}

##############################
#  Git
##############################

# git clone & then cd
gc() {
  local reponame=${1##*/}
  reponame=${reponame%.git}
  git clone "$1" "$reponame"
  cd "$reponame"
}

# search every commit in history for a string
gitsearch() {
  git rev-list --all | xargs git grep -i "$1"
}

##############################
#  Docker
##############################

dex() {
  docker exec -it "$1" /bin/bash
}

##############################
#  Node / JS
##############################

fix-yarn() {
  echo "Performing: git checkout origin/master -- yarn.lock"
  git checkout origin/master -- yarn.lock
  echo "Performing: yarn install"
  yarn install
  echo "Performing: git add yarn.lock"
  git add yarn.lock
  echo "You should: git rebase --continue"
}

dep3() {
  depcruise --max-depth 3 --exclude "^(node_modules)|.test.js$" --output-type dot "$1$2" | dot -T pdf >"$2.pdf"
}

##############################
#  Misc
##############################

wttr() {
  local location=$1
  if [ -z "$location" ]; then
    location="seattle"
  fi
  curl "wttr.in/$location"
}

# thefuck costs ~70ms to initialise and is only needed once you actually type
# `fuck`, so build the real alias on first use instead of at every shell start.
fuck() {
  unfunction fuck
  eval "$(thefuck --alias)"
  fuck "$@"
}

colors() {
  local e="\033["
  for f in 0 7 $(seq 6); do
    local no=""
    local bo=""
    for b in n 7 0 $(seq 6); do
      local co="3$f"
      local p="  "
      [ $b = n ] || {
        co="$co;4$b"
        p=""
      }
      no="${no}${e}${co}m   ${p}${co} ${e}0m"
      bo="${bo}${e}1;${co}m ${p}1;${co} ${e}0m"
    done
    echo -e "$no\n$bo"
  done
}

##############################
#  Network
##############################

# Start an HTTP server from a directory, optionally specifying the port.
# Was `statik`, which is no longer installed; python3 ships with macOS.
server() {
  local port="${1:-8000}"
  open "http://localhost:${port}/" &
  python3 -m http.server "$port"
}

# get gzipped size
gz() {
  echo "orig size    (bytes): "
  wc -c < "$1"
  echo "gzipped size (bytes): "
  gzip -c "$1" | wc -c
}

# whois a domain or a URL
whois() {
  local domain=$(echo "$1" | awk -F/ '{print $3}') # get domain from URL
  if [ -z "$domain" ]; then
    domain=$1
  fi
  echo "Getting whois record for: $domain …"

  # avoid recursion; this is the best whois server; strip extra fluff
  /usr/bin/whois -h whois.internic.net "$domain" | sed '/NOTICE:/q'
}

localip() {
  _localip() { echo "📶  "$(ipconfig getifaddr "$1"); }
  export -f _localip 2>/dev/null
  local purple="\x1B\[35m" reset="\x1B\[m"
  networksetup -listallhardwareports |
    sed -r "s/Hardware Port: (.*)/${purple}\1${reset}/g" |
    sed -r "s/Device: (en.*)$/_localip \1/e" |
    sed -r "s/Ethernet Address:/📘 /g" |
    sed -r "s/(VLAN Configurations)|==*//g"
}
