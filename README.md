# dotfiles

Personal dotfiles managed with GNU Stow.

## Structure

- `configs/`: Stow packages for home and `.config` files
- `scripts/`: helper scripts for package install, Stow apply, sync setup, and package tracking
- `packages/`: curated package lists
- `system/`: system-level files such as pacman hooks

## Packages

- `zsh`: `.zshrc`, `.zprofile`, `.p10k.zsh`
- `shell`: `.profile`, `.bashrc`
- `tmux`: `.tmux.conf`
- `asdf`: `.tool-versions`
- `x11`: `.xinitrc`, `.gtkrc-2.0`
- `nvim`: `~/.config/nvim`
- `i3`: `~/.config/i3`
- `eww`: `~/.config/eww`
- `quickshell`: `~/.config/quickshell`
- `rofi`: `~/.config/rofi`
- `picom`: `~/.config/picom`
- `dunst`: `~/.config/dunst`
- `kitty`: `~/.config/kitty`
- `lazygit`: `~/.config/lazygit`
- `gtk`: `~/.config/gtk-3.0`, `~/.config/gtk-4.0`
- `qt`: `~/.config/Kvantum`, `~/.config/qt5ct`, `~/.config/xsettingsd`
- `input`: `~/.config/fcitx`, `~/.config/fcitx5`
- `thunar`: `~/.config/Thunar`
- `desktop`: `~/.config/autostart`, `~/.config/mimeapps.list`
- `obs`: `~/.config/obs-studio`
- `vlc`: `~/.config/vlc`

## Requirements

- `stow`

## Package Tracking

- `packages/packages-dotfiles.txt`: curated package list for this dotfiles setup

This file starts with the packages relevant to the current dotfiles.
After that, it is updated from package transactions by comparing the explicit package set before and after installs/removals.

Initialize tracking state:

```bash
sudo ~/dotfiles/scripts/sync-dotfiles-packages --init
```

Refresh tracking manually:

```bash
sudo ~/dotfiles/scripts/sync-dotfiles-packages
```

Enable automatic updates after package installs, upgrades, and removals:

```bash
sudo install -Dm644 system/pacman/hooks/95-dotfiles-packages.hook /etc/pacman.d/hooks/95-dotfiles-packages.hook
```

The hook runs `scripts/sync-dotfiles-packages` after each pacman transaction.

## Usage

Install listed packages:

```bash
./scripts/install-packages.sh
```

Apply dotfiles with Stow:

```bash
./scripts/apply-stow.sh
```

Enable package sync after pacman/paru transactions:

```bash
./scripts/enable-package-sync.sh
```

Run everything:

```bash
./scripts/run-all.sh
```

All of these scripts are safe to rerun.

Apply selected packages manually:

```bash
stow -d configs -t "$HOME" zsh shell tmux
stow -d configs -t "$HOME" nvim i3 rofi picom dunst
```

Remove a package manually:

```bash
stow -d configs -D -t "$HOME" zsh
```

Preview changes without writing symlinks:

```bash
stow -d configs -nv -t "$HOME" zsh nvim
```

## Workflow

1. Run `./scripts/install-packages.sh`.
2. Run `./scripts/enable-package-sync.sh`.
3. Run `./scripts/apply-stow.sh`.
4. Or just run `./scripts/run-all.sh`.

## Notes

- `obs` includes useful OBS settings and scene data, but skips transient data such as logs and updates.
- Some configs still contain machine-specific paths and may need cleanup before reuse on another machine.
- Package tracking uses explicit package diffs after transactions, so installs from `pacman -S` and `paru -S` are added and removed packages are deleted from `packages/packages-dotfiles.txt`.
- `scripts/install-packages.sh` is idempotent because it uses `paru -S --needed`.
- `scripts/apply-stow.sh` is idempotent because it restows managed links and only backs up unmanaged existing targets.
- `scripts/enable-package-sync.sh` is idempotent because it reinstalls the hook in place and only initializes tracking state when it does not exist.
