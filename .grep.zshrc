(( $+commands[pcregrep] )) && alias g="pcregrep --color -i" || alias g="grep -P --color -i"
alias ge="grep -E --color -i"
alias no="grep -Piv"
fax () { grep -Ev '^(\s*#|$)' $1 }
gblock () { pcregrep -Mh '(^[^\n]+\n)*[^\n]*'$1'[^\n]*(\n[^\n]+)*' ${@[2,-1]} }

alias leaves="grep -E --color=auto '[^/]+$'"

fnd () {
    term='*'$1'*'
    cmd=(find -L . -iname ${(q-)term})
    for term in ${@:2}; do
        cmd+=('|' grep -iP ${(q-)term})
    done
    eval $cmd
}
loc () {
    cmd=(locate -i --regex ${(q-)1})
    for term in ${@:2}; do
        cmd+=('|' grep -iP ${(q-)term})
    done
    eval $cmd
}
alias locu="sudo updatedb && loc"
alias uloc="sudo updatedb && loc"
configs () { loc "$1" "^($HOME/\.|/etc/)" | no ~/.cache }

# gymlblock () { pcregrep -Mh '^[^ \n]+\n(^ [^\n]+\n)*[^\n]*'$1'[^\n]*(\n[^\n]+)*' ${@[2,-1]} }
# gyml () { pcregrep -Mh '(^[^ ]*\n)*'$1'([^\n]*\n)(^[^ ]*)' }
# gyml () { pcregrep -Mh '(^[^ ]*\n)*'$1'([^\n]*\n)(^[^ ]*)' }
# gyml () { ''$1'[^\n]*(\n [^\n]*)*(>=\n[^ ])' }
# gyml () { '^('$1')?[^ ]*[^\n]*\n'$1'[^\n]*(\n [^\n]*)*' }
