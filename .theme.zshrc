setopt promptsubst

local ZSH_THEME_USER="%(!.%F{red}.%F{green})%n%f"
local ZSH_THEME_HOST="%F{cyan}%m%f"
local ZSH_THEME_CONSOLE
if [[ -n $TMUX_PANE ]]; then
    ZSH_THEME_CONSOLE="%F{cyan}$(tmux display-message -p '#I')%f"
else
    ZSH_THEME_CONSOLE="%F{cyan}tty$(echo $TTY | egrep -o '\w+$')%f"
fi
local ZSH_THEME_CWD="%F{magenta}%~%f"
local ZSH_THEME_RETURN="%(?..%F{red}%? <- )%(?.%F{green}.)%*%f"

local ZSH_THEME_GIT_PROMPT_PREFIX="(%F{blue}"
local ZSH_THEME_GIT_PROMPT_SUFFIX="%f)"
local ZSH_THEME_GIT_PROMPT_CLEAN=""
local ZSH_THEME_GIT_PROMPT_DIRTY="%F{red}*%f"

function git_prompt_info() {
    local ref
    ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
    echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

function parse_git_dirty() {
    local STATUS=$(command git status --porcelain 2> /dev/null | tail -n1)
    if [[ -n $STATUS ]]; then
        echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
    else
        echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
    fi
}

PROMPT='${ZSH_THEME_USER}@${ZSH_THEME_HOST}.${ZSH_THEME_CONSOLE}:${ZSH_THEME_CWD}$(git_prompt_info)
%F{red}%(!.#.⣿)%f '
PROMPT2='%F{red}\ %f'
RPROMPT='${ZSH_THEME_RETURN}'
