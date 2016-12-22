hcat () { hg cat "$@" }
hdif () { hg diff "$@" | vimcat -c ":set syntax=diff" }
hdiff () { hg diff "$@" | vimpager -c ":set syntax=diff" }
hmeld () { hg cat -r "$1" "$2" > hg_meld_other && meld "$2" hg_meld_other && rm hg_meld_other }
