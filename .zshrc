. ~/.theme.zshrc

. /usr/share/doc/pkgfile/command-not-found.zsh 2>/dev/null

() {
    local zshzpath=/home/andy/Code/plugins/zsh-z/zsh-z.plugin.zsh
    ZSHZ_CMD=j ZSHZ_NO_RESOLVE_SYMLINKS=1 ZSHZ_UNCOMMON=1 . $zshzpath 2>/dev/null
}

. /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh 2>/dev/null \
|| . /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

. ~/.editor.zshrc
. ~/.zsh.zshrc

. ~/.awk.zshrc
. ~/.buildah.zshrc
. ~/.cd.zshrc
. ~/.git.zshrc
. ~/.grep.zshrc
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
. ~/.work.zshrc 2>/dev/null
. ~/.wttr.zshrc

alias aw="wiki-search"
alias c="xclip -sel clip"
clip() { echo "$@" | xclip -sel clip }
alias copy="rsync -aPhhh"
alias ddg="ddgr -n 3 -x --show-browser-logs"
alias decrypt="xclip -sel clip -o | gpg --decrypt"
alias downthese="aria2c -i downthese.txt"
alias fz="fzf --reverse -m -0"
alias ggl="googler --show-browser-logs -x -n 6"
logit () {  # [logdir]
    s6-log t s4194304 S41943040 ${${1:-log-${$(s6-clock)#@}}:a}
}
alias lynx="=lynx -accept_all_cookies"
# -scrollbar_arrow -scrollbar -use_mouse
mkcd () { mkdir -p "$1" && cd "$1" }
alias mounts="lsblk -f"
o () { for f in "$@"; do xdg-open "$f"; done }
alias p="xclip -sel clip -o"
post () { curl -Ffile=@"$1" https://0x0.st }
alias pt="papertrail"
alias qb="qbittorrent-nox --portable --sequential"
redact () {
    local secret_assignment=('^(\s*\S*('
        'user(name)?|_id|acct'
        '|passw(or)?d|key|token|secret'
        '|address|email'
        '|blob|data'
        '|History Items\[\$e\]'
        '|calendar_(id_)?list'
    ') ?[=:] ?)(\S+)$')
    sed -E "s/${(j::)secret_assignment}/\1[redacted]/gim" $@ \
    | sed -E 's-(.+://[^:]+:)([^@]+)(@.+)-\1[redacted]\3-g' \
    | sed -E 's/(.*: )?(.*)\\$/\1[redacted]/g' \
    | sed -E 's/^[^"]+"$/[redacted]/g'
}
alias repeaterbounce="ssh 192.168.2.1 reboot || echo 'Try connecting to the repeater network first.'"
alias routerbounce="ssh 192.168.1.1 reboot || echo 'Try connecting to the main network first.'"

alias subs="subberthehut -nfsq"
alias sem="semaphoreci"
alias serve="python -m http.server"
alias spleet="spleeter separate -o . -i"
alias t="tmux a || tmux"
tmerge () {
    tmux splitw
    tmux selectp -t 0
    tmux send -l "diff -u ${(q-)1} ${(q-)2} | diff-so-fancy | $PAGER"; tmux send Enter
    tmux selectp -t 1
    # tmux send -l "$EDITOR ${(q-)1} ${(q-)2}"; tmux send Enter
    tmux send -l "$EDITOR ${(q-)2}"; tmux send Enter
}
vidcut () {  # sourcevid start [end]
    local end=${3:-$(ffprobe -v -8 -show_entries format=duration -of csv=p=0 $1)}
    local vidname="${1:r}--cut-${2//:/_}-${end//:/_}.${1:e}"
    ffmpeg -i "$1" -ss "$2" -to "$end" -c copy -map 0 "$vidname"
}
vidgif () {  # sourcevid [gif-filename]
    ffmpeg -i $1 -vf "fps=10,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" ${2:-${1:r}.gif}
}
vidtg () {  # sourcevid [video-encoder=copy [audo-encoder=copy]]
# TODO: fzf multi-choosing streams and codecs
    local vidname="${1:r}--tg.mp4"
    # ffmpeg -i "$1" -an -c:v libx264 "$vidname"
    # ffmpeg -i "$1" -an -c:v libx264 "$vidname"
    ffmpeg -i "$1" -c:v "${2:-copy}" -c:a "${3:-copy}" -c:s mov_text -map 0 "$vidname"
}
voices () {  # [text]
    for voice in ${(z)"$(mimic -lv)"#*: }; do
        print "Testing voice: $voice . . ."
        mimic -t "$1; This voice is called $voice" -voice $voice \
        || print "%F{red}ERROR testing $voice%f"
    done
}
say () {  # <text...>
    mimic -voice awb -t "${(j: :)@}"
}
alias xdn="xargs -d '\n'"

cleansubs () {  # <srt file>...
    local patterns=(
        '^Advertise your prod.*'
        '^Support us and become.*'
        '.*OpenSub.*'
        '\[[^]]+\]'
        '\([^)]+\)'
        '♪.*'
        '.*♪'
    )
    for pattern in $patterns; do
        if rg -S -C 2 $pattern *srt; then
            if read -q "?Delete matches [yN]? "; then
                sed -i -E "s/${pattern}//g" $@
            fi
            print '\n'
        fi
    done
}

pw () {  # [<filter-word>...]
    rbw login
    local fzf_args=(--reverse -0)
    if [[ $1 ]]; then
        fzf_args+=(-q "${(j: :)@}")
    fi
    # rbw get "$(rbw ls | fzf $fzf_args)" | xclip -sel clip
    local lines=(${(f)"$(rbw get --full "$(rbw ls | fzf $fzf_args)")"})
    xclip -sel clip <<<${lines[2]##Username: }
    xclip -sel clip <<<${lines[1]}
}

# txtnamer () {  # [<old_filename>...]
    # local old_names=($@)
    # [[ $old_names ]] || old_names=(./*(:t))
    # local names_file=$(mktemp)
    # ${(F)old_names} > $names_file
    # names_file.write('\n'.join(old_names))
    # local[local.env['EDITOR']](names_file)
    # new_names = names_file.read().strip().splitlines()
# if len(new_names) == len(old_names):
    # for old_path, new_path in zip(
        # map(local.path, old_names), map(local.path, new_names)
    # ):
        # if old_path != new_path:
            # print(
                # old_path.name | red,
                # new_path.name | green, '', sep='\n'
            # )
            # old_path.move(new_path)
# }

() {  # Assume always 1 or 0 sessions
    if [[ ! $TMUX ]]; then
        local REPLY
        if read -t 3 -k "?Attach to tmux session [Yn]? "; then
            if [[ $REPLY == $'\n' || $REPLY:l == y ]]; then
                tmux a || tmux
            fi
        fi
        clear
    fi
}
