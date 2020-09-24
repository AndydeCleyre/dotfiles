() {
    local usual_distro='Arch Linux' usual_host='Ingram' usual_user='andy'

    local agkozakpath=~/Code/plugins/zsh/agkozak-zsh-prompt/agkozak-zsh-prompt.plugin.zsh
    local p10kpath=~/Code/plugins/zsh/powerlevel10k/powerlevel10k.zsh-theme

    # comment one to *enable* it, or *neither* to use the fallback theme defined below:
    # agkozakpath=/DISABLED
    p10kpath=/DISABLED

    if [[ -r $agkozakpath ]]; then
        [[ ! ${HOST:#$usual_host} && ! ${USERNAME:#$usual_user} ]]
        AGKOZAK_USER_HOST_DISPLAY=$?
        AGKOZAK_LEFT_PROMPT_ONLY=1
        AGKOZAK_PROMPT_CHAR=('%F{white}%B->%b%f' '#' ':')
        AGKOZAK_PROMPT_DIRTRIM=4
        AGKOZAK_CUSTOM_SYMBOLS=('⇣⇡' '⇣' '⇡' '+' 'x' '!' '>' '?' 'S')
        . $agkozakpath
    elif [[ -r $p10kpath ]]; then
        . ~/.cache/p10k-instant-prompt-$USERNAME.zsh 2>/dev/null
        . $p10kpath
        . ~/.p10k.zsh 2>/dev/null
        POWERLEVEL9K_VIRTUALENV_GENERIC_NAMES=()
        POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status context dir vcs pyenv virtualenv background_jobs vpn_ip command_execution_time newline prompt_char)
        POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
        POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION='%B->%b'
        POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION='%B->%b'
        POWERLEVEL9K_SHORTEN_DELIMITER=…
        POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=3
        POWERLEVEL9K_DIR_MAX_LENGTH=80
        POWERLEVEL9K_STATUS_ERROR=true
        POWERLEVEL9K_VIRTUALENV_FOREGROUND=5
        POWERLEVEL9K_PYENV_FOREGROUND=5
        POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=true
        POWERLEVEL9K_VIRTUALENV_SHOW_WITH_PYENV=true
        POWERLEVEL9K_TIME_FORMAT='%D{%L:%M:%S}'
        POWERLEVEL9K_VPN_IP_FOREGROUND=2
        POWERLEVEL9K_VPN_IP_VISUAL_IDENTIFIER_EXPANSION=
    else
        setopt promptsubst
        local distro line segments=() right_segments=()

        read line </etc/os-release
        distro=${${line#*\"}%\"*}
        [[ $distro   == $usual_distro ]] || right_segments+="%F{white}${distro}%f"
        [[ $HOST     == $usual_host   ]] || right_segments+='%F{blue}%m%f'
        [[ $USERNAME == $usual_user   ]] || right_segments+='%(!.%F{red}%n%f.%F{green}%n%f)'
        RPROMPT=${(j: | :)right_segments}

        git_prompt_info () {
            local gitref=${$(git branch --show-current 2>/dev/null):-$(git rev-parse --short HEAD 2>/dev/null)}
            local gitroot=$(git rev-parse --show-toplevel 2>/dev/null)
            gitroot=${$(realpath --relative-to=. $gitroot 2>/dev/null):#(.|$PWD)}
            print -rP -- "%F{magenta}${gitroot}%F{white}${gitroot:+:}%F{blue}${gitref}%F{red}${$(git status --porcelain 2>/dev/null):+*}%f"
        }

        segments+='%(?..%U%F{red}%? <-%f%u )'                                      # retcode if non-zero
        segments+='%F{white}%U${${TMUX_PANE:+:}%u%f'                               # tmux indicator
        segments+='%F{white}%U${TTY##*/}%u%f '                                     # TTY number
        segments+='%B%F{magenta}%U%~%u%f%b '                                       # folder
        segments+='%U$(git_prompt_info)%u${$(git rev-parse HEAD 2>/dev/null):+ }'  # git info
        segments+='%F{green}%U%D{%L:%M:%S}%u%f'                                    # time
        segments+='%B%F{white}%(!.'$'\n''#.'$'\n''->)%f%b '                        # prompt symbol
        PROMPT=${(j::)segments}
    fi
}

PROMPT2='%B%F{yellow}……%f%b '
