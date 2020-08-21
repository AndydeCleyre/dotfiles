export PAGER=less
export LESS=FRXij.5
l () {
    local doc=${@[-1]%:<->##}
    [[ $doc != ${@[-1]} ]] && local linenum=${@[-1]#${doc}:}
    less ${linenum:++${linenum}} ${linenum:+-N} ${@[1,-2]} ${doc}
}

export HIGHLIGHT_OPTIONS='-O truecolor -s aiseered -t 4 --force --stdout'
alias h="highlight"  # <file>
alias hs="h -S"  # <syntax> <file>; <cmd> | hs <syntax>

export BAT_THEME=ansi-dark
alias b="bat -p --pager never --color always"  # <file>
alias bs="b -l"   # <syntax> <file>; <cmd> | bs <syntax>

alias plain="sed 's/\x1b\[[0-9;]*m//g'"  # <cmd> | plain

lh () {
    local doc linenum
    doc=${@[1]%:<->##}
    if [[ $doc != ${@[1]} ]]; then
        linenum=${@[1]#${doc}:}
        h ${doc} ${@[2,-1]} | less ${linenum:++${linenum}} ${linenum:+-N}
    else
        doc=${@[-1]%:<->##}
        [[ $doc != ${@[-1]} ]] && linenum=${@[-1]#${doc}:}
        h ${@[1,-2]} ${doc} | less ${linenum:++${linenum}} ${linenum:+-N}
    fi
}
hh () { h $@ | head -n 20 }
th () { h $@ | tail -n 20 }

alias z="hs zsh"

alias jqq="jq -R -r '. as \$line | try fromjson catch \$line'"
alias jqqq="jq -R 'fromjson?'"

alias gconfig="hs ini .git/config"

d () {
    if (( $+commands[delta] )); then
        diff -u $1 $2 | delta $@[3,-1]
    elif (( $+commands[diff-so-fancy] )); then
        diff -u $1 $2 | diff-so-fancy
    elif (( $+commands[diff-highlight] )); then
        diff -u $1 $2 | diff-highlight
    elif (( $+commands[highlight] )); then
        diff -u $1 $2 | hs diff
    elif (( $+commands[bat] )); then
        diff -u $1 $2 | bs diff
    elif (( $+commands[batcat] )); then
        diff -u $1 $2 | bat -p --pager never --color always -l diff
    else
        diff -u $1 $2
    fi
}

.zhelp () {  # (<zshrc>|<function>|<alias>)
    if [[ -f $1 ]]; then
        pcregrep -Mh '^(alias|([^ \n]+ \(\))|#|$)' $1 | uniq
    else
        pcregrep -Mh '(^#[^\n]+\n)*^(alias '$1'=|('$1' \(\)))' ~/.*zshrc || which $1
    fi
}
zh () {  # (<zshrc>|<function>|<alias>)
    .zhelp $@ | z
}

cols () {  # <range> [delimiter-regex='[[:blank:]]+'] [cut-args...]
    sed -E "s/${2:-[[:blank:]]+}/\t/g" | cut -f $1 ${@:3}
    # local txt=$(sed -E "s/${2:-[[:blank:]]+}/\t/g" | cut -f $1 ${@:3})
    # local numcols=$[$(head -n 1 <<< $txt | grep -o $'\t' | wc -l)+1]
    # local cells=(${(@s:$'\t':)txt})
    # print -raC $numcols $cells
    # print -rl $cells[1]
}
behead () {  # [head-count=1] [delimiter-regex='[[:blank:]]+']
    cols 1-${1:-1} "${2:-[[:blank:]]+}" --complement
}

alias rb="rainbow"

# TODO: probably move some of this parsing/transformation into .zhelp
# TODO: subcommand parsing
# TODO: generalize enough to apply to zpy...
zh_complete () {  # <funcname...>
    for f in $@; do
        _${f} () {
            _arguments '*:icon file:_files'
            _message -r "$(
                .zhelp ${0[2,-1]} \
                | sed -E 's/(.*) \(\) \{  # (.*)/%B\1%b \2/g' \
                | sed -E 's/^(#.*)/%F{blue}\1%f/g'
            )"
        }
        compdef _${f} ${f} 2>/dev/null
    done
}
zh_complete zh cols behead bldr
