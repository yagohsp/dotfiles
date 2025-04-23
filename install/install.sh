# yay
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

# packages
yay -S uwsm httpie-desktop fzf blueman cliphist wtype zsh-syntax-highlighting hyprlock hyprpaper \
    waybar wofi kitty xclip zsh neovim cmake dotnet-sdk ttf-firacode-nerd npm pnpm nodejs \
    firefox swappy wl-clipboard imv viu  network-manager network-manager-applet fastfetch nvm \
    galculator archlinux-xdg-menu hyprpicker wl-clipboard bluetoothctl dunst lazygit tmux wayfreeze \
    --noconfirm
# ttf-unifont

sudo systemctl disable systemd-resolved
sudo systemctl disable systemd-networkd
sudo systemctl enable network-manager
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager
sudo systemctl disable sddm

# oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

chmod -R +x ~/.config
~/.config/install/auto-start.sh
~/.config/install/fix-cedilha.sh

sudo mkdir /etc/systemd/system/getty@tty1.service.d
sudo touch /etc/systemd/system/getty@tty1.service.d/autologin.conf
sudo bash -c 'echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty -o '\''-p -f -- \\u'\'' --noclear --autologin '$WHOAMI' %I \$TERM"' > /etc/systemd/system/getty@tty1.service.d/autologin.conf
