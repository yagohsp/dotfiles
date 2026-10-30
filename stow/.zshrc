plugins=(git fzf extract vi-mode)

# vi-mode cursor: block in normal, bar (|) in insert
VI_MODE_SET_CURSOR=true
VI_MODE_CURSOR_NORMAL=2
VI_MODE_CURSOR_INSERT=6
VI_MODE_CURSOR_VISUAL=2

source /usr/share/cachyos-zsh-config/cachyos-config.zsh

bindkey '^F' autosuggest-accept

eval "$(zoxide init zsh)"
unsetopt correctall

export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

alias copy="xclip -selection clipboard"

# "<command> copy" + Enter -> copy "<command>" verbatim to the clipboard instead of running it.
# Uses the raw typed text, so quotes/escapes/$vars are preserved exactly. "cmd | copy" still pipes.
_copy_cmd_accept_line() {
  local match mbegin mend
  if [[ $BUFFER =~ '^[[:space:]]*(.*[^|&;[:space:]])[[:space:]]+copy[[:space:]]*$' ]]; then
    local cmd=$match[1]
    print -rn -- "$cmd" | xclip -selection clipboard
    print -rs -- "$cmd"
    BUFFER=''
    zle -M "Copied: $cmd"
  else
    zle .accept-line
  fi
}
zle -N accept-line _copy_cmd_accept_line
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

# Machine-local settings and secrets (not versioned)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

alias vps="ssh yshen@147.93.8.165"
alias asm=""
alias asmr=""

basm() {
	arg1=$1
	filename=${arg1%.*}
	nasm -g -F dwarf -f elf64 $filename.asm
	ld $filename.o -o $filename

	arg2=$2
	if [[ -n $agr2 ]]; then
		echo $filename
	fi
}

rasm() {
	filename=$(basm $1 $1)
	./$filename
}
