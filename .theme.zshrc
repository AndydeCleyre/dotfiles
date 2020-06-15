setopt promptsubst

local retcode="%(?..%F{red}%? <-%f)"
local user="%(!.%F{red}%n%f.%n)"
local console=${${TMUX_PANE:+$(tmux display-message -p '#I')}:-tty${TTY##*/}}
local distro=$(head -n 1 /etc/os-release | cut -d '"' -f 2) 2> /dev/null

function git_prompt_info() {
    local gitref=${$(git branch --show-current 2>/dev/null):-$(git rev-parse --short HEAD 2>/dev/null)}
    local gitroot=$(git rev-parse --show-toplevel 2>/dev/null)
    gitroot=${${$(realpath --relative-to=. $gitroot 2>/dev/null):#.}:#$PWD}
    print -P "%F{magenta}${gitroot}%F{white}${gitroot:+:}%F{blue}${gitref}%F{red}${$(git status --porcelain 2> /dev/null):+*}%f"
}

PROMPT='\
%F{green}%U${retcode}%u${$(print -P $retcode):+ }\
%F{green}%U${user}%u \
%F{white}%U%m%u \
%F{white}%U${console}%u \
%B%F{magenta}%U%~%u%b \
%U$(git_prompt_info)%u${$(git rev-parse HEAD 2> /dev/null):+ }\
%F{green}%U%D{%L:%M:%S}%u
%B%F{white}%(!.#.>>)%f%b '
PROMPT2='%B%F{red}……%f%b '
[[ $distro = "Arch Linux" ]] || RPROMPT="%F{white}${distro}%f"
