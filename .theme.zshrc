setopt promptsubst

() {
    local line
    read line </etc/os-release
    PROMPT_DISTRO=${${line#*\"}%\"*}
}

git_prompt_info () {
    local gitref=${$(git branch --show-current 2>/dev/null):-$(git rev-parse --short HEAD 2>/dev/null)}
    local gitroot=$(git rev-parse --show-toplevel 2>/dev/null)
    gitroot=${${$(realpath --relative-to=. $gitroot 2>/dev/null):#.}:#$PWD}
    print -rP -- "%F{magenta}${gitroot}%F{white}${gitroot:+:}%F{blue}${gitref}%F{red}${$(git status --porcelain 2> /dev/null):+*}%f"
}

PROMPT='\
%(?..%U%F{red}%? <-%f%u )\
%U%(!.%F{red}%n%f.%F{green}%n%f)%u \
%F{white}%U%m%u%f \
%F{white}%U${${TMUX_PANE:+$(tmux display-message -p "#I")}:-tty${TTY##*/}}%u%f \
%B%F{magenta}%U%~%u%f%b \
%U$(git_prompt_info)%u${$(git rev-parse HEAD 2> /dev/null):+ }\
%F{green}%U%D{%L:%M:%S}%u%f
%B%F{white}%(!.#.>>)%f%b '
PROMPT2='%B%F{red}……%f%b '
[[ $PROMPT_DISTRO == "Arch Linux" ]] || RPROMPT="%F{white}${PROMPT_DISTRO}%f"
