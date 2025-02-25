if [[ -z $DISPLAY && $(tty) == /dev/tty1 ]]; then
    startx
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
HYPHEN_INSENSITIVE="true"

plugins=(git zsh-autosuggestions)

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

# fastfetch
 eval "$(zoxide init bash)"

 
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '(%b)'

# Define each part of the prompt as a variable
ZSH_fg_cyan='%{$fg[cyan]%}'
ZSH_fg_blue='%{$fg[blue]%}'
ZSH_fg_yellow='%{$fg[yellow]%}'
ZSH_reset_color='%{$reset_color%}'
ZSH_user='%n'
ZSH_path='%~'
ZSH_git_branch='${vcs_info_msg_0_}'
ZSH_prompt_char='%#'

# PROMPT="${fg_blue}${user}${reset_color}:${fg_blue}${path}${reset_color} ${fg_blue}${git_branch}${reset_color} "
PROMPT="${ZSH_fg_blue}${ZSH_user}${ZSH_reset_color} ${ZSH_fg_blue}${ZSH_path}${ZSH_reset_color} ${ZSH_fg_cyan}${ZSH_git_branch} 
❱ ${ZSH_reset_color}"
