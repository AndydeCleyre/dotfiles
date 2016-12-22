alias gitgraph="git log --graph --all --decorate --oneline"
hotfixed () { git checkout develop && git push && git checkout master && git push && git push --tags }

