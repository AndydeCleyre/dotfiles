export PATH=$HOME/bin:/usr/local/bin:$PATH
type ruby &> /dev/null && export PATH=$HOME/bin:/usr/local/bin:$(ruby -rubygems -e "puts Gem.user_dir")/bin:$PATH
type rbenv &> /dev/null && eval "$(rbenv init -)"
export GOPATH=~/go
export PATH=$PATH:$GOPATH/bin
typeset -U PATH

