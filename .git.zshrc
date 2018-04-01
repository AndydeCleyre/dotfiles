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
alias ga="git add"
alias gapa="git add --patch"
alias gc="git commit -v"
alias gca="git commit -v -a"
alias gcl="git clone --recursive"
alias gco="git checkout"
alias gd="git diff"
alias gitgraph="git log --graph --all --decorate --oneline"
alias gl="git pull"
alias gm="git merge"
alias gp="git push"
alias gpsup="git push --set-upstream origin $(git_current_branch)"
alias gsb="git status -sb"
hotfixed () { git checkout develop && git push && git checkout master && git push && git push --tags }
