# yay
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

# packages
yay -S uwsm httpie-desktop cliphist wtype zsh-syntax-highlighting hyprlock hyprpaper \
    waybar wofi kitty xclip zsh neovim cmake dotnet-sdk ttf-firacode-nerd npm pnpm nodejs \
    firefox swappy wl-clipboard fastfetch nvm \
    galculator archlinux-xdg-menu hyprpicker wl-clipboard dunst lazygit tmux wayfreeze \
    yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide imagemagick stow \
    fcitx5 fcitx5-im fcitx5-gtk fcitx5-qt fcitx5-configtool fcitx5-mozc \
    --noconfirm

bash <(curl -s https://raw.githubusercontent.com/quantumvoid0/better-control/refs/heads/main/betterctl.sh)

sudo systemctl disable sddm

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

chmod -R +x ~/.config
~/.config/install/auto-start.sh
~/.config/install/fix-cedilha.sh

sudo mkdir /etc/systemd/system/getty@tty1.service.d
sudo touch /etc/systemd/system/getty@tty1.service.d/autologin.conf
sudo bash -c 'echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty -o '\''-p -f -- \\u'\'' --noclear --autologin '$WHOAMI' %I \$TERM"' > /etc/systemd/system/getty@tty1.service.d/autologin.conf
