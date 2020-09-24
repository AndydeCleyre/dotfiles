() {
    local zpypath=~/Code/zpy/zpy.plugin.zsh
    # local zpypath=~/Code/plugins/zsh/zpy/zpy.plugin.zsh
    . $zpypath
}
alias ii="ipython"
alias i="ptipython"
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
    if [[ $@ ]]; then
        m zshall $@
    else
        man zshall
    fi
}
