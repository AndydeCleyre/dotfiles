alias bld="buildah"
alias bldc="buildah containers"
alias bldi="buildah images"
bldrun () {  # iname cname cmd
    buildah inspect $2 &> /dev/null
    if [ $? -eq 0 ]; then
        buildah run "$2" ${@:3}
    else
        buildah pull $1
        buildah from --name $2 $1
        buildah run $2 ${@:3}
    fi
}

bldalpine () {
    bldrun alpine:edge ${1:-alpine-scratch} apk upgrade
    buildah config --env "TERM=xterm" ${1:-alpine-scratch}
    buildah run ${1:-alpine-scratch} sh
}
