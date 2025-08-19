if [[ -z $DISPLAY && $(tty) == /dev/tty1 ]]; then
    startx
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
HYPHEN_INSENSITIVE="true"

plugins=(git zsh-autosuggestions zsh-vi-mode)

source $ZSH/oh-my-zsh.sh
source /usr/share/nvm/init-nvm.sh

source ~/.config/zsh/theme.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source ~/.config/zsh/functions.zsh
source ~/.config/zsh/alias.zsh

export PATH="$PATH:/opt/mssql-tools/bin"
export PATH=$PATH:/usr/share/dotnet:~/.dotnet/tools

export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --bind=shift-tab:down
  --bind=tab:up
'
export zsh=~/.zshrc
export hypr=~/.config/hypr/hyprland.conf
export EDITOR=nvim
export SHELL=/bin/zsh
export XDG_CONFIG_HOME=~/.config
export QML_IMPORT_PATH=/usr/lib/qt/qml

export MANPAGER="nvim +Man!"

# fastfetch
 eval "$(zoxide init bash)"
 
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '(%b)'

zc_background="{146}"
zc_lightText='{255}'   
zc_text='{54}'          
zc_darkText='{17}'      
zc_lightPurple='{133}' 
zc_purple='{90}'      
zc_pink='{162}'        

ZSH_fg_cyan='%{$fg[cyan]%}'
ZSH_fg_blue='%{$fg[blue]%}'
ZSH_fg_yellow='%{$fg[yellow]%}'
ZSH_reset_color='%{$reset_color%}'
ZSH_user='%n'
ZSH_path='%~'
ZSH_git_branch='${vcs_info_msg_0_}'
ZSH_prompt_char='%#'

PROMPT="${ZSH_fg_blue}${ZSH_user}${ZSH_reset_color} ${ZSH_fg_blue}${ZSH_path}${ZSH_reset_color} ${ZSH_fg_cyan}${ZSH_git_branch} 
❱ ${ZSH_reset_color}"

# pnpm
export PNPM_HOME="/$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

source $HOME/.cargo/env

# auto start tmux
if command -v tmux &> /dev/null; then
  if [ -z "$TMUX" ]; then
    tmux attach -t main 2>/dev/null || tmux new -s main
  fi
fi
