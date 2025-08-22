# 1. Install git and clone dotfiles
sudo pacman -S git --noconfirm
cd ~
git clone https://github.com/yagohsp/dotfiles.git

# 2. Install yay
sudo pacman -S --needed base-devel --noconfirm
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm

# 3. Install packages
yay -S --noconfirm \
    kitty zsh neovim tmux lazygit \
    jq poppler fd ripgrep fzf zoxide imagemagick fastfetch \
    galculator mousepad \
    nvm nodejs npm pnpm cmake dotnet-sdk \
    uwsm hyprlock hyprpaper waybar hyprpicker wayfreeze \
    rofi swappy dunst archlinux-xdg-menu libnotify \
    ttf-firacode-nerd ttf-jetbrains-mono-nerd noto-fonts-cjk bibata-cursor-theme \
    nautilus yazi ark unrar 7zip \
    cliphist wtype wl-clipboard xclip \
    fcitx5 fcitx5-im fcitx5-gtk fcitx5-qt fcitx5-configtool fcitx5-mozc \
    zen-browser-bin google-chrome httpie-desktop ffmpeg \
    flatpak vial rustup qt6ct unzip bat

flatpak install -y vlc

# 4. Install tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# 5. Install Better control
bash <(curl -s https://raw.githubusercontent.com/quantumvoid0/better-control/refs/heads/main/betterctl.sh)

# 6. Disable SDDM to skip
sudo systemctl disable sddm

# 7. Install Oh My Zsh and plugins
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/jeffreytse/zsh-vi-mode $ZSH_CUSTOM/plugins/zsh-vi-mode

# 8. Custom install scripts
chmod -R +x ~/.config
~/.config/install/auto-start.sh
~/.config/install/fix-cedilha.sh

# 9. Setup systemd autologin
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo bash -c 'echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty -o '\''-p -f -- \\u'\'' --noclear --autologin '$WHOAMI' %I \$TERM"' > /etc/systemd/system/getty@tty1.service.d/autologin.conf

# 10. Link dotfiles using stow
cd ~/dotfiles
stow --override='.*' .

# 11. Cleanup yay directory
cd ~
rm -rf yay
