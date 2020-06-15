p10kpath=/usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
# p10kpath=~/Code/powerlevel10k/powerlevel10k.zsh-theme
if [[ -r $p10kpath ]]; then
    . ~/.cache/p10k-instant-prompt-$USERNAME.zsh 2>/dev/null
    . $p10kpath
    . ~/.p10k.zsh 2>/dev/null
    POWERLEVEL9K_VIRTUALENV_GENERIC_NAMES=()
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status context dir vcs pyenv virtualenv background_jobs vpn_ip time command_execution_time newline prompt_char)
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
    POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION='%B>>%b'
    POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION='%B>>%b'
    PROMPT2='%B%F{yellow}……%f%b '
    POWERLEVEL9K_SHORTEN_DELIMITER=…
    POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=3
    POWERLEVEL9K_DIR_MAX_LENGTH=80
    POWERLEVEL9K_STATUS_ERROR=true
    POWERLEVEL9K_VIRTUALENV_FOREGROUND=5
    POWERLEVEL9K_PYENV_FOREGROUND=5
    POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=true
    POWERLEVEL9K_VIRTUALENV_SHOW_WITH_PYENV=true
    POWERLEVEL9K_TIME_FORMAT='%D{%L:%M:%S}'
else
    . ~/.theme.zshrc
fi

. /usr/share/doc/pkgfile/command-not-found.zsh 2>/dev/null

zshzpath=/usr/share/zsh/plugins/zsh-z/zsh-z.plugin.zsh
ZSHZ_CMD=j ZSHZ_NO_RESOLVE_SYMLINKS=1 . $zshzpath 2>/dev/null

. /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh 2>/dev/null \
|| . /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

. ~/.editor.zshrc
. ~/.zsh.zshrc
. ~/.path.zshrc

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
alias ddg="ddgr -n 3 -x --show-browser-logs"
alias decrypt="xclip -sel clip -o | gpg --decrypt"
alias downthese="aria2c -i downthese.txt"
alias fz="fzf --reverse -m -0"
logit () {  # [logdir]
    s6-log t s4194304 S41943040 ${${1:-log-${$(s6-clock)#@}}:a}
}
alias lynx="/usr/bin/lynx -accept_all_cookies"
mkcd () { mkdir -p "$1" && cd "$1" }
alias mounts="lsblk -f"
alias mz="mansnip zshall"
o () { for f in "$@"; do xdg-open "$f"; done }
alias p="xclip -sel clip -o"
post () { curl -Ffile=@"$1" https://0x0.st }
alias pt="papertrail"
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

cleansubs () {
    local patterns=(
        '^Advertise your prod.*'
        '^Support us and become.*'
        '.*OpenSub.*'
    )
    for pattern in $patterns; do
        if rg -S -C 2 $pattern *srt; then
            if read -q "?Delete matches [yN]? "; then
                sed -i "s/${pattern}//g" *srt
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
    # rbw doesn't currently work for getting usernames...
    rbw get "$(rbw ls | fzf $fzf_args)" | xclip -sel clip
}
