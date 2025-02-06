if [[ -z $DISPLAY && $(tty) == /dev/tty1 ]]; then
    startx
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
HYPHEN_INSENSITIVE="true"

plugins=(git )

source $ZSH/oh-my-zsh.sh
source /usr/share/nvm/init-nvm.sh

source ~/.config/zsh/themes/catppuccin.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source ~/.config/zsh/functions.zsh
source ~/.config/zsh/alias.zsh

export PATH="$PATH:/opt/mssql-tools/bin"
export DOTNET_ROOT=/home/yago/.dotnet
export PATH="$PATH:$DOTNET_ROOT"
export PATH="$PATH:$DOTNET_ROOT/tools"
export WAYLAND_DISPLAY=wayland-1

export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --bind=shift-tab:down
  --bind=tab:up
'
export zsh=~/.config/zsh/.zshrc
export hypr=~/.config/hypr/hyprland.conf
export EDITOR=nvim
export SHELL=/bin/zsh

fastfetch
