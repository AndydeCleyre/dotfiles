# . /usr/share/zsh/site-functions/_yay

alias spacman="sudo pacman"
alias update-mirrors="sudo reflector --save /etc/pacman.d/mirrorlist --sort score --country 'United States' --country 'Canada' --latest 30 -p http"
alias y="yay"
alias yc="sudo DIFFPROG='sudo -u andy env SUDO_EDITOR=meld sudoedit' pacdiff"
ycl () { yay -G $1 && cd ${1#*/} }
alias yg="ycl"

__pkgdesc () {  # <pkgname>
    pacman -Qi "$1" | grep -E '^Description\s+:' | sed -E 's/.+:\s+(.+)/\1/'
}

why () {  # <pkgname...>
    for pkg in $@; do
        pactree -r $pkg
        __pkgdesc $pkg
    done
}
_why () { _alternative "arguments:Installed Packages:($(pacman -Qq))" }
compdef _why why

alias whose="pacman -Qo"
_whose () { _alternative 'arguments:Files:_files' 'arguments:Commands:_files -W /bin' }
compdef _whose whose

when () {  # <pkgname-filter>
    ((( $+commands[rainbow] )) &&
        grep -aEi "ed [^ ]*$1" /var/log/pacman.log \
        | rainbow \
            --bold '(?<=^\[\d{4}-)\d{2}-\d{2}' \
            --blue reinstalled \
            --green installed \
            --yellow upgraded \
            --red removed \
            --bold '[^ \(]+(?=\)$)' \
            --bold '(?<='$1')\S+' \
            --bold '\S+(?='$1')' \
            --italic $1
    ) ||
        grep -aEi "ed [^ ]*$1" /var/log/pacman.log
}
            # --bold '(?<= -> )[^ ]+(?=\)$)' \
_when () {
    local repos=($(pacman-conf --repo-list) AUR)
    _arguments '1:All Packages:(${$(yay -Pc):|repos})'
}
compdef _when when yg

# alias what="pactree -c"

where () {  # pkgname
    (pacman -Qql "$@" || pkgfile -lq "$@") | grep -P -v "/$"
}
_where () { _alternative 'arguments:All Packages:_pacman_completions_all_packages' }
compdef _where where
alias what="where"
