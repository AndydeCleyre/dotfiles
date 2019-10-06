alias bld="buildah"
alias bldc="buildah containers"
alias bldi="buildah images"

bldr () {  # cname [cmd]
    if [[ "$#" -eq 0 ]]; then
        bldr ${"$(buildah containers --format "{{.ContainerName}} :: {{.ImageName}}" | fzf --reverse)"%% :: *}
    else
        buildah inspect $1 &> /dev/null || buildah from --pull-always --name $1 alpine:edge
        buildah config --env TERM=$TERM $1
        buildah run -t $1 ${${@:2}:-$(buildah run $1 grep -E -v '^(#|$)' /etc/shells | fzf --reverse)}
    fi
}

bldrfrom () {  # iname cname [cmd]
    buildah inspect $2 &> /dev/null && (
        bldr "$2" ${@:3}
    ) || (
        buildah from --pull-always --name $2 $1
        bldr $2 ${@:3}
    )
}

bldalp () {  # [cname]
    bldr ${1:-alpine-scratch} apk upgrade
    bld copy ${1:-alpine-scratch} ~/.*zshrc /root/
    bldr ${1:-alpine-scratch}
}
