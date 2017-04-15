autoload -U colors && colors

ZSH_THEME_USER="%(!.%{$fg[red]%}.%{$fg[green]%})%n%{$reset_color%}"
ZSH_THEME_HOST="%{$fg[cyan]%}%m%{$reset_color%}"
if [[ -n $TMUX_PANE ]]; then
    ZSH_THEME_CONSOLE="%{$fg[cyan]%}$(tmux display-message -p '#I')%{$reset_color%}"
else
    ZSH_THEME_CONSOLE="%{$fg[cyan]%}tty$(echo $TTY | egrep -o '\w+$')%{$reset_color%}"
fi
ZSH_THEME_CWD="%{$fg[magenta]%}%~%{$reset_color%}"
ZSH_THEME_RETURN="%(?..%{$fg[red]%}%? <- )%(?.%{$fg[green]%}.)%*%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_PREFIX="(%{$fg[blue]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%})"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}*%{$reset_color%}"

# copied from oh-my-zsh's git lib: ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ #
function git_prompt_info() {
    local ref
    if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" != "1" ]]; then
        ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
        ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
        echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
    fi
}

function parse_git_dirty() {
    local STATUS=''
    local FLAGS
    FLAGS=('--porcelain')
    if [[ "$(command git config --get oh-my-zsh.hide-dirty)" != "1" ]]; then
        if [[ $POST_1_7_2_GIT -gt 0 ]]; then
            FLAGS+='--ignore-submodules=dirty'
        fi
        if [[ "$DISABLE_UNTRACKED_FILES_DIRTY" == "true" ]]; then
            FLAGS+='--untracked-files=no'
        fi
        STATUS=$(command git status ${FLAGS} 2> /dev/null | tail -n1)
    fi
    if [[ -n $STATUS ]]; then
        echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
    else
        echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
    fi
}
# ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ #

PROMPT='${ZSH_THEME_USER}@${ZSH_THEME_HOST}.${ZSH_THEME_CONSOLE}:${ZSH_THEME_CWD}$(git_prompt_info)
%{$fg[red]%}%(!.#.⣿)%{$reset_color%} '
PROMPT2='%{$fg[red]%}\ %{$reset_color%}'
RPROMPT='${ZSH_THEME_RETURN}'
