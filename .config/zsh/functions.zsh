# find config file
ff() {
    vc_file=$(find ~/dotfiles \( -name node_modules -o -name .git \) -prune -o -type f -print | fzf --preview 'bat --style=numbers --color=always {} || cat {}') 
    if [ ! -z "$vc_file" ]; then
        vc_path=$(dirname $vc_file)
        cd $vc_path
        nvim $vc_file
        wtype -k "return"
    fi
}

# find config folders
ffc() {
     vf_folder=$(find ~/dotfiles -name .git -prune -o -type d -print | fzf)
     if [ ! -z "$vf_folder" ]; then
         cd $vf_folder
         wtype -k "return"
     fi
 }

# find folders
f() {
    vf_folder=$(find ~ \
        -type d \( -name '.*' -o -name 'node_modules' \) -prune -o -print | fzf)
    if [ ! -z "$vf_folder" ]; then
        cd "$vf_folder"
        wtype -k "return"
    fi
}


yi() {
    for package in "$@"; 
    do
        yay -S "$package" --noconfirm
    done
}

yr() {
    for package in "$@"; 
    do
        yay -Rns "$package" --noconfirm
    done
}

ys() {
    yay -Ss "$1"
}

set_theme(){
  selected_theme=$(ls "$HOME/dotfiles/theme" | grep -v "current" | fzf)
  if [ ! -z "$selected_theme" ]; then
    rm "$HOME/dotfiles/theme/current"
    ln -s "$HOME/dotfiles/theme/$selected_theme" "$HOME/dotfiles/theme/current"
  fi
}

set_workspace(){
  selected_workspace=$(ls "$HOME/dotfiles/workspace" | grep -v "current" | fzf)
  if [ ! -z "$selected_workspace" ]; then
    rm "$HOME/dotfiles/workspace/current"
    ln -s "$HOME/dotfiles/workspace/$selected_workspace" "$HOME/dotfiles/workspace/current"
  fi
}
