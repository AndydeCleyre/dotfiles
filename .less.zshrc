export PAGER=less
export LESS=FRXi
man () { /usr/bin/man "$1" || "$1" --help | c -- -l haskell }
