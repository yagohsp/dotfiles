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

ss() {
    local folder="${1:-.}"
    local depth="${2:-3}"
    local type="${3:-file}"

    local ignored_dirs="( -name .git -o -name node_modules -o -name __pycache__ )"

    if [[ "$type" == "dir" ]]; then
        local list
        list=$(find "$folder" -maxdepth "$depth" \
                \( -type d \( -name .git -o -name node_modules -o -name __pycache__ \) -prune \) \
                -o \( -type d -print \) \
            | grep -vE '/(\.git|node_modules|__pycache__)(/|$)')
        [[ -z "$list" ]] && echo "No dir found." && return 1
        local selected
        selected=$(echo "$list" | fzf --preview 'tree -L 2 {}')
        [[ -z "$selected" ]] && return 1
        cd "$selected"
    else
        local list
        list=$(find "$folder" -maxdepth "$depth" \
                \( -type d \( -name .git -o -name node_modules -o -name __pycache__ \) -prune \) \
                -o \( -type f \
                ! -name '.DS_Store' \
                ! -name '*.pyc' \
                ! -name '*.o' \
                ! -name '*.class' \
                ! -name '*.swp' \
                ! -name '*.tmp' \
                ! -name '*.lock' \
                ! -name '*.log' \
                -print \) \
            | grep -vE '/(\.git|node_modules|__pycache__)(/|$)')
        [[ -z "$list" ]] && return 1
        local selected
        selected=$(echo "$list" | fzf --preview 'bat --style=numbers --color=always --line-range=:100 {}')
        [[ -z "$selected" ]] && return 1
        cd "$(dirname "$selected")" && nvim "$(basename "$selected")"
    fi
}

fd(){
    ss ~/dotfiles 10
}

fdd(){
    ss ~/dotfiles 10 dir
}

fdc(){
    ss ~/dotfiles/.config 10
}

fy(){
    ss ~/y 1 dir
}

fw(){
    ss ~/w 2 dir
}
