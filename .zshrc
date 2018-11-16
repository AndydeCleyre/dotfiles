export BROWSER=firefox

[[ -e /usr/share/doc/pkgfile/command-not-found.zsh ]] && . /usr/share/doc/pkgfile/command-not-found.zsh

. ~/.editor.zshrc
. ~/.zsh.zshrc
. ~/.path.zshrc
. ~/.theme.zshrc

. ~/.buildah.zshrc
. ~/.cd.zshrc
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
# configs () { /usr/bin/locate -i "$1" | grep "^($HOME/\.|/etc/)" | grep --color=auto "/[^/]*$" }
configs () { /usr/bin/locate -i "$1" | grep "^($HOME/\.|/etc/)" }
alias copyfrom="xclip -sel clip"
alias c="xclip -sel clip"
clip() { echo "$@" | xclip -sel clip }
alias cuts="cut -d ' '"
alias decrypt="xclip -sel clip -o | gpg --decrypt"
alias define="/home/andy/.local/share/venvs/23689963cd6571d2a4488a6e27452cee/venv/bin/define"
alias downthese="aria2c -i downthese.txt"
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
alias redact="sed -r 's/^(\s*\S*(user(name)?|_id|passw(or)?d|key|token|address|secret|blob|email|acct|calendar_(id_)?list) ?[=:] ?)(\S+)$/\1[redacted]/gim'"
alias routerbounce="ssh 192.168.1.1 reboot || echo 'Try connecting to the main network first.'"
alias subs="subberthehut -nfsq"
alias serve="python -m http.server"
alias t="tmux a || tmux"
stalj () { ssh "$1" tail -f /var/log/nginx/access.log | logstalgia -f -x -u 1 }
alias tree="tree -C"
alias txtnamer="~/Code/txtnamer.py"
alias x="~/Code/x.py"
alias arglines="xargs -d '\n'"
