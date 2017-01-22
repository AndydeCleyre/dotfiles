export ZSH_CACHE_DIR="$HOME/.cache/zsh"
mkdir -p "$ZSH_CACHE_DIR"

if [[ -z "$LS_COLORS" ]]; then (( $+commands[dircolors] )) && eval "$(dircolors -b)"; fi
alias ls='ls --color=tty'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

unsetopt menu_complete
setopt auto_menu
setopt complete_in_word
setopt always_to_end
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path $ZSH_CACHE_DIR

autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey '\e[A' history-beginning-search-backward-end
bindkey '\e[B' history-beginning-search-forward-end
push-line-and-clear() { zle .push-line; zle .clear-screen }
zle -N push-line-and-clear
bindkey '^L' push-line-and-clear
bindkey ' ' magic-space
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init() { echoti smkx }
    function zle-line-finish() { echoti rmkx }
    zle -N zle-line-init
    zle -N zle-line-finish
fi
if [[ "${terminfo[kdch1]}" != "" ]]; then
    bindkey "${terminfo[kdch1]}" delete-char
else
    bindkey "^[[3~" delete-char; bindkey "^[3;5~" delete-char; bindkey "\e[3~" delete-char
fi
if [[ "${terminfo[kpp]}" != "" ]]; then bindkey "${terminfo[kpp]}" up-line-or-history; fi
if [[ "${terminfo[knp]}" != "" ]]; then bindkey "${terminfo[knp]}" down-line-or-history; fi
if [[ "${terminfo[khome]}" != "" ]]; then bindkey "${terminfo[khome]}" beginning-of-line; fi
if [[ "${terminfo[kend]}" != "" ]]; then bindkey "${terminfo[kend]}"  end-of-line; fi
if [[ "${terminfo[kcbt]}" != "" ]]; then bindkey "${terminfo[kcbt]}" reverse-menu-complete; fi

alias zedit="nano ~/.zshrc && . ~/.zshrc"
alias zedits="subl3 -w ~/.zshrc && . ~/.zshrc"
alias sedit="subl3 -w ~/.zshrc && . ~/.zshrc"
alias zsource=". ~/.zshrc"
zcheck () { [[ "$#" -gt 0 ]] && (egrep --color=auto -i "$@" ~/.*zshrc || (which "$@" || true) ) || "$PAGER" ~/.zshrc }
