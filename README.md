# dotfiles

Personal dotfiles managed with GNU Stow.

## Structure

- `stow/`: single Stow package that mirrors `$HOME` (e.g. `stow/.zshrc`, `stow/.config/nvim`)
- `scripts/`: helper scripts for package install, Stow apply, sync setup, and package tracking
- `packages/`: curated package lists
- `system/`: system-level files such as pacman hooks
- `backups/`: local backups not managed by Stow

## Layout

The `stow/` tree is installed into `$HOME` as-is:

- `stow/.zshrc` → `~/.zshrc`
- `stow/.tmux.conf` → `~/.tmux.conf`
- `stow/.cursor/skills` → `~/.cursor/skills`
- `stow/.config/nvim` → `~/.config/nvim`
- `stow/.config/i3` → `~/.config/i3`
- `stow/.config/paru` → `~/.config/paru`
- …and the rest of `.config/` the same way

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

Install the [Rosé Pine GTK theme](https://github.com/Fausto-Korpsvart/Rose-Pine-GTK-Theme) (also run as part of `run-all.sh`):

```bash
./scripts/install-rose-pine-gtk-theme.sh
```

Installs the default-accent light variant (`Rosepine-Light`, matching this setup's `gtk-application-prefer-dark-theme=0`) and sets it as the active GTK theme in `gtk-3.0`/`gtk-4.0` `settings.ini` and `xsettingsd.conf`, reloading `xsettingsd` if it's running.

Apply manually:

```bash
stow -d "$HOME/dotfiles" -t "$HOME" stow
```

Remove:

```bash
stow -D -d "$HOME/dotfiles" -t "$HOME" stow
```

Preview without writing symlinks:

```bash
stow -nv -d "$HOME/dotfiles" -t "$HOME" stow
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
- `scripts/install-rose-pine-gtk-theme.sh` caches the upstream theme source in `~/.cache/dotfiles/Rose-Pine-GTK-Theme` and pulls instead of re-cloning on rerun.
