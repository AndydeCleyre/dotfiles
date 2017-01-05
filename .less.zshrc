export PAGER=vimpager
alias less="$PAGER"
alias lesss="/usr/bin/less -i"
alias lless="/usr/bin/less -i"
alias zless="$PAGER"
man () { /usr/bin/man "$1" || "$1" --help | vimpager -c ":set syntax=man" }
