setopt promptsubst

local retcode="%(?..%F{red}%? <-%f)"
local user="%(!.%F{red}%n%f.%n)"
local console=${${TMUX_PANE:+$(tmux display-message -p '#I')}:-term${TTY##*/}}
local distro=$(head -n 1 /etc/os-release | cut -d '"' -f 2) 2> /dev/null

function git_prompt_info() {
    local gitref=${${$(git symbolic-ref HEAD 2> /dev/null)#refs/heads/}:-$(git rev-parse --short HEAD 2> /dev/null)}
    local gitroot=$(git rev-parse --show-toplevel 2> /dev/null)
    gitroot=${$(realpath --relative-to=. $gitroot 2> /dev/null):#.}
    echo "%F{magenta}${gitroot}%F{cyan}${gitroot:+:}%F{blue}${gitref}%F{red}${$(git status --porcelain 2> /dev/null):+*}%f"
}

PROMPT='\
%F{green}%U${retcode}%u%f${$(print -P $retcode):+ }\
%F{green}%U${user}%u%f \
%F{cyan}%U%m%u%f \
%F{cyan}%U${console}%u%f \
%B%F{magenta}%U%~%u%f%b \
%U$(git_prompt_info)%u${$(git status 2> /dev/null):+ }\
%F{green}%U%*%u%f
%B%F{cyan}%(!.#.>)%f%b '
PROMPT2='%B%F{red}………%f%b '
[[ $distro = "Arch Linux" ]] || RPROMPT="%B%F{cyan}${distro}%f%b"
