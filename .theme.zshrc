setopt promptsubst

local retcode="%(?..%F{red}%? <- )"
local user="%(!.%F{red}.%F{green})%n%f"
local host="%F{cyan}%m%f"
if [[ $TMUX_PANE ]]; then
    local console="%F{cyan}$(tmux display-message -p '#I')%f"
else
    local console="%F{cyan}tty$(echo $TTY | grep -E -o '\w+$')%f"
fi
local cwd="%F{magenta}%~%f"
local clock="%F{green}%*%f"

function git_prompt_info() {
    local gitref=$(git symbolic-ref HEAD 2> /dev/null)
    [[ $gitref ]] || gitref=$(git rev-parse --short HEAD 2> /dev/null)
    [[ $gitref ]] && gitref="%F{blue}${gitref#refs/heads/}%f"
    if [[ $gitref ]]; then
        local gitroot=$(git rev-parse --show-toplevel 2> /dev/null)
        [[ $gitroot ]] && gitroot=$(realpath --relative-to=. $gitroot 2> /dev/null)
        gitroot="${gitroot:#.}"
        [[ $gitroot ]] && gitroot="${gitroot}:"

        local gitdirty=$(git status --porcelain 2> /dev/null | tail -n1)
        [[ $gitdirty ]] && gitdirty="%F{red}*%f"

        local gitinfo=" ${gitroot}${gitref}${gitdirty} "
        echo "${gitinfo:/  / }"
    else
        echo " "
    fi
}

PROMPT='%U${retcode}${user}@${host}.${console}:${cwd}$(git_prompt_info)${clock}%u
%F{magenta}%(!.#.$)%f '
PROMPT2='%F{red}… %f'
