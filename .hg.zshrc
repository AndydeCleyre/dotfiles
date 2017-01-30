hcat () { hg cat "$@" }
hdif () { hg diff "$@" | highlight -O truecolor -s solarized-light -S diff }
hdiff () { hg diff "$@" | highlight -O truecolor -s solarized-light -S diff | "$PAGER" }
hmeld () { hg cat -r "$1" "$2" > hg_meld_other && meld "$2" hg_meld_other && rm hg_meld_other }
