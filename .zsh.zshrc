export ZSH_CACHE_DIR="$HOME/.cache/zsh"
autoload -U compinit
compinit

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

HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_verify
setopt share_history

if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init() { echoti smkx }
    function zle-line-finish() { echoti rmkx }
    zle -N zle-line-init
    zle -N zle-line-finish
fi
push-line-and-clear() { zle .push-line; zle .clear-screen }
zle -N push-line-and-clear
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey '^L' push-line-and-clear
bindkey ' ' magic-space
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
if [[ "${terminfo[kcuu1]}" != "" ]]; then bindkey "${terminfo[kcuu1]}" history-beginning-search-backward-end; fi
if [[ "${terminfo[kcud1]}" != "" ]]; then bindkey "${terminfo[kcud1]}" history-beginning-search-forward-end; fi
if [[ "${terminfo[kpp]}" != "" ]]; then bindkey "${terminfo[kpp]}" up-line-or-history; fi
if [[ "${terminfo[knp]}" != "" ]]; then bindkey "${terminfo[knp]}" down-line-or-history; fi
if [[ "${terminfo[khome]}" != "" ]]; then bindkey "${terminfo[khome]}" beginning-of-line; fi
if [[ "${terminfo[kend]}" != "" ]]; then bindkey "${terminfo[kend]}"  end-of-line; fi
if [[ "${terminfo[kcbt]}" != "" ]]; then bindkey "${terminfo[kcbt]}" reverse-menu-complete; fi
if [[ "${terminfo[kdch1]}" != "" ]]; then bindkey "${terminfo[kdch1]}" delete-char
else bindkey "^[[3~" delete-char; bindkey "^[3;5~" delete-char; bindkey "\e[3~" delete-char; fi

zcheck () { [[ "$#" -gt 0 ]] && (egrep --color=auto -i "$@" ~/.*zshrc || (which "$@" || true) ) || highlight -O truecolor -s solarized-light --stdout ~/.zshrc ~/.*.zshrc | tr -s '\n' | "$PAGER" }
