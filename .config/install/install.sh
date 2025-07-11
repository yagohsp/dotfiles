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
    # Terminal emulators, shells, and tools
    kitty zsh neovim tmux lazygit \
    zsh-syntax-highlighting zsh-autosuggestions \
    nvm nodejs npm pnpm \
    \
    # Clipboard and text utilities
    cliphist wtype wl-clipboard xclip \
    \
    # GUI/Wayland/Hyprland ecosystem
    uwsm hyprlock hyprpaper waybar hyprpicker wayfreeze \
    rofi swappy dunst \
    \
    # Fonts and appearance
    ttf-firacode-nerd ttf-jetbrains-mono-nerd noto-fonts-cjk bibata-cursor-theme \
    \
    # File managers and compression
    nautilus yazi ark unrar 7zip \
    \
    # Video and audio
    vlc vlc-plugin-ffmpeg ffmpeg \
    \
    # Development tools
    cmake dotnet-sdk \
    \
    # Utilities
    jq poppler fd ripgrep fzf zoxide imagemagick fastfetch \
    \
    # Calculator
    galculator \
    \
    # Menus
    archlinux-xdg-menu \
    \
    # Notification
    libnotify \
    \
    # Input method 
    fcitx5 fcitx5-im fcitx5-gtk fcitx5-qt fcitx5-configtool fcitx5-mozc \
    \
    # Browser
    zen-browser-bin google-chrome \
    \
    # Misc
    dotnet-sdk \
    httpie-desktop

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
