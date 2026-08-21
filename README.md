# dotfiles

macOS + zsh. Rebuilt from the live config in Aug 2026; the commits before that
are the 2017 bash-era layout, kept for history.

```sh
git clone git@github.com:tylercrosse/dotfiles.git ~/dev/dotfiles
# No SSH key on this machine yet? The repo is public, so clone over HTTPS
# instead, then `git remote set-url origin git@...` once keys are set up:
#   git clone https://github.com/tylercrosse/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles
brew bundle            # packages, casks, npm globals -- run BEFORE the
                       # first new shell, or the aliases point at
                       # binaries that are not installed yet
./install.sh --dry     # see what it would replace
./install.sh           # symlink everything, backing up what's there
```

Clone somewhere other than `~/dev/dotfiles`? Set `DOTFILES` in `~/.zshrc.local`
to match; `rc.zsh` defaults to `~/dev/dotfiles`.

On a machine that already has a shell config, `install.sh` moves the existing
files into a timestamped backup directory rather than deleting them. Read the
old `.zshrc` out of that backup afterwards: anything machine-specific in it
belongs in `~/.zshrc.local`.

## Layout

| Path | Linked to | What |
| --- | --- | --- |
| `zsh/rc.zsh` | `~/.zshrc` | entrypoint — sources the rest |
| `zsh/zshenv.zsh` | `~/.zshenv` | every shell, incl. non-interactive |
| `zsh/zprofile.zsh` | `~/.zprofile` | login shells — Homebrew, OrbStack |
| `zsh/path.zsh` | — | **every** PATH entry and version manager |
| `zsh/aliases.zsh` | — | aliases |
| `zsh/functions.zsh` | — | functions |
| `zsh/completions.zsh` | — | fpath + a single `compinit` |
| `zsh/prompt.zsh` | — | prompt (vcs_info), VS Code integration |
| `git/gitconfig` | `~/.gitconfig` | delta, aliases, nbdime |
| `vim/vimrc` | `~/.vimrc` | pathogen + solarized |
| `config/*` | `~/.config/*/…` | bat, git, htop, neofetch, thefuck |
| `bin/` | on `$PATH` | `colortest`, `md_tidy.py` |

`~/.zshrc` is a **symlink into this repo**. Installers still append to it — but
because the file is tracked, `git status` shows you what they added. Move PATH
lines into `path.zsh`, completions into `completions.zsh`, then revert `rc.zsh`.
That review step is the entire point of the symlink.

Machine-specific settings (work credentials, one-off PATH entries) go in
`~/.zshrc.local`, which is never tracked.

## Not tracked here

- `~/.ssh/config` — 66 hosts. Copy it across by hand.
- `~/.claude` — lives in its own repo, `tylercrosse/claude-config`.
- VS Code settings and extensions.
- Anything holding a token: `.aws`, `.azure`, `.config/gh`.

## Notes

- `compinit -C` skips the fpath security audit. That's most of the startup
  speedup; drop the `-C` in `completions.zsh` if you'd rather have the check.
- `pyenv` and `thefuck` are lazy-loaded — the shims go on `$PATH` eagerly, but
  the shell functions are built on first use.
- The prompt uses zsh built-ins, no framework. Warp sets `HonorPS1=false` and
  draws its own chips, so `prompt.zsh` returns early there rather than
  computing a prompt nothing renders.
- The branch name is read from `.git/HEAD` rather than shelling out: 0.05ms per
  prompt in any repo, against ~10ms for `git rev-parse` and 77-162ms for
  `vcs_info`.
- The `✚` dirty marker is one `git status --porcelain --ignore-submodules=all`.
  That flag is the whole trick: without it git recurses into every submodule,
  and grpc (16 submodules) costs 402ms instead of 32ms. Measured whole-prompt
  cost is 11ms in a small repo, 34ms in grpc.
- No async, no daemon, no prompt framework — those were measured and rejected.
  `vcs_info` costs 77-162ms before touching the repo; starship's default config
  costs 26ms small / 531ms in grpc, because it also shells out for python,
  swift, and cmake versions. `gitstatusd` (what powerlevel10k runs) is the only
  genuinely faster option, at the price of a background daemon per shell.
- `core.fsmonitor` was tested and did not help: 58ms on vs 44ms off in grpc.
- Set `PROMPT_NO_GIT_DIRTY=1` in `~/.zshrc.local` for a prompt that never
  shells out at all (0.05ms, branch only).
- Three formulae come from third-party taps (`borders`, `peon-ping`,
  `runpodctl`). Homebrew warns it "cannot check whether X is outdated because
  its tap is not trusted" until you run `brew trust --formula <name>` once per
  machine. The install still works; it is only the outdated-check that is
  skipped.
- `brew bundle check` reports self-updating casks (1password-cli, ngrok, warp,
  temurin) as unsatisfied whenever a newer version exists upstream. That is an
  update notice, not a missing package.

## Available but not linked

- `readline/inputrc` — case-insensitive completion and history-search on the
  arrow keys for readline programs (`psql`, the Python REPL). It does not affect
  zsh, which uses ZLE. Opt in with `ln -s ~/dev/dotfiles/readline/inputrc ~/.inputrc`.
