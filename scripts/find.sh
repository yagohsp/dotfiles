#!/bin/bash
file=$(find ~/dotfiles \( -name node_modules -o -name .git \) -prune -o -type f -print \
    | fzf --no-sort --preview 'bat --style=numbers --color=always {} || cat {}')

if [[ -n "$file" ]]; then
    dir=$(dirname "$file")
    tmux new-window "cd '$dir' && exec \$SHELL"
fi
