if [[ -z $DISPLAY && $(tty) == /dev/tty1 ]]; then
    startx
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
HYPHEN_INSENSITIVE="true"

plugins=(git )
bindkey '^P' vf

source $ZSH/oh-my-zsh.sh

source ~/.config/symlink/zsh/themes/catppuccin.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export nvim="/usr/bin/nvim"
export PATH="$PATH:/opt/mssql-tools/bin"
export PATH="$PATH:/home/yago/.dotnet/tools"

export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --bind=shift-tab:down
  --bind=tab:up
'

# git status
zle -N gs
gs() {
    git status
        wtype -k "return"
}
bindkey '^G' gs

# list folders
zle -N vc
vc() {
    vc_file=$(find ~/.config -type f | fzf --preview 'bat --style=numbers --color=always {} || cat {}') 
    if [ ! -z "$vc_file" ]; then
        vc_path=$(dirname $vc_file)
        cd $vc_path
        wtype -k "return"
        # nvim $vc_file
    fi
}
bindkey '^O' vc

#list config files
zle -N vf
vf() {
    vf_folder=$(find ~ -type d -name '.*' -prune -o -type d -print | fzf)
    if [ ! -z "$vf_folder" ]; then
        cd $vf_folder
        wtype -k "return"
        # nvim $vf_folder
    fi
}
bindkey '^P' vf

#list config files
zle -N vv
vv() {
    nvim .
}
bindkey '^V' vv

export zsh=~/.config/symlink/zsh/.zshrc
export hypr=~/.config/hypr/hyprland.conf

alias v="nvim"
alias rz="source ~/.config/symlink/zsh/.zshrc"
alias vz="nvim ~/.config/symlink/zsh/.zshrc"
alias audio="pavucontrol"
alias bluetooth="blueman-manager"
