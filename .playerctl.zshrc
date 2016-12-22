alias play="playerctl play-pause"
alias pause="playerctl play-pause"
alias next="playerctl next"
alias skip="playerctl next"
alias back="playerctl previous"
alias previous="playerctl previous"

now () {
	echo "$fg[blue]`playerctl metadata title`$reset_color"
	echo "by $fg[yellow]`playerctl metadata artist`$reset_color"
	echo "on $fg[green]`playerctl metadata album`"
}

show () {
	notify-send "`playerctl metadata title`\

by `playerctl metadata artist`\

on `playerctl metadata album`"
}
