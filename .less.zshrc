export PAGER=less
export LESS=FRXi
export C_PYGMENTS_THEME=lovelace
man () { /usr/bin/man "$1" || "$1" --help | c -- -l haskell }
