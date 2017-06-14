export PAGER=less
export LESS=FRXi
alias l=less
alias h="highlight -O truecolor -s solarized-light --force --stdout"
alias hs="highlight -O truecolor -s solarized-light --force --stdout -S"
hl () { highlight -O truecolor -s solarized-light --force --stdout "$@" | less }
hh () { highlight -O truecolor -s solarized-light --force --stdout "$@" | head -n 20 }
ht () { highlight -O truecolor -s solarized-light --force --stdout "$@" | tail -n 20 }
