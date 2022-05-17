precmd () { rehash }

# Keys: esc,h
unalias run-help 2>/dev/null || true
autoload -Uz run-help  # Smarter-than-man help for current command

autoload -Uz zargs

setopt extendedglob
setopt globdots
setopt nocaseglob

setopt interactivecomments

fpath=(~/.local/share/zsh/site-functions $fpath)
autoload -Uz compinit
compinit -d ~/.cache/zsh/zcompdump-$ZSH_VERSION
setopt auto_menu
setopt complete_in_word
setopt always_to_end

if (( $+commands[dircolors] )) eval "$(dircolors -b)"
zstyle ':completion:*'           list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:*:*:*'   menu select

zstyle ':completion:*'           matcher-list 'm:{a-z}={A-Za-z}' '+l:|=* r:|=*'
zstyle ':completion:*'           accept-exact-dirs 'yes'

zstyle ':completion:*'           group-name ''
zstyle ':completion:*'           format '%F{blue}%U☛ %B%d:%b%u%f'
zstyle ':completion::complete:*' cache-path "$HOME/.cache/zsh"; mkdir -p "$HOME/.cache/zsh"
zstyle ':completion::complete:*' use-cache 1

zstyle ':completion:complete-files:*' completer _files
zle -C complete-files menu-complete _generic
bindkey '^T' complete-files  # ctrl+t
bindkey '^.' complete-files  # ctrl+.

HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_verify
setopt share_history

