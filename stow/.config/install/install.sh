# Install git and clone dotfiles
sudo pacman -S git --noconfirm
cd ~
git clone https://github.com/yagohsp/dotfiles.git

# Install yay
sudo pacman -S --needed base-devel --noconfirm
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm

# Install packages
yay -S --noconfirm \
    7zip alsa-utils amd-ucode archlinux-xdg-menu aspnet-runtime-8.0 aws-cli aylurs-gtk-shell-git baobab base base-devel bc better-control-git \
    bibata-cursor-theme bluez-tools btop btrfs-progs catppuccin-cursors-mocha catppuccin-gtk-theme-mocha cliphist cmake dart-sass \
    dbeaver discord dkms docker docker-compose dotnet-sdk-bin dracula-gtk-theme dracula-icons-theme \
    elephant-bin elephant-desktopapplications-bin fastfetch fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-mozc fcitx5-qt fd firefox flatpak foot \
    fzf galculator git github-cli glad glew glfw glib2-devel glm google-chrome grim grub gst-libav htop hyprland hyprlock hyprpaper \
    hyprpicker imagemagick inotify-tools inter-font iptables-nft iwd jq kitty kvantum kvantum-qt5 lazygit lib32-nvidia-utils libastal-apps-git \
    libastal-battery-git libastal-bluetooth-git libastal-hyprland-git libastal-mpris-git libastal-network-git libastal-niri-git \
    libastal-notifd-git libastal-powerprofiles-git libastal-tray-git libdvdcss libnotify libreoffice-still libva-nvidia-driver \
    linux linux-firmware linux-headers man-db matugen-bin mono mono-msbuild mousepad mpv nano nautilus neovim net-tools \
    ngrok nodejs noto-fonts-cjk npm ntfs-3g nvidia-dkms nvm nwg-look obs-cli obs-studio obs-websocket-compat ollama openh264 openssh os-prober \
    pavucontrol pinta piper pngquant polkit-kde-agent postman-bin pulseaudio-alsa python-aiohttp-oauthlib python-openpyxl python-pip \
    python-pipx qbittorrent qt5-multimedia qt5-svg qt5-wayland qt5ct qt6-wayland qt6ct-kde ripgrep rsync sddm shotcut slurp spotify \
    steam stow swappy syncthing tesseract tesseract-data-jpn tesseract-data-jpn_vert tmux tree ttf-fira-code ttf-firacode-nerd \
    ttf-jetbrains-mono-nerd ttf-liberation ttf-material-symbols-variable-git ttf-roboto unityhub unrar unzip uwsm \
    ventoy-bin vesktop-bin vim vlc-plugin-ffmpeg walker-bin wayfreeze-git webapp-manager \
    wev wget wl-clipboard wpa_supplicant xclip xdg-desktop-portal-hyprland xdg-utils xorg-server xorg-xinit yarn yay \
    zen-browser-bin zoxide zsh zsh-syntax-highlighting
pipx install neovim-remote
flatpak install -y vlc
git clone https://github.com/mwh/dragon.git && cd dragon && make install && cd .. && rm -rf dragon


# Install tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Disable SDDM to skip
sudo systemctl disable sddm

# Install Oh My Zsh and plugins
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/jeffreytse/zsh-vi-mode $ZSH_CUSTOM/plugins/zsh-vi-mode

# Setup systemd autologin
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo bash -c 'echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty -o '\''-p -f -- \\u'\'' --noclear --autologin '$WHOAMI' %I \$TERM"' > /etc/systemd/system/getty@tty1.service.d/autologin.conf

# Link dotfiles using stow
cd ~/dotfiles
stow --override='.*' .

# Cleanup yay directory
cd ~
rm -rf yay
