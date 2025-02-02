if [[ -z $DISPLAY && $(tty) == /dev/tty1 ]]; then
    startx
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
HYPHEN_INSENSITIVE="true"

plugins=(git )

source $ZSH/oh-my-zsh.sh

source ~/.config/zsh/themes/catppuccin.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source ~/.config/zsh/functions.zsh
source ~/.config/zsh/alias.zsh

# export nvim="/usr/bin/nvim"
# export PATH="$PATH:/opt/mssql-tools/bin"
# export PATH="$PATH:/home/yago/.dotnet/tools"

export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --bind=shift-tab:down
  --bind=tab:up
'
export zsh=~/.config/zsh/.zshrc
export hypr=~/.config/hypr/hyprland.conf

source /usr/share/nvm/init-nvm.sh

neofetch
