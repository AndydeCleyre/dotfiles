autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey '\e[A' history-beginning-search-backward-end
bindkey '\e[B' history-beginning-search-forward-end

push-line-and-clear() {
    zle .push-line
    zle .clear-screen
}
zle -N push-line-and-clear
bindkey '^L' push-line-and-clear

alias zedit="nano ~/.zshrc && . ~/.zshrc"
alias zedits="subl3 -w ~/.zshrc && . ~/.zshrc"
alias sedit="subl3 -w ~/.zshrc && . ~/.zshrc"
alias zsource=". ~/.zshrc"
zcheck () { [[ "$#" -gt 0 ]] && (egrep --color=auto -i "$@" ~/.*zshrc || (which "$@" || true) ) || "$PAGER" ~/.zshrc }
