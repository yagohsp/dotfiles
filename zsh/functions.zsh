# git status
zle -N gs
bindkey '^G' gs
gs() {
    git status
        wtype -k "return"
}

# find config file
zle -N ff
ff() {
    vc_file=$(find ~/.config \( -name node_modules -o -name .git \) -prune -o -type f -print | fzf --preview 'bat --style=numbers --color=always {} || cat {}') 
    if [ ! -z "$vc_file" ]; then
        vc_path=$(dirname $vc_file)
        cd $vc_path
        nvim $vc_file
        wtype -k "return"
    fi
}

# find config folders
zle -N ffc
ffc() {
     vf_folder=$(find ~/.config -type d -print | fzf)
     if [ ! -z "$vf_folder" ]; then
         cd $vf_folder
         wtype -k "return"
     fi
 }

# find folders
zle -N f
f() {
     vf_folder=$(find ~ -type d -name '.*' -prune -o -print | fzf)
     if [ ! -z "$vf_folder" ]; then
         cd $vf_folder
         wtype -k "return"
     fi
 }


zle -N _vv
bindkey '^v' _vv
_vv() {
    nvim
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
