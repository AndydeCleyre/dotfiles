alias play="playerctl play-pause"
alias pause="playerctl play-pause"
alias next="playerctl next"
alias skip="playerctl next"
alias back="playerctl previous"
alias previous="playerctl previous"

show () {
	notify-send "`playerctl metadata title`
by `playerctl metadata artist`
on `playerctl metadata album`"
}

# ANSI Color -- use these variables to easily have different color
#    and format output. Make sure to output the reset sequence after
#    colors (f = foreground, b = background), and use the 'off'
#    feature for anything you turn on.
# Author: steampunknyanja
# Source: http://crunchbang.org/forums/viewtopic.php?pid=146715#p146715
initializeANSI()
{
  esc="\x1b"

  blackf="${esc}[30m";   redf="${esc}[31m";    greenf="${esc}[32m"
  yellowf="${esc}[33m"   bluef="${esc}[34m";   purplef="${esc}[35m"
  cyanf="${esc}[36m";    whitef="${esc}[37m"

  blackb="${esc}[40m";   redb="${esc}[41m";    greenb="${esc}[42m"
  yellowb="${esc}[43m"   blueb="${esc}[44m";   purpleb="${esc}[45m"
  cyanb="${esc}[46m";    whiteb="${esc}[47m"

  boldon="${esc}[1m";    boldoff="${esc}[22m"
  italicson="${esc}[3m"; italicsoff="${esc}[23m"
  ulon="${esc}[4m";      uloff="${esc}[24m"
  invon="${esc}[7m";     invoff="${esc}[27m"

  reset="${esc}[0m"
}

initializeANSI

now () {
	echo "$bluef`playerctl metadata title`$reset"
	echo "by $yellowf`playerctl metadata artist`$reset"
	echo "on $greenf`playerctl metadata album`"
}

