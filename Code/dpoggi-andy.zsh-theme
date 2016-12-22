if [ $UID -eq 0 ]; then NCOLOR="red"; else NCOLOR="green"; fi
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

NTTY=$(echo $TTY | egrep -o "\w+$")
time="%(?.%{$fg[green]%}.%{$fg[red]%})%*%{$reset_color%}"
PROMPT='%{$fg[$NCOLOR]%}%n%{$reset_color%}@%{$fg[cyan]%}%m\
%{$reset_color%}.\
%{$fg[cyan]%}$NTTY\
%{$reset_color%}:%{$fg[magenta]%}%~\
$(git_prompt_info)
%{$fg[red]%}%(!.#.»)%{$reset_color%} '
PROMPT2='%{$fg[red]%}\ %{$reset_color%}'
RPS1='${return_code}'
RPROMPT='${time}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}(%{$fg[blue]%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}*%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%})"
