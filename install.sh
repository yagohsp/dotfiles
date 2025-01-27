# yay
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

# packages
yay -S cliphist wtype zsh-syntax-highlighting hyprlock waybar wofi kitty xclip zsh neovim cmake dotnet-sdk ttf-firacode-nerd --noconfirm

# oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

chmod +x ~/.config/install/*
~/.config/install/auto-start.sh
~/.config/install/fix-cedilha.sh
