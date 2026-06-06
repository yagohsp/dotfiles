plugins=(git fzf extract vi-mode)
source /usr/share/cachyos-zsh-config/cachyos-config.zsh

bindkey '^F' autosuggest-accept

eval "$(zoxide init zsh)"
unsetopt correctall

export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

alias copy="xclip -selection clipboard"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/yago/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/home/yago/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/yago/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/yago/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

. "$HOME/.local/bin/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/yago/.lmstudio/bin"
# End of LM Studio CLI section

