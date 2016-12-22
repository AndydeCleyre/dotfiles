export PAGER=vimpager
alias less="$PAGER"
alias lesss="/usr/bin/less"
alias lless="/usr/bin/less"
alias zless="$PAGER"
man () { /usr/bin/man "$1" || "$1" --help | vimpager -c ":set syntax=man" }
