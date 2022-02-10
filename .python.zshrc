PYTHONNOUSERSITE=1

() {
    # local zpypath=~/Code/zpy/zpy.plugin.zsh
    local zpypath=~/Code/plugins/zsh/zpy/zpy.plugin.zsh
    . $zpypath
}
alias i="ipython"
pyenv-init () { eval "$(pyenv init - zsh)" }

# This was the slowest-running single command in my zshrc by an order of magnitude:
# eval "$(pip completion -z)"
# So here's its output run more directly:
function _pip_completion {
    local words cword
    read -Ac words
    read -cn cword
    reply=($(
        COMP_WORDS="$words[*]" \
        COMP_CWORD=$(( cword-1 )) \
        PIP_AUTO_COMPLETE=1 $words[1] 2>/dev/null
    ))
}
compctl -K _pip_completion pip

alias define="cambrinary -w"
alias so="socli -iq"
alias sopy="socli -i -t python -q"
m () {
  # mansnip $@ | lh -S man
  mansnip $@ | bat -p -l man | less
}
mz () {
  if [[ $@ ]] {
    # m zshall $@
    mansnip zshall $@ | bat -p -l man | less
  } else {
    man zshall
  }
}
wk () {  # <word-or-phrase>
  emulate -L zsh
  local json="$(ddgr -n 3 -x --json 'site:en.wiktionary.org' "$1")"
  for 1 ( 0 1 2 ) {
    print -rP -- "%B%U$(yaml-get -p $1.title <<<$json)%u%b $(yaml-get -p $1.url <<<$json)"
    print
    yaml-get -p $1.abstract <<<$json
    print
  }
}
without () {  # [<yamlpath>=sops]
  if [[ -t 1 ]] {
    yaml-set -g "${1:-sops}" -D | hs yml
  } else {
    yaml-set -g "${1:-sops}" -D
  }
}
