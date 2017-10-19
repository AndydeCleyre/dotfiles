export EDITOR=micro
export MICRO_TRUECOLOR=1

alias e="$EDITOR"
alias se="sudoedit"
xe () { touch "$@"; chmod +x "$@"; $EDITOR "$@" }

alias smeld="SUDO_EDITOR=meld sudoedit"

xsubl () { touch "$@"; chmod +x "$@"; subl "$@" }
