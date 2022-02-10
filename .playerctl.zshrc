alias play="playerctl play-pause"
alias pause="playerctl play-pause"
alias next="playerctl next"
alias skip="playerctl next"
alias back="playerctl previous"
alias previous="playerctl previous"

osd () {
  emulate -L zsh
  # TODO: port back to panel applet
  local lines=("$(playerctl metadata title)" "by $(playerctl metadata artist)")
  local album=$(playerctl metadata album)
  if [[ $album ]] lines+=("on $album")

	notify-send -a Listening -i cantata "${(F)lines}"
}

now () {
  emulate -L zsh

  local lines=(
    "%F{blue}$(playerctl metadata title)%f"
    "by %F{yellow}$(playerctl metadata artist)%f"
  )
  local album=$(playerctl metadata album)
  if [[ $album ]] lines+=("on %F{green}$album%f")

	print -rlP $lines
}

lyrics () {
  =lyrics $(playerctl --list-all | fzf -0 -1)
}

# genius () {
  # emulate -L zsh
  # TODO: store token privately...
  # TODO: auto-respawn on song change?
  # better handled by first making one daemon that replaces fixed-place json file
  # and then monitor that for changes?

#   local folder=$(mktemp -d)
#   trap "cd ${(q-)PWD} && rm -rf ${(q-)folder}; return" EXIT INT QUIT
#   cd $folder

#   GENIUS_ACCESS_TOKEN="zvbLcyuFDnSfkS_E7ooWwO4IQtPccAuc69XMrKAXZDPGuXOQHJI_y6_qPGAf7z0S" \
#   lyricsgenius --save song "$(playerctl metadata title)" "$(playerctl metadata artist)"

#   local json=(*.json(N))
#   if [[ ! -r $json ]] return 1

#   print -- $(yaml-get -p lyrics $json) | $PAGER
# }

genius-pager () {
  emulate -L zsh

  local json=${XDG_CACHE_HOME:-~/.cache}/genius/lyrics.json

  while (( 1 )) {
    if [[ -r $json ]] {
      clear
      print -rPl -- "%B$(yaml-get -p full_title $json)%b" ''
      print -- "$(yaml-get -p lyrics $json)"
    }
    inotifywait -qq -e modify -e attrib -e move -e move_self -e create -e delete -e delete_self -e unmount $json
  }
}

# genius-daemon () {
#   emulate -L zsh
#   # TODO: store token privately... see GH issue
#   # TODO: auto-respawn on song change?
#   local title artist workdir json prev_title prev_artist
#   local cachedir=${XDG_CACHE_HOME:-~/.cache}/genius
#   mkdir -p $cachedir

#   workdir=$(mktemp -d)
#   trap "cd ${(q-)PWD} && rm -rf ${(q-)workdir}; return" EXIT INT QUIT
#   cd $workdir || return 2

#   while { true } {
#     title=$(playerctl -p ncspot metadata title)
#     artist=$(playerctl -p ncspot metadata artist)

#     if [[ ! $title || ! $artist ]] || [[ $title == $prev_title && $artist == $prev_artist ]] {
#       sleep 6
#       continue
#     }

#     prev_title=$title
#     prev_artist=$artist

#     rm -f *.json
#     GENIUS_ACCESS_TOKEN="zvbLcyuFDnSfkS_E7ooWwO4IQtPccAuc69XMrKAXZDPGuXOQHJI_y6_qPGAf7z0S" \
#     lyricsgenius --save song $title $artist

#     json=(*.json(N))
#     if [[ ! -r $json ]] {
#       sleep 45
#       continue
#     }

#     print -rPl -- '' "%B$(yaml-get -p full_title $json)%b" '' >>$cachedir/lyrics.txt
#     print -- "$(yaml-get -p lyrics $json)" >>$cachedir/lyrics.txt
#     mv $json $cachedir/lyrics.json
#     sleep 6
#   }



  # local folder=${XDG_CACHE_HOME:-~/.cache}/genius
  # mkdir -p $folder

  # print -- $(yaml-get -p lyrics $json) | $PAGER
# }
