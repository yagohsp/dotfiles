# yay
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

# packages
sudo pacman -S cliphist wtype zsh-syntax-highlighting hyprlock waybar wofi kitty xclip zsh neovim --noconfirm

# oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

chmod +x ~/.config/initial/*
~/.config/install/auto-start.sh
~/.config/install/fix-cedilha.sh
