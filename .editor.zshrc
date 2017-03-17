export EDITOR=micro
export MICRO_TRUECOLOR=1

alias e="$EDITOR"
alias se="sudoedit"
xe () { touch "$@"; chmod +x "$@"; $EDITOR "$@" }

alias smeld="SUDO_EDITOR=meld sudoedit"

alias subl="subl3"
xsubl () { touch "$@"; chmod +x "$@"; subl3 "$@" }
