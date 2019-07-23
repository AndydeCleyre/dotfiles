export PAGER=less
export LESS=FRXi
alias l=less
alias txt="sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g'"

alias h="highlight -O truecolor -s moria -t 4 --force --stdout"
alias hs="highlight -O truecolor -s moria -t 4 --force --stdout -S"
lh () { h "$@" | less }
hh () { h "$@" | head -n 20 }
th () { h "$@" | tail -n 20 }
dh () { diff "$@" | hs diff }
alias diffh="dh"

alias b="bat -p"
alias bs="bat -p -l"

alias jqq="jq -R -r '. as \$line | try fromjson catch \$line'"
alias jqqq="jq -R 'fromjson?'"

function man() {
 env \
  LESS_TERMCAP_mb=$(printf "\e[1;31m") \
  LESS_TERMCAP_md=$(printf "\e[1;31m") \
  LESS_TERMCAP_me=$(printf "\e[0m") \
  LESS_TERMCAP_se=$(printf "\e[0m") \
  LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
  LESS_TERMCAP_ue=$(printf "\e[0m") \
  LESS_TERMCAP_us=$(printf "\e[1;32m") \
  _NROFF_U=1 \
   man "$@"
}
