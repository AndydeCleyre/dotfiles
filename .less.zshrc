export PAGER=less
export LESS=FRXi
alias l=less
man () { /usr/bin/man "$1" || "$1" --help | highlight -O truecolor -s solarized-light -S lua | less }
alias h="highlight -O truecolor -s solarized-light --force"
alias hs="highlight -O truecolor -s solarized-light --force -S"
