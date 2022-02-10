alias bld="buildah"
alias bldc="buildah containers"
alias bldi="buildah images"
alias docker="podman"

bldi-rmnone () { buildah rmi $(buildah images -f dangling=true --format '{{.ID}}') }

bldimg () {
  emulate -L zsh

  local data=$(mktemp)
  trap "rm -rf ${(q-)data}" EXIT INT QUIT
  buildah images --json >"$data"

  local image_ids
  image_ids=($(yaml-get -p .id "$data"))

  local rows=() row=() img_id
  local -U names=()
  for img_id ( $image_ids ) {
    IFS=${IFS}:
    names=(${=$(buildah images --json | yaml-get -p "[id=$img_id].names.*")})
    IFS=$IFS[1,-2]
    # row=(
    #   "$img_id"
    #   "$(yaml-get -p "[id=$img_id].createdat" "$data")"
    #   "$(yaml-get -p "[id=$img_id].size" "$data")"
    #   "${(j. :: .)names}"
    # )
    row=(
      "${names[1]}"
      "$img_id"
      "$(yaml-get -p "[id=$img_id].createdat" "$data")"
      "$(yaml-get -p "[id=$img_id].size" "$data")"
      "[${(j:, :)names[2,-1]}]"
    )
    rows+=("${(j. | .)row}")
  }

  # print -rn -- "${$(<<<${(F)rows} fzf --reverse -m -0)%% *}"
  <<<${(F)rows} fzf --reverse -m -0 | cut -d ' ' -f 3
}


# --- #

# If ctnr <cname> exists, do nothing. Otherwise create it from <iname>.
.buildah_require_ctnr () {  # <cname> [iname=alpine:3.11]
    buildah inspect $1 &>/dev/null \
    || buildah from --name $1 ${2:-alpine:3.11}
}

# Interactively select a local ctnr, printing its name.
.buildah_pick_ctnr () {
    setopt localoptions extendedglob
    print -rn "${$(
        buildah containers --format '{{.ContainerName}} :: {{.ImageName}}' \
        | fzf --reverse -0 -1
    )%% ##:: *}"
    # )% :: *}"  # https://github.com/containers/buildah/issues/2016
}

# Interactively select a local image, printing its name.
.buildah_pick_img () {
    # print -rn "${$(buildah images --format '{{.Name}} :: {{.Tag}} :: {{.Size}} :: {{.ID}}' | fzf --reverse -0 -1
    setopt localoptions extendedglob
    print -rn "${$(
        buildah images --format '{{.Name}} :: {{.Tag}} :: {{.ID}} :: {{.Size}} :: {{.CreatedAt}}' \
        | fzf --reverse -0 -1
    )%% ##:: *}"
    # )% :: *}"  # https://github.com/containers/buildah/issues/2016
}

# Interactively select a shell available within a local ctnr <cname>, printing its path.
.buildah_pick_ctnr_shell () {  # <cname>
    print -rn "$(
        buildah run $1 grep -E -v '^(#|$)' /etc/shells \
        | fzf --reverse -0 -1
    )"
}

# Interactively select a user available within a local ctnr <cname>, printing its name.
.buildah_pick_ctnr_user () {  # <cname>
    print -rn "${$(
        bldr $1 grep -E '^root:|:/home/' /etc/passwd \
        | fzf --reverse -0 -1
    )%%:*}"
}

# buildah_bldr () {  # [cname [cmd]]
    # if [[ "$#" -eq 0 ]]; then
        # local ctnr=$(.buildah_pick_ctnr)
        # [[ $ctnr ]] || return 1
        # bldr $ctnr
    # else
        # .buildah_require_ctnr $1
        # buildah config --env TERM=xterm-256color $1
        # buildah run -t $1 ${${@:2}:-$(.buildah_pick_ctnr_shell $1)}
    # fi
# }

# TODO: combine, group 1

# Run <cmd> (or an interactively selected shell) within ctnr <cname>.
# With no arguments, interactively choose a local ctnr and shell within to run.
# If <cname> doesn't exist locally, create it from alpine:3 first.
bldr () {  # [cname [cmd]]
    if [[ "$#" -eq 0 ]]; then
        local ctnr=$(.buildah_pick_ctnr)
        [[ $ctnr ]] || return 1
        bldr $ctnr
    else
        .buildah_require_ctnr $1
        buildah config --env TERM=xterm-256color $1
        buildah run -t $1 ${${@:2}:-$(.buildah_pick_ctnr_shell $1)}
    fi
}

