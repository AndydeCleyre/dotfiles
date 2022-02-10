() {
    local zshzpath=~/Code/plugins/zsh/zsh-z/zsh-z.plugin.zsh
    if [[ -r $zshzpath ]] ZSHZ_CMD=j ZSHZ_NO_RESOLVE_SYMLINKS=1 ZSHZ_UNCOMMON=1 . $zshzpath
}

. ~/.zsh.zshrc

() {
    local cnfpath=/usr/share/doc/pkgfile/command-not-found.zsh
    if [[ -r $cnfpath ]] . $cnfpath

    local fshpath=~/Code/plugins/zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
    if [[ -r $fshpath ]] . $fshpath
}

. ~/.theme.zshrc

. ~/.editor.zshrc

. ~/.awk.zshrc
. ~/.buildah.zshrc
. ~/.cd.zshrc
. ~/.git.zshrc
. ~/.grep.zshrc
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
if [[ -r ~/.work.zshrc ]] . ~/.work.zshrc
. ~/.wttr.zshrc

ccb-tail () {
  ssh ccb podman exec -it ccb tail -F /home/colorcodebot/logs/colorcodebot/current \
  | lnav
}

alias aw="wiki-search"
alias c="xclip -sel clip"
clip() { echo "$@" | xclip -sel clip }
alias copy="rsync -aPhhh"
alias ddg="ddgr -n 3 -x --show-browser-logs"
alias decrypt="xclip -sel clip -o | gpg --decrypt"
alias downthese="aria2c --console-log-level=error -i downthese.txt"
alias fz="fzf --reverse -m -0"
alias ggl="googler --show-browser-logs -x -n 6"
alias hm="typeset -p"
alias huh="typeset -p"
alias imdb="imdb-rename ~/.cache/imdb-rename"
logrun () {  # <cmd> [<cmd-arg>...]
    emulate -L zsh
    # local logdir=${${:-$1.${$(s6-clock)#@}.log.d}:a}
    local logdir=$PWD:a/$1.${$(s6-clock)#@}.log.d
    REPLY=$logdir/current
    print -r -- $REPLY
    $@ | s6-log t s4194304 S41943040 $logdir
}
logit () {  # [logdir]
    emulate -L zsh
    # TODO: get and use process name
    # lsof /dev/fd/0
    # lsof /dev/stdin
    local name
    if { lsof -h |& grep -q lsof-org } {
        # local incoming=${${:-/dev/stdin}:P}
        # print -- ${${:-/dev/stdin}:P}
        name=${$(lsof -F c ${${:-/dev/stdin}:P} 2>/dev/null)[2][2,-1]}
    }

    local logdir=${${1:-${name}${name:+.}${$(s6-clock)#@}.log.d}:a}

    REPLY=$logdir/current
    print -r -- $REPLY

    s6-log t s4194304 S41943040 $logdir
}
# TODO: move to s6 zshrc...
alias lynx="=lynx -accept_all_cookies"
# -scrollbar_arrow -scrollbar -use_mouse
mkcd () { mkdir -p "$1" && cd "$1" }
alias mounts="lsblk -f"
newage () {
  emulate -L zsh
  mkdir -p ~/.config/sops/age
  print -rl "# --- ${1:-$(date +"%Y-%m-%d %H:%M:%S%Z")} ---" >>~/.config/sops/age/keys.txt
  age-keygen >>~/.config/sops/age/keys.txt
}
o () { for f in "$@"; do xdg-open "$f"; done }
alias p="xclip -sel clip -o"
post () { curl -Ffile=@"$1" https://0x0.st }
alias pt="papertrail"
alias qb="qbittorrent-nox --portable --sequential"
redact () {
    emulate -L zsh
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
tsplit () {  # <file>...
    emulate -L zsh
    zmodload -F zsh/stat b:zstat

    local reply
    for 1 {
        zstat -A reply +size $1
        if (( reply > 2097152000 )) {
            7z a -mx0 -v2000m "${1:t:r}.7z" $1
        } else {
            print -ru 2 -- "Skipping small-enough $1"
        }
        # TODO: more precisely max out the sizes
    }
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
  ffmpeg \
    -i "$1" \
    -c:v "${2:-copy}" \
    -c:a "${3:-copy}" \
    -c:s mov_text \
    -movflags +faststart \
    "$vidname"
    # -map 0 \
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

cleansubs () {  # [<srt file>...]
  emulate -L zsh

  local srts=(${@:-*.srt})
  [[ $srts ]] || return 1

  local patterns=(
    '^Advertise your prod.*'
    '^Support us and become.*'
    '.*OpenSub.*'
    '.*Please rate this subtitle.*'
    '.*choose the best subtitles*'
    '\[[^]]+\]'
    '\([^)]+\)'
    '♪.*'
    '.*♪'
  )

  for pattern ( $patterns ) {
    if { rg -S -C 2 $pattern $srts } {
      if { read -q "?Delete matches [yN]? " } {
        sed -i -E "s/${pattern}//g" $srts
      }
      print '\n'
    }
  }
}

pw () {  # [<filter-word>...]
    rbw login
    local fzf_args=(--reverse -0)
    if [[ $1 ]] fzf_args+=(-q "${(j: :)@}")
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

pj () {
    local appname=${PWD:t}
    mkdir -p $appname test doc
    print -rl -- \
        '"""Does the thing"""' '' '__version__ = "0.0.1"' \
    >>$PWD/$appname/__init__.py
}

#####################
### .broot.zshrc? ###
#####################
br () {  # [<broot-opt>...]
  emulate -L zsh

  local cmdfile=$(mktemp)
  trap "rm ${(q-)cmdfile}" EXIT INT QUIT
  if { broot --outcmd "$cmdfile" $@ } {
    if [[ -r $cmdfile ]] eval "$(<$cmdfile)"
  } else {
    return
  }
}

# alias brp="br --color yes --conf $HOME/.config/broot/conf.hjson\;$HOME/.config/broot/select.hjson"
.zle_insert-path-broot () {
  local location_space="${(q-)$(broot --color yes --conf $HOME/.config/broot/conf.hjson\;$HOME/.config/broot/select.hjson)} "
  BUFFER+=$location_space
  (( CURSOR+=$#location_space ))
}
zle -N .zle_insert-path-broot
bindkey '^[[1;7B' .zle_insert-path-broot  # ctrl+alt+down

# brcd () {  # [<broot-opt>...]
  # cd "$(br --color yes --conf "$HOME/.config/broot/conf.hjson;$HOME/.config/broot/select-folder.hjson" $@)"
# }
.zle_cd-broot () {
  cd "$(broot --color yes --conf "$HOME/.config/broot/conf.hjson;$HOME/.config/broot/select-folder.hjson")"
  .zle_redraw-prompt
}
zle -N .zle_cd-broot
bindkey '^[[1;3B' .zle_cd-broot  # alt+down
#####################

espansee () {
  emulate -L zsh -o errreturn

  local cfg=${XDG_CONFIG_HOME:-~/.config}/espanso

  local ymls=($cfg/default.yml $cfg/user/*.yml)

  local yml=$(print -rl $ymls | fzf --reverse -0)

  local triggers=("$(yaml-get -p 'matches.trigger' $yml)")

  local reps=()
  for 1 ( $triggers ) reps+=("$(yaml-get -p "matches[trigger = $1].replace" $yml)")

  print -rC2 -- $triggers $reps
}

# alias font="fontpreview-ueberzug -b '#262c2e' -f '#b8bb26' -t"
# alias fonts="fontpreview-ueberzug -b '#262c2e' -f '#b8bb26' -t 'A wizard\'s job\nis to vex chumps\nquickly in fog.\ndbqp mrnuv\n96 Il1 QO0\n@&*S5Z2'"
# mournful vet
fonts () {  # [-s <size>] [[+]<text>...]
  local fpu_args=(-b '#262c2e' -f '#b8bb26')
  if [[ $1 == -s ]] {
    fpu_args+=($1 $2)
    shift 2
  }
  local text=(
    # 'Quick fox jumps'
    # 'nightly above wizard!'
    # 'dbqp mrnuv BRP 3&8$S5s'
    # 'Wait! Quick wizard'
    # 'jumps fox nghly bve'
    # 'wacky jig; oz hex!'
    # 'dbqp mrnuv tf QODUACGJ'
    # 'wtf zacky? goji hex!'
    'wtf jack? ziggy hex!'
    'dbqp mrnuv QOD GUACJ'
    # '96 Il1 ~-O0 Z27 4@*'
    # '0O 1Il 496 72Z ~- @*'
    'o0O 1Il 496 72Z~- @*'
    # '96 Il1~-QO0 Z27 @*'
    "EFPRBKHMW 3&8\$S5s ;'"
  )
  if [[ $1 ]] {
    if [[ ${1[1]} == + ]] {
      text+=(${1[2,-1]} ${@[2,-1]})
    } else {
      text=($@)
    }
  }
  fontpreview-ueberzug $fpu_args -t ${(F)text}
#
# Pack my box with
# five dozen liquor jugs!
# Waxy and quivering, jocks fumble the pizza!
    # "A wizard's job
    # is to vex chumps
    # quickly in fog!?
    # dbqp mrnuv BRP 3&8$sS5
    # 96 Il1 QO0 Z27 @*"

    # local text="A wizard's job\nis to vex chumps\nquickly in fog.\ndbqp mrnuv\n96 Il1 QO0\n@&*S5Z2"
    # if [[ $1 ]] text="$@"
    # fontpreview-ueberzug $fpu_args -t $text
    # fontpreview-ueberzug -b '#262c2e' -f '#b8bb26' -t $text
    # fontpreview-ueberzug -b '#262c2e' -f '#b8bb26' -t "A wizard's job\nis to vex chumps\nquickly in fog.\ndbqp mrnuv\n96 Il1 QO0\n@&*S5Z2"
    # fontpreview-ueberzug -b '#262c2e' -f '#b8bb26' -t "${1:-A wizard's job\nis to vex chumps\nquickly in fog.\ndbqp mrnuv\n96 Il1 QO0\n@&*S5Z2}"
}

x () {  # <archive>
  emulate -L zsh
  zmodload -mF zsh/files 'b:zf_mkdir'
  rehash

  local first_choice new_folder
  local -i count ret
  for 1 {

    # local first_choice
    if [[ $1:t:r ]] {
      first_choice=${1:a:r}
    } else {
      first_choice=${1:a}.contents
    }

    # local new_folder=$first_choice
    # local -i count=0
    new_folder=$first_choice
    count=0
    while [[ -e $new_folder ]] {
      new_folder=${first_choice}.${count}
      count+=1
    }

    if (( $+commands[notify-send] )) notify-send -i ark -a Extracting "${1:t}" "$new_folder"

    zf_mkdir $new_folder
    if (( $+commands[7zz] )) {
      7zz x "-o${new_folder}" $1
    } elif (( $+commands[7z] )) {
      7z x "-o${new_folder}" $1
    } elif (( $+commands[aunpack] )) {
      aunpack -X "$new_folder" $1
    } elif (( $+commands[ark] )) {
      ark -b -o "$new_folder" $1
    } elif (( $+commands[tar] )) {
      tar xf $1 --directory="$new_folder"
    } else {
      print -rPu2 "%F{red}No suitable unarchiver detected!%f"
      return 1
    }
    ret=$?

    print -ru2 Destination: $new_folder

    if (( $+commands[notify-send] )) notify-send -i ark -a "Finished Extracting" "${${ret:#0}:+[ERROR $ret] }${1:t}" "$new_folder"
    return ret
  }
}

alias yt="ytfzf -t"
alias ytnew="ytfzf -t --sort"
alias ytvid="ytfzf -tdf"
alias ytsound="ytfzf -tdmf"

if (( $+functions[compdef] )) {
  _please () {
    shift 1 words
    (( CURRENT-=1 ))
    _normal -P
  }
  compdef _please please
}

() {  # Assume always 1 or 0 sessions
    if [[ ! $TMUX ]]; then
        local REPLY
        if read -t 3 -k "?Attach to tmux session [Yn]? "; then
            if [[ $REPLY == $'\n' || $REPLY:l == y ]] tmux a || tmux
        fi
        clear
    fi
}

if (( ${+functions[p10k]} )) p10k finalize  # See .theme.zshrc
