#!/usr/bin/env bash
#
# Symlink the tracked dotfiles into place.
#
#   ./install.sh          symlink everything, backing up whatever is there now
#   ./install.sh --dry    print what it would do and change nothing
#
# Safe to re-run. Existing symlinks that already point at the right file are
# left alone; real files are moved into a timestamped backup directory first.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
DRY=false
[[ "${1:-}" == "--dry" ]] && DRY=true

link() {
  local src="$DOTFILES/$1" dest="$2"

  if [[ ! -e "$src" ]]; then
    echo "  skip    $2  (missing in repo: $1)"
    return
  fi

  # Already correct?
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    echo "  ok      $2"
    return
  fi

  if $DRY; then
    [[ -e "$dest" || -L "$dest" ]] && echo "  BACKUP  $2" || true
    echo "  LINK    $2  ->  $1"
    return
  fi

  # Move anything real out of the way before replacing it
  if [[ -e "$dest" || -L "$dest" ]]; then
    mkdir -p "$BACKUP/$(dirname "${dest#$HOME/}")"
    mv "$dest" "$BACKUP/${dest#$HOME/}"
    echo "  backup  $2  ->  $BACKUP/${dest#$HOME/}"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "  link    $2  ->  $1"
}

echo "dotfiles: $DOTFILES"
$DRY && echo "(dry run — nothing will change)"
echo

echo "shell:"
link zsh/rc.zsh        "$HOME/.zshrc"
link zsh/zshenv.zsh    "$HOME/.zshenv"
link zsh/zprofile.zsh  "$HOME/.zprofile"

echo "git:"
link git/gitconfig        "$HOME/.gitconfig"
link git/gitignore_global "$HOME/.gitignore_global"

echo "editors:"
link vim/vimrc   "$HOME/.vimrc"

# Linked file-by-file, not directory-by-directory: these apps keep state next
# to their config (zed stores its prompt library and embeddings in ~/.config/zed,
# htop rewrites htoprc on exit), and a directory symlink would displace it.
echo "xdg config:"
link config/bat/config          "$HOME/.config/bat/config"
link config/git/attributes      "$HOME/.config/git/attributes"
link config/git/ignore          "$HOME/.config/git/ignore"
link config/htop/htoprc         "$HOME/.config/htop/htoprc"
link config/neofetch/config.conf "$HOME/.config/neofetch/config.conf"
link config/thefuck/settings.py "$HOME/.config/thefuck/settings.py"

echo
if ! $DRY; then
  [[ -d "$BACKUP" ]] && echo "replaced files backed up to: $BACKUP"
  cat <<'MSG'

Not done automatically — run these yourself as needed:

  brew bundle --file=Brewfile          install packages and casks

Machine-specific settings go in ~/.zshrc.local (never tracked).
MSG
fi
