dif () { /usr/bin/diff "$@" | vimcat -c ":set syntax=diff" }
diff () { /usr/bin/diff "$@" | vimpager -c ":set syntax=diff" }
alias difff="/usr/bin/diff"
alias ddiff="/usr/bin/diff"
