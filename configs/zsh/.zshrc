plugins=(git fzf extract vi-mode)
source /usr/share/cachyos-zsh-config/cachyos-config.zsh

bindkey '^F' autosuggest-accept

eval "$(zoxide init zsh)"
unsetopt correctall

export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

alias copy="xclip -selection clipboard"
alias ca="cursor-agent"
alias car="cursor-agent --resume"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/yago/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/home/yago/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/yago/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/yago/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/yago/.lmstudio/bin"
# End of LM Studio CLI section

export PATH="$HOME/Android/Sdk/platform-tools:$PATH"
export ANDROID_HOME="$HOME/Android"

