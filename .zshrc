precmd () { rehash }

export EDITOR=nano
export BROWSER=firefox

. /usr/share/doc/pkgfile/command-not-found.zsh

. ~/.zsh.zshrc
. ~/.path.zshrc
. ~/.antigen.zshrc

. ~/.ag.zshrc
. ~/.cat.zshrc
. ~/.cd.zshrc
. ~/.diff.zshrc
. ~/.docker.zshrc
. ~/.fzf.zshrc
. ~/.git.zshrc
. ~/.hg.zshrc
. ~/.less.zshrc
. ~/.locate.zshrc
. ~/.pacman.zshrc
. ~/.plasma.zshrc
. ~/.playerctl.zshrc
. ~/.python.zshrc
. ~/.steam.zshrc
. ~/.sublime.zshrc
. ~/.sudo.zshrc
. ~/.systemd.zshrc
. ~/.transfer.sh.zshrc
. ~/.tree.zshrc
. ~/.wine.zshrc
. ~/.work.zshrc
. ~/.wttr.zshrc
. ~/.xtouch.zshrc

alias aw="wiki-search"
configs () { /usr/bin/locate "$1" | egrep "($HOME/\.|/etc/)" }
alias connect="nmtui"
alias copyfrom="xclip -sel clip"
alias excerpt="mpv --lua ~/Code/mpv-plugin-excerpt/excerpt.lua"
alias get="~/Code/clown/get.py"
alias grep="egrep --color=auto -i"
fax () { grep -v '^#' $1 | tr -s '\n' }
alias no="egrep -i -v"
alias img="/usr/bin/gm"
lines () { sed -n "$1p" "$2" } # lines first[,last] textfile
alias lynx="/usr/bin/lynx -accept_all_cookies"
mkcd () { mkdir -p "$1" && cd "$1" }
alias mounts="lsblk -f"
alias open="xdg-open"
alias ports="~/Code/ports.py"
post () { curl -Ffile=@"$1" https://0x0.st }
recent () { ls -rt "$@" | tail -20 }
alias s="tmux a || tmux"
alias t="tmux a || tmux"
alias serve="python -m http.server"
stalj () { ssh "$1" tail -f /var/log/nginx/access.log | logstalgia -f -x -u 1 }
alias txtnamer="~/Code/txtnamer.py"
