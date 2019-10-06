. /usr/share/doc/pkgfile/command-not-found.zsh 2> /dev/null || true

. ~/.editor.zshrc
. ~/.zsh.zshrc
. ~/.path.zshrc
. ~/.theme.zshrc

. ~/.buildah.zshrc
. ~/.cd.zshrc
. ~/.fasd.zshrc
. ~/.git.zshrc
. ~/.hg.zshrc
. ~/.ls.zshrc
. ~/.pacman.zshrc
. ~/.pager.zshrc
. ~/.plasma.zshrc
. ~/.playerctl.zshrc
. ~/.python.zshrc
. ~/.rg.zshrc
. ~/.s6.zshrc
. ~/.scripts.zshrc
. ~/.steam.zshrc
. ~/.sudo.zshrc
. ~/.systemd.zshrc
. ~/.wine.zshrc
[[ -e ~/.work.zshrc ]] && . ~/.work.zshrc
. ~/.wttr.zshrc

alias arglines="xargs -d '\n'"
alias aw="wiki-search"
configs () { /usr/bin/locate -i "$1" | grep "^($HOME/\.|/etc/)" }
alias copyfrom="xclip -sel clip"
alias c="xclip -sel clip"
clip() { echo "$@" | xclip -sel clip }
alias cuts="cut -d ' '"
alias ddg="ddgr -n 3 -x --show-browser-logs"
alias decrypt="xclip -sel clip -o | gpg --decrypt"
alias diffr="diffr --colors 'added:background:black' --colors 'refine-added:background:black'"
alias downthese="aria2c -i downthese.txt"
alias g="grep -P --color=auto -i"
alias ge="grep -E --color=auto -i"
fax () { grep -v '^\s*#' $1 | tr -s '\n' }
alias leaves="grep -E --color=auto '[^/]+$'"
alias no="grep -P -i -v"
alias img="/usr/bin/gm"
lines () { sed -n "$1p" "$2" } # lines first[,last] textfile
alias lynx="/usr/bin/lynx -accept_all_cookies"
mkcd () { mkdir -p "$1" && cd "$1" }
alias mounts="lsblk -f"
o () { for f in "$@"; do xdg-open "$f"; done }
alias p="xclip -sel clip -o"
post () { curl -Ffile=@"$1" https://0x0.st }
alias pt="papertrail"
redact () {
    sed -E 's/^(\s*\S*(user(name)?|_id|passw(or)?d|key|token|address|secret|blob|email|acct|History Items\[\$e\]|calendar_(id_)?list) ?[=:] ?)(\S+)$/\1[redacted]/gim' $@ \
    | sed -E 's-(.+://[^:]+:)([^@]+)(@.+)-\1[redacted]\3-g'
}
alias repeaterbounce="ssh 192.168.2.1 reboot || echo 'Try connecting to the repeater network first.'"
alias routerbounce="ssh 192.168.1.1 reboot || echo 'Try connecting to the main network first.'"
alias subs="subberthehut -nfsq"
alias serve="python -m http.server"
alias t="tmux a || tmux"
vidcut () {  # sourcevid start [end]
    local _end=${3:-$(ffprobe -v -8 -show_entries format=duration -of csv=p=0 $1)}
    local _vidname="${1:r}--cut-${2//:/_}-${_end//:/_}.${1:e}"
    ffmpeg -i "$1" -ss "$2" -to "$_end" -c copy "$_vidname"
}

bindkey -s '^f' '`fzf --reverse`\n'
