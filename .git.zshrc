alias ga="git add"
alias gapa="echoti clear && git add --patch"
alias gc="git commit -v"
gcat () {  # <branch> <file>
    git show $1:$2
}
alias gca="git commit -v -a"
gcl () {  # <uri> [<folder>] [<git clone arg>...]
    local uri=$1; shift
    local folder
    if [[ ! $1 || $1 =~ ^- ]]; then
        folder=${${${uri:gs.:./}:t}%.git}
    else
        folder=$1; shift
    fi
    git clone --recursive $@ $uri $folder \
    && cd $folder
}
gcl1 () { gcl $@ --depth 1 }
alias gco="git checkout --recurse-submodules"
alias gd="git diff --submodule=diff"
alias gitgraph="git log --graph --all --decorate --oneline"
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
    git checkout develop
}

alias gist="gh gist create --public"

# alias gsub="git submodule foreach"
# gsub () {
    # git submodule foreach zsh -fc ". ~/.git.zshrc; ${(j: :)@}"
# }

# Run cmd in each git submodule's folder
gsub () {  # <cmd> [<cmd-arg>...]
  emulate -L zsh
  trap "cd ${(q-)PWD}" EXIT INT QUIT

  local repo submods=(${(f)"$(git submodule foreach -q --recursive pwd)"})

  print -rl -- "Visiting each of:" $submods
  for repo ( $submods ) {
    cd $repo
    print -rl -- '' "Entering ${repo}…"
    eval "$@"
  }
}

if (( $+functions[compdef] )) {
  _gsub () {
    _message "Run cmd in each git submodule's folder; Usage: gsub <cmd> [<cmd-arg>...]"
    shift 1 words
    (( CURRENT-=1 ))
    _normal -P
  }
  compdef _gsub gsub
}

# alias yp="yadm pull --recurse-submodules"
alias yp="yadm submodule foreach git pull"
