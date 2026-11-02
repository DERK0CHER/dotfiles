# dotfiles

Configs for **neovim**, **tmux** and **kitty**.

## Install

```sh
git clone https://github.com/DERK0CHER/dotfiles ~/dotfiles
~/dotfiles/install.sh
```

The script symlinks into `~/.config` and moves any existing config aside as `*.bak.<timestamp>`. It's safe to re-run.

| Repo            | Linked to                         |
|-----------------|-----------------------------------|
| `nvim/`         | `~/.config/nvim`                  |
| `tmux/tmux.conf`| `~/.config/tmux/tmux.conf`        |
| `kitty/kitty.conf`, `kitty/themes/` | `~/.config/kitty/` |

## Requirements

- **neovim** ≥ 0.10. Plugins install on first launch (lazy.nvim, pinned by `nvim/lazy-lock.json`).
- **tmux** ≥ 3.2. The install script clones [TPM](https://github.com/tmux-plugins/tpm); inside tmux, press `prefix + I` to (re)install plugins (resurrect, continuum).
- **kitty**, with the fonts *Hasklig* and *Symbols Nerd Font Mono*.
- Optional: `fish` (tmux uses it as the shell when present), plus `pbcopy`, `wl-copy` or `xclip` for the clipboard.

## Kitty themes

`~/.config/kitty/current-theme.conf` is a per-machine symlink into `themes/` that isn't tracked:

```sh
ln -sfn themes/calm.conf ~/.config/kitty/current-theme.conf
```