# TODO: combine, group 1
# Like bldr, but as ctnr-user <user>.
bldru () {  # <user> [cname [cmd]]
    if [[ "$#" -eq 1 ]]; then
        local ctnr=$(.buildah_pick_ctnr)
        [[ $ctnr ]] || return 1
        bldru $1 $ctnr
    else
        .buildah_require_ctnr $2
        buildah config --env TERM=xterm-256color $2
        buildah run --user $1 -t $2 ${${@:3}:-$(.buildah_pick_ctnr_shell $2)}
    fi
}

# TODO: combine, group 1
# Like bldr, but interactively select a ctnr-user to run as.
ubldr () {  # [cname [cmd]]
    if [[ "$#" -eq 0 ]]; then
        local ctnr=$(.buildah_pick_ctnr)
        [[ $ctnr ]] || return 1
        ubldr $ctnr
    else
        .buildah_require_ctnr $1
        buildah config --env TERM=xterm-256color $1
        bldru $(.buildah_pick_ctnr_user $1) $1 ${${@:2}:-$(.buildah_pick_ctnr_shell $1)}
    fi
}

bldrfrom () {  # [iname [cname=<iname>-scratch [cmd]]]
    local iname=${1:-$(.buildah_pick_img)}
    [[ $iname ]] || return 1
    local ctnr=${2:-${iname//:/-}-scratch}
    .buildah_require_ctnr $ctnr $iname
    bldr $ctnr ${@:3}
}

bldalp () {  # [cname=alpine-scratch [(zulu|prezto|addme|zshrc|testing)...]
    local ctnr=${1:-alpine-scratch}
    local addons=${@:2}
    .buildah_require_ctnr $ctnr
    if [[ ${#addons} -gt 0 ]]; then
       if [[ ${addons[(ie)addme]} -le ${#addons} ]]; then
            bldr $ctnr apk add sudo
            bldr $ctnr adduser -G wheel -D $USER
            bldr $ctnr sh -c 'echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/buildah'
        fi
       if [[ ${addons[(ie)zulu]} -le ${#addons} ]]; then
            bldr $ctnr apk add git zsh ncurses
           if [[ ${addons[(ie)addme]} -le ${#addons} ]]; then
                bldru $USER $ctnr zsh -c 'wget -O - https://zulu.molovo.co/install | zsh'
                bldru $USER $ctnr zsh -ic 'zulu config set analytics false'
            else
                bldr $ctnr zsh -c 'wget -O - https://zulu.molovo.co/install | zsh'
                bldr $ctnr zsh -ic 'zulu config set analytics false'
            fi
        fi
       if [[ ${addons[(ie)prezto]} -le ${#addons} ]]; then
            bldr $ctnr apk add git zsh coreutils
           if [[ ${addons[(ie)addme]} -le ${#addons} ]]; then
                bldru $USER $ctnr git clone --recursive https://github.com/sorin-ionescu/prezto.git /home/$USER/.zprezto
                bldru $USER $ctnr zsh -c "for rcfile in /home/$USER/.zprezto/runcoms/z*; do ln -s \$rcfile /home/$USER/.\${rcfile:t}; done"
                bldru $USER $ctnr rm -rf /home/$USER/.zprezto/.git

                bldru $USER $ctnr sh -c "echo \"precmd () { rehash }\" >> /home/$USER/.zshrc"
            else
                bldr $ctnr git clone --recursive https://github.com/sorin-ionescu/prezto.git /root/.zprezto
                bldr $ctnr zsh -c 'for rcfile in /root/.zprezto/runcoms/z*; do ln -s $rcfile /root/.${rcfile:t}; done'
                bldr $ctnr rm -rf /root/.zprezto/.git

                bldr $ctnr sh -c "echo \"precmd () { rehash }\" >> /root/.zshrc"
            fi
        fi
       if [[ ${addons[(ie)zshrc]} -le ${#addons} ]]; then
            bldr $ctnr apk add zsh
            buildah copy $ctnr ~/.*zshrc /root/
           if [[ ${addons[(ie)addme]} -le ${#addons} ]]; then
                buildah copy --chown $USER $ctnr ~/.*zshrc /home/$USER/
            fi
        fi
       if [[ ${addons[(ie)testing]} -le ${#addons} ]]; then
            bldr $ctnr sh -c 'echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories'
            bldr $ctnr apk update
        fi
        [[ ${addons[(ie)addme]} -le ${#addons} ]] && buildah config --user $USER $ctnr
    fi
    bldr $ctnr
}

