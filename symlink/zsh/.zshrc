if [[ -z $DISPLAY && $(tty) == /dev/tty1 ]]; then
    startx
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
HYPHEN_INSENSITIVE="true"

# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git )

source $ZSH/oh-my-zsh.sh

source ~/.config/symlink/zsh/themes/catppuccin.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export nvim="/usr/bin/nvim"
export PATH="$PATH:/opt/mssql-tools/bin"
export PATH="$PATH:/home/yago/.dotnet/tools"

# Write a value in .zshrc
rz() {
  local value="$1"
  echo "$value" >> ~/.zshrc
  source ~/.config/symlink/zsh/.zshrc
}

# Define alias
_alias() {
  local key="$1"
  local value="$2"
  echo "alias $key=\"$value\"" >> ~/.zshrc
  source ~/.config/symlink/zsh/.zshrc
}

# nf() {
#     local path=$(find ~/ -type d -not -path '*/\.*' | fzf)
#     if [ -n "$path" ]; then
#         nvim "$path"
#     fi
# }
# nc() {
#     local path=$(find ~/.config -type f | fzf);
#     if [ -n "$path" ]; then
#         nvim "$path"
#     fi
# }

export zsh=~/.config/symlink/zsh/.zshrc
export hypr=~/.config/hypr/hyprland.conf

alias v="nvim"
alias rz="source ~/.config/symlink/zsh/.zshrc"
alias vz="nvim ~/.config/symlink/zsh/.zshrc"
alias audio="pavucontrol"
alias bluetooth="blueman-manager"

alias gs="git status"
