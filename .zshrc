precmd () { rehash }

export BROWSER=firefox

[[ -e /usr/share/doc/pkgfile/command-not-found.zsh ]] && . /usr/share/doc/pkgfile/command-not-found.zsh

. ~/.antigen.zshrc
. ~/.editor.zshrc
. ~/.zsh.zshrc
. ~/.path.zshrc

. ~/.cd.zshrc
. ~/.docker.zshrc
. ~/.git.zshrc
. ~/.hg.zshrc
. ~/.locate.zshrc
. ~/.pacman.zshrc
. ~/.pager.zshrc
. ~/.plasma.zshrc
. ~/.playerctl.zshrc
. ~/.python.zshrc
. ~/.rg.zshrc
. ~/.steam.zshrc
. ~/.sudo.zshrc
. ~/.systemd.zshrc
. ~/.transfer.sh.zshrc
. ~/.tree.zshrc
. ~/.wine.zshrc
[[ -e ~/.work.zshrc ]] && . ~/.work.zshrc
. ~/.wttr.zshrc

compdef yadm=git

alias aw="wiki-search"
alias CAPSOFF="python -c 'from ctypes import *; X11 = cdll.LoadLibrary(\"libX11.so.6\"); display = X11.XOpenDisplay(None); X11.XkbLockModifiers(display, c_uint(0x0100), c_uint(2), c_uint(0)); X11.XCloseDisplay(display)'"
configs () { /usr/bin/locate "$1" | egrep "($HOME/\.|/etc/)" }
alias copyfrom="xclip -sel clip"
clip() { echo "$@" | xclip -sel clip }
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
