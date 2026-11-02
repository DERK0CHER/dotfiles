#!/usr/bin/env bash
# Symlink nvim, tmux and kitty configs into ~/.config.
# Existing configs are moved to ~/.config/<name>.bak.<timestamp>.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
STAMP="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$CONFIG"

link() {
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "ok      $dst"; return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mv "$dst" "$dst.bak.$STAMP"; echo "backup  $dst -> $dst.bak.$STAMP"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"; echo "link    $dst -> $src"
}

# nvim: whole directory (lazy.nvim writes lazy-lock.json back into the repo)
link "$DOTFILES/nvim" "$CONFIG/nvim"

# tmux: link the file so TPM's plugins/ dir stays out of the repo
mkdir -p "$CONFIG/tmux"
link "$DOTFILES/tmux/tmux.conf" "$CONFIG/tmux/tmux.conf"
if [ ! -d "$CONFIG/tmux/plugins/tpm" ] && command -v git >/dev/null; then
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$CONFIG/tmux/plugins/tpm"
  "$CONFIG/tmux/plugins/tpm/bin/install_plugins" || true
fi

# kitty: link files so current-theme.conf stays machine-local
mkdir -p "$CONFIG/kitty"
link "$DOTFILES/kitty/kitty.conf" "$CONFIG/kitty/kitty.conf"
link "$DOTFILES/kitty/themes"     "$CONFIG/kitty/themes"
if [ ! -e "$CONFIG/kitty/current-theme.conf" ]; then
  ln -s themes/default.conf "$CONFIG/kitty/current-theme.conf"
  echo "link    $CONFIG/kitty/current-theme.conf -> themes/default.conf"
fi

echo "done."
