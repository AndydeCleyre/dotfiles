export EDITOR=micro
export MICRO_TRUECOLOR=1

alias e="$EDITOR"
alias se="sudoedit"
alias smeld="SUDO_EDITOR=meld sudoedit"
xt () { touch "$@"; chmod +x "$@" }
xe () { xt "$@"; $EDITOR "$@" }
xsubl () { xt "$@"; subl "$@" }

bindkey -s '^e' '_to_edit=$(fzf --reverse) && $EDITOR ${(q-)_to_edit}\n'
