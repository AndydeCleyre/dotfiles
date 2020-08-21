if (( $+commands[exa] )); then
    alias ls="exa -b --git"
    alias recent="exa -b --git -snew"
    tree () {
        local depth dirsonly
        while [[ $1 == -L || $1 == -d ]]; do
            if [[ $1 == -L ]]; then
                depth=(-L $2)
                shift 2
            fi
            if [[ $1 == -d ]]; then
                dirsonly=-D
                shift
            fi
        done
        exa -bT --git $depth $dirsonly $@
    }
else
    alias ls="ls --color=auto"
    alias tree="tree -C"
    alias recent="ls -rt"
fi

alias lsa="ls -a"

alias lsl="ls -l"
