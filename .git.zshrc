alias ga="git add"
alias gapa="git add --patch"
alias gc="git commit -v"
alias gca="git commit -v -a"
gcl () {  # <uri> [<folder>] [<git clone arg>...]
    local uri=$1; shift
    local folder
    if [[ ! $1 || $1 =~ ^- ]]; then
        folder=${${${uri:gs.:./}:t}%.git}
    else
        folder=$1; shift
    fi
    git clone --recursive $@ $uri $folder
    cd $folder
}
gcl1 () { gcl $@ --depth 1 }
alias gco="git checkout --recurse-submodules"
gcp () {  # <branch> <file>
    git show $1:$2 > $2
}
alias gd="git diff --submodule=diff"
alias gitgraph="git log --graph --all --decorate --oneline"
# alias gl="git pull --recurse-submodules --all"
alias gl="git pull --recurse-submodules"
gls () {  # [<branch> [<git ls-tree arg>...]]
    git ls-tree -r --name-only ${1:-$(git branch --show-current)} ${@[2,-1]}
}
alias gm="git merge"
alias gp="git push"
alias gpsup="git push --set-upstream"
alias gsb="git status -sb"

alias gf="git flow"
alias gfi="git flow init -d"
hotfixed () {
    git checkout develop && git push
    git checkout master && git push
    git push --tags
}
