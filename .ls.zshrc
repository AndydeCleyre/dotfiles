if (( $+commands[lsd] )); then
    alias ls="lsd"
    tree () {
        local depth dirsonly
        while [[ $1 == -L || $1 == -d ]]; do
            if [[ $1 == -L ]]; then
                depth=(--depth $2)
                shift 2
            fi
            if [[ $1 == -d ]]; then
                dirsonly=1
                shift
            fi
        done
        if [[ $dirsonly ]]; then
            lsd --tree $depth --icon always --color always $@ | grep 
        else
            lsd --tree $depth $@
        fi
    }
else
    alias ls="ls --color=auto"
    alias tree="tree -C"
fi

alias lsa="ls -a"
alias recent="ls -rt"

if (( $+commands[exa] )); then
    alias lsl="exa -lb --git"
else
    alias lsl="ls -l"
fi
