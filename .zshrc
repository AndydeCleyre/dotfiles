precmd () { rehash }

export BROWSER=firefox

[[ -e /usr/share/doc/pkgfile/command-not-found.zsh ]] && . /usr/share/doc/pkgfile/command-not-found.zsh

. ~/.editor.zshrc
. ~/.zsh.zshrc
. ~/.antigen.zshrc
. ~/.path.zshrc
. ~/.theme.zshrc

. ~/.buildah.zshrc
. ~/.cd.zshrc
. ~/.docker.zshrc
. ~/.fasd.zshrc
. ~/.git.zshrc
. ~/.hg.zshrc
. ~/.locate.zshrc
. ~/.pacman.zshrc
. ~/.pager.zshrc
. ~/.plasma.zshrc
. ~/.playerctl.zshrc
. ~/.python.zshrc
. ~/.rg.zshrc
. ~/.s6.zshrc
. ~/.steam.zshrc
. ~/.sudo.zshrc
. ~/.systemd.zshrc
. ~/.transfer.sh.zshrc
. ~/.wine.zshrc
[[ -e ~/.work.zshrc ]] && . ~/.work.zshrc
. ~/.wttr.zshrc

alias aw="wiki-search"
alias ariadone="~/Code/ariadone.py"
alias CAPSOFF="python -c 'from ctypes import *; X11 = cdll.LoadLibrary(\"libX11.so.6\"); display = X11.XOpenDisplay(None); X11.XkbLockModifiers(display, c_uint(0x0100), c_uint(2), c_uint(0)); X11.XCloseDisplay(display)'"
configs () { /usr/bin/locate "$1" | egrep "^($HOME/\.|/etc/)" }
alias copyfrom="xclip -sel clip"
alias c="xclip -sel clip"
clip() { echo "$@" | xclip -sel clip }
alias excerpt="mpv --script ~/Code/mpv-plugin-excerpt/excerpt.lua"
alias get="~/Code/clown/get.py"
alias grep="egrep --color=auto -i"
alias g="egrep --color=auto -i"
fax () { grep -v '^\s*#' $1 | tr -s '\n' }
alias no="egrep -i -v"
alias img="/usr/bin/gm"
lines () { sed -n "$1p" "$2" } # lines first[,last] textfile
alias lynx="/usr/bin/lynx -accept_all_cookies"
mkcd () { mkdir -p "$1" && cd "$1" }
alias mounts="lsblk -f"
o () { for f in "$@"; do xdg-open "$f"; done }
alias pd="~/Code/playdelete.py"
alias ports="~/Code/ports.py"
post () { curl -Ffile=@"$1" https://0x0.st }
recent () { ls -rt "$@" | tail -20 }
alias redact="sed -r 's/^(\s*\S*(user(name)?|passw(or)?d|key(_id)?|token|address|secret|blob|email|acct|calendar_(id_)?list) ?[=:] ?)(\S+)$/\1[redacted]/gim'"
alias s="tmux a || tmux"
alias t="tmux a || tmux"
alias subs="subberthehut -nfsq"
alias serve="python -m http.server"
stalj () { ssh "$1" tail -f /var/log/nginx/access.log | logstalgia -f -x -u 1 }
alias tree="tree -C"
alias txtnamer="~/Code/txtnamer.py"
