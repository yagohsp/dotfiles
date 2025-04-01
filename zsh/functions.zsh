# git status
zle -N gs
bindkey '^G' gs
gs() {
    git status
        wtype -k "return"
}

# find config file
zle -N _vc
bindkey '\eo' _vc
_vc() {
    vc_file=$(find ~/.config \( -name node_modules -o -name .git \) -prune -o -type f -print | fzf --preview 'bat --style=numbers --color=always {} || cat {}') 
    if [ ! -z "$vc_file" ]; then
        vc_path=$(dirname $vc_file)
        cd $vc_path
        nvim $vc_file
        wtype -k "return"
    fi
}

# find folders
zle -N _vf
bindkey '\ep' _vf
_vf() {
     vf_folder=$(find ~ -type d -name '.*' -prune -o -type d -print | fzf)
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
