#!/usr/bin/env sh

apk update
apk upgrade

apk add  git bash zsh go make lua-dev boost-dev g++ openssl # highlight (try this if 3.35+ gets to alpine)

# micro
# - go, make
export GOPATH=~/go
go get -d github.com/zyedidia/micro
cd $GOPATH/src/github.com/zyedidia/micro
make install
mv $GOPATH/bin/micro /usr/local/bin/
cd
rm -r $GOPATH

# highlight
# - lua-dev, boost-dev, make, g++
highlight_v=3.35
wget "http://www.andre-simon.de/zip/highlight-$highlight_v.tar.bz2"
tar xf "highlight-$highlight_v.tar.bz2"
cd "highlight-$highlight_v"
make cli
make install
cd ..
rm -r "highlight-$highlight_v"*

# antigen
# - zsh, openssl
antigen_v="1.4.1"
mkdir /usr/share/zsh/share
wget "https://cdn.rawgit.com/zsh-users/antigen/v${antigen_v}/bin/antigen.zsh" -P /usr/share/zsh/share

# yadm
# - bash, git
git clone https://github.com/TheLocehiliosan/yadm ~/.yadm-project
ln -s ~/.yadm-project/yadm /usr/local/bin/yadm
yadm clone https://github.com/andydecleyre/dotfiles

apk add python3-dev ncdu htop

chsh -s /bin/zsh
zsh
