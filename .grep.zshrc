# if (( $+commands[pcre2grep] ))    { alias g="pcre2grep --color -i"
# } elif (( $+commands[pcregrep] )) { alias g="pcregrep --color -i"
# } else                            { alias g="grep -P --color -i" }

g () {  # <grep-arg>...
  emulate -L zsh
  rehash

  local cmd=(grep -P --color -i)
  if (( $+commands[pcre2grep] )) {
    cmd=(pcre2grep --color -i)
  } elif (( $+commands[pcregrep] )) {
    cmd=(pcregrep --color -i)
  } elif [[ ${commands[grep]:P:t} != grep ]] {
    cmd=(grep -E --color -i)
  }

  $cmd $@
}

alias ge="grep -E --color -i"
alias no="grep -Piv"
alias leaves="grep -E --color=auto '[^/]+$'"

fax () {  # [<file>...]
  emulate -L zsh

  if [[ $1 ]] {
    for 1 { grep -Ev '^(\s*#|$)' $1 }
  } else  { grep -Ev '^(\s*#|$)'    }
}

gblock () {  # <term> [<pcre(2)grep-arg>...]
  emulate -L zsh
  rehash

  # TODO: rg
  # TODO: pure zsh with pcre?

  if (( $+commands[pcre2grep] )) {
    pcre2grep -Mh '(^[^\n]+\n)*[^\n]*'$1'[^\n]*(\n[^\n]+)*' ${@[2,-1]}
  } else {
    pcregrep -Mh '(^[^\n]+\n)*[^\n]*'$1'[^\n]*(\n[^\n]+)*' ${@[2,-1]}
  }
}

loc () {  # <regex-term>...
  emulate -L zsh

  local cmd=(locate -i --regex ${(q-)1})
  for 1 ( ${@[2,-1]} ) {
    cmd+=('|' grep -iP ${(q-)1})
  }
  eval $cmd
}
alias locu="sudo updatedb && loc"
alias uloc="sudo updatedb && loc"

configs () {  # <app-term>
  emulate -L zsh
  loc "$1" "^($HOME/\.|/etc/)" | no ~/.cache
}

# gymlblock () { pcregrep -Mh '^[^ \n]+\n(^ [^\n]+\n)*[^\n]*'$1'[^\n]*(\n[^\n]+)*' ${@[2,-1]} }
# gyml () { pcregrep -Mh '(^[^ ]*\n)*'$1'([^\n]*\n)(^[^ ]*)' }
# gyml () { pcregrep -Mh '(^[^ ]*\n)*'$1'([^\n]*\n)(^[^ ]*)' }
# gyml () { ''$1'[^\n]*(\n [^\n]*)*(>=\n[^ ])' }
# gyml () { '^('$1')?[^ ]*[^\n]*\n'$1'[^\n]*(\n [^\n]*)*' }

# insertline

fnd () {  # [-F] <leaf-term> [<term>...]
  emulate -L zsh -o extendedglob -o globdots

  local matches=()
  if [[ $1 == -F ]] {
    shift
    matches=(**/*(#l)$1*)
  } else {
    matches=(***/*(#l)$1*)
  }
  shift
  for 1 {
    matches=(${(M)matches:#*(#l)$1*})
  }

  print -rl -- $matches
}
