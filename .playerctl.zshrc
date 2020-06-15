alias play="playerctl play-pause"
alias pause="playerctl play-pause"
alias next="playerctl next"
alias skip="playerctl next"
alias back="playerctl previous"
alias previous="playerctl previous"

show () {
	notify-send -a Music "`playerctl metadata title`
by `playerctl metadata artist`
on `playerctl metadata album`"
}

now () {
	print -P "%F{blue}`playerctl metadata title`%f"
	print -P "by %F{yellow}`playerctl metadata artist`%f"
	print -P "on %F{green}`playerctl metadata album`"
}

lyrics () {
    =lyrics $(playerctl --list-all | fzf -0 -1)
}
