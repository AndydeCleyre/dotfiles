[[ "$(command -v lsd)" ]] && alias ls="lsd" || alias ls="ls --color=auto"
alias lsa="ls -a"
alias lsl="ls -l"
alias recent="ls -rt"
[[ "$(command -v lsd)" ]] && alias tree="lsd --tree" || alias tree="tree -C"