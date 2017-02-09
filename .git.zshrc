alias gitgraph="git log --graph --all --decorate --oneline"
hotfixed () { git checkout develop && git push && git checkout master && git push && git push --tags }
function git_current_branch() { # from oh-my-zsh, used by oh-my-zsh's git plugin (gpsup)
    local ref
    ref=$(command git symbolic-ref --quiet HEAD 2> /dev/null)
    local ret=$?
    if [[ $ret != 0 ]]; then
        [[ $ret == 128 ]] && return  # no git repo.
        ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
    fi
    echo ${ref#refs/heads/}
}