WORDCHARS=${WORDCHARS//[\/]}

multibind () {  # <cmd> <in-string> [<in-string>...]
  emulate -L zsh
  local cmd=$1; shift
  for 1 { bindkey $1 $cmd }
}

bindkey ' ' magic-space
bindkey '^[[Z' reverse-menu-complete

multibind delete-char '^[[3~' "^[3'5~" '\e[3~'  # del

multibind beginning-of-line '^[[1;5A' '^[[H' '^[[1~'  # home
multibind end-of-line '^[[1;5B' '^[[F' '^[[4~'  # end

multibind backward-word '^[[1;5D' '^[[5~'  # ctrl+left
multibind forward-word '^[[1;5C' '^[[6~'  # ctrl+right


# Expand aliases on the line, with ctrl+x
expand-aliases () {  # https://unix.stackexchange.com/a/150737
  unset 'functions[_expand-aliases]'
  functions[_expand-aliases]=$BUFFER
  if (( $+functions[_expand-aliases] )) {
    BUFFER=${functions[_expand-aliases]#$'\t'}
    CURSOR=$#BUFFER
  }
}
zle -N expand-aliases
bindkey '^X' expand-aliases

# Keys: up; down
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end  history-search-end
multibind history-beginning-search-backward-end '^[OA' '^[[A'  # up
multibind history-beginning-search-forward-end  '^[OB' '^[[B'  # down

setopt noflowcontrol
bindkey -r '^s'

zcheck () {
    if [[ "$#" -gt 0 ]] {
        grep -E --color=auto -i "$@" ~/.*zshrc || which "$@"
    } else {
        tail -vn +1 ~/.zshrc ~/.*.zshrc
    }
}

# {{{ Inline Selection

# Keys: del; backspace; left; right; ctrl+{left,right}
# Depends: multibind
# Credit: https://stackoverflow.com/a/30899296

# TODO: [terminfo] Shift combinations aren't picked up.
#       shift+{left,right} and ctrl+shift+{up,down} only
#       work within tmux, and shift+{pgup,pgdown} not at all.

.zle_deselect-and-left () { (( REGION_ACTIVE=0 )); zle backward-char }
zle -N .zle_deselect-and-left
bindkey '^[[D' .zle_deselect-and-left  # left

.zle_deselect-and-right () { (( REGION_ACTIVE=0 )); zle forward-char }
zle -N .zle_deselect-and-right
bindkey '^[[C' .zle_deselect-and-right  # right

.zle_deselect-and-left-word () { (( REGION_ACTIVE=0 )); zle backward-word }
zle -N .zle_deselect-and-left-word
multibind .zle_deselect-and-left-word '^[[1;5D' '^[[5~'  # ctrl+left; pgup

.zle_deselect-and-right-word () { (( REGION_ACTIVE=0 )); zle forward-word }
zle -N .zle_deselect-and-right-word
multibind .zle_deselect-and-right-word '^[[1;5C' '^[[6~'  # ctrl+right; pgdown

.zle_deselect-and-home () { (( REGION_ACTIVE=0 )); zle beginning-of-line }
zle -N .zle_deselect-and-home
multibind .zle_deselect-and-home '^[[1;5A' '^[[H' '^[[1~'  # home

.zle_deselect-and-end () { (( REGION_ACTIVE=0 )); zle end-of-line }
zle -N .zle_deselect-and-end
multibind .zle_deselect-and-end '^[[1;5B' '^[[F' '^[[4~'  # end

.zle_del-selected-or-bksp () { if (( REGION_ACTIVE )) { zle kill-region } else { zle backward-delete-char } }
zle -N .zle_del-selected-or-bksp
bindkey '^?' .zle_del-selected-or-bksp  # backspace

.zle_del-selected-or-del () { if (( REGION_ACTIVE )) { zle kill-region } else { zle delete-char } }
zle -N .zle_del-selected-or-del
multibind .zle_del-selected-or-del '^[[3~' "^[3'5~" '\e[3~'  # del

.zle_select-and-left () { if ! (( REGION_ACTIVE )) zle set-mark-command; zle backward-char }
zle -N .zle_select-and-left
bindkey '^[[1;2D' .zle_select-and-left  # shift+left

.zle_select-and-right () { if ! (( REGION_ACTIVE )) zle set-mark-command; zle forward-char }
zle -N .zle_select-and-right
bindkey '^[[1;2C' .zle_select-and-right  # shift+right

.zle_select-and-left-word () { if ! (( REGION_ACTIVE )) zle set-mark-command; zle backward-word }
zle -N .zle_select-and-left-word
bindkey '^[[1;6D' .zle_select-and-left-word  # ctrl+shift+left; TODO: shift+pgup

.zle_select-and-right-word () { if ! (( REGION_ACTIVE )) zle set-mark-command; zle forward-word }
zle -N .zle_select-and-right-word
bindkey '^[[1;6C' .zle_select-and-right-word  # ctrl+shift+right; TODO: shift+pgdown

.zle_select-and-home () { if ! (( REGION_ACTIVE )) zle set-mark-command; zle beginning-of-line }
zle -N .zle_select-and-home
multibind .zle_select-and-home '^[[1;2H' '^[[1;6A'  # shift+home; ctrl+shift+up

.zle_select-and-end () { if ! (( REGION_ACTIVE )) zle set-mark-command; zle end-of-line }
zle -N .zle_select-and-end
multibind .zle_select-and-end '^[[1;2F' '^[[1;6B'  # shift+end; ctrl+shift+down

# }}} Inline Selection

.zle_redraw-prompt () {
  # Credit: romkatv/z4h
  emulate -L zsh
  for 1 ( chpwd $chpwd_functions precmd $precmd_functions ) {
    if (( $+functions[$1] ))  $1 &>/dev/null
  }
  zle .reset-prompt
  zle -R
}

# {{{ Folder Up, Back, Forward

# Keys: alt+{up,left,right}
# Depends: .zle_redraw-prompt
# Credit: romkatv/z4h

setopt autopushd pushdignoredups
DIRSTACKSIZE=12

.zle_cd-up () { cd ..; .zle_redraw-prompt }
zle -N .zle_cd-up
bindkey '^[[1;3A' .zle_cd-up  # alt+up

.zle_cd-rotate () {
  emulate -L zsh
  while (( $#dirstack )) && ! { pushd -q $1 &>/dev/null } { popd -q $1 }
  if (( $#dirstack ))  .zle_redraw-prompt
}

.zle_cd-back () { .zle_cd-rotate +1 }
zle -N .zle_cd-back
bindkey '^[[1;3D' .zle_cd-back  # alt+left

.zle_cd-forward () { .zle_cd-rotate -0 }
zle -N .zle_cd-forward
bindkey '^[[1;3C' .zle_cd-forward  # alt+right

# }}} Folder Up, Back, Forward

# {{{ Better Screen Clearing: clear line, restore it at next prompt, and redraw

# Keys: ctrl+l
# Depends: .zle_redraw-prompt

.zle_push-line-and-clear () { zle .push-line; zle .clear-screen; .zle_redraw-prompt }
zle -N .zle_push-line-and-clear
bindkey '^L' .zle_push-line-and-clear

# }}} Better Screen Clearing

if [[ $TMUX ]] {
  .zle_tmux-copy-mode-pgup () { tmux copy-mode -u }
  zle -N .zle_tmux-copy-mode-pgup
  bindkey '^[[5~' .zle_tmux-copy-mode-pgup  # pgup
}

