alias bld="sudo buildah"
alias bldc="sudo buildah containers"
alias bldi="sudo buildah images"
bldalpine () {
    sudo buildah run alpine-working-container sh || (
        sudo buildah from alpine && sudo buildah run alpine-working-container sh
    )
}
bldarch () {
    sudo buildah run archlinux-working-container sh || (
        sudo buildah from base/archlinux && sudo buildah run archlinux-working-container sh
    )
}
