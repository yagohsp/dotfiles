sudo pacman -S git
cd ~
git clone https://github.com/yagohsp/dotfiles.git

# yay
sudo pacman -S --needed base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

# packages
yay -S uwsm httpie-desktop cliphist wtype zsh-syntax-highlighting hyprlock hyprpaper \
    waybar rofi kitty xclip zsh neovim cmake dotnet-sdk ttf-firacode-nerd npm pnpm nodejs \
    zen-browser-bin swappy wl-clipboard fastfetch nvm \
    galculator archlinux-xdg-menu hyprpicker wl-clipboard dunst lazygit tmux wayfreeze \
    yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide imagemagick stow \
    fcitx5 fcitx5-im fcitx5-gtk fcitx5-qt fcitx5-configtool fcitx5-mozc \
    ark unrar nautilus legcord libnotify bibata-cursor-theme noto-fonts-cjk ttf-jetbrains-mono-nerd \
    vlc vlc-plugin-ffmpeg
--noconfirm

bash <(curl -s https://raw.githubusercontent.com/quantumvoid0/better-control/refs/heads/main/betterctl.sh)

sudo systemctl disable sddm

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/jeffreytse/zsh-vi-mode $ZSH_CUSTOM/plugins/zsh-vi-mode

chmod -R +x ~/.config
~/.config/install/auto-start.sh
~/.config/install/fix-cedilha.sh

sudo mkdir /etc/systemd/system/getty@tty1.service.d
sudo touch /etc/systemd/system/getty@tty1.service.d/autologin.conf
sudo bash -c 'echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty -o '\''-p -f -- \\u'\'' --noclear --autologin '$WHOAMI' %I \$TERM"' > /etc/systemd/system/getty@tty1.service.d/autologin.conf

cd ~/dotfiles
stow --override='.*' .

cd ~
rm -rf yay
