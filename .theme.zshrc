setopt promptsubst

() {
  emulate -L zsh

  local usual_distro='Arch Linux' usual_host='Ingram' usual_user='andy'
  # local ptime='%D{%L:%M}'
  local ptime='$(dt)'  # dozenal time

  local agkozakpath p10kpath
  agkozakpath=~/Code/plugins/zsh/agkozak-zsh-prompt/agkozak-zsh-prompt.plugin.zsh
  p10kpath=~/Code/plugins/zsh/powerlevel10k/powerlevel10k.zsh-theme

  if [[ -r $agkozakpath ]] {
    if [[ $HOST != $usual_host || $USERNAME != $usual_user ]] {
      AGKOZAK_USER_HOST_DISPLAY=1
    } else {
      AGKOZAK_USER_HOST_DISPLAY=0
    }
    AGKOZAK_CUSTOM_SYMBOLS=('⇣⇡' '⇣' '⇡' '+' 'x' '!' '>' '?' 'S')
    AGKOZAK_LEFT_PROMPT_ONLY=1
    AGKOZAK_PROMPT_CHAR=('%F{white}%B->>%b%f' '#' ':')
    AGKOZAK_PROMPT_DIRTRIM=4
    AGKOZAK_PROMPT_DIRTRIM_STRING=…
    # if (( $+commands[tmux] )) {
    if [[ $TMUX ]] && [[ $TMUX != *tmate* ]] {
      AGKOZAK_CUSTOM_RPROMPT='${(j: :)${(f)"$(tmux lsw -F "#{?#{==:#{pane_tty},$TTY},%B%F{white#},%F{blue#}}#{?#{!=:#W,zsh},#W,%%}#{?#{!=:#{window_panes},1},+,}%f%b" 2>/dev/null)"}} %F{green}'$ptime'%f'
    } else {
      AGKOZAK_CUSTOM_RPROMPT='%F{green}'$ptime'%f'
    }

    . $agkozakpath

  } elif [[ -r $p10kpath ]] {

    # Plop one of these at the end of .zshrc:
    # if (( ${+functions[p10k]} )) p10k finalize

    if [[ -r ~/.cache/p10k-instant-prompt-$USERNAME.zsh ]] . ~/.cache/p10k-instant-prompt-$USERNAME.zsh
    . $p10kpath
    if [[ -r ~/.p10k.zsh ]] . ~/.p10k.zsh

    POWERLEVEL9K_DIR_MAX_LENGTH=80
    POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=3
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status context dir vcs pyenv virtualenv background_jobs vpn_ip command_execution_time newline prompt_char)
    POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION='%B->>%b'
    POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION='%B->>%b'
    POWERLEVEL9K_PYENV_FOREGROUND=5
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(time)
    POWERLEVEL9K_SHORTEN_DELIMITER=…
    POWERLEVEL9K_STATUS_ERROR=true
    POWERLEVEL9K_TIME_FORMAT='%D{%L:%M}'
    POWERLEVEL9K_TRANSIENT_PROMPT=off
    POWERLEVEL9K_VIRTUALENV_FOREGROUND=5
    POWERLEVEL9K_VIRTUALENV_GENERIC_NAMES=()
    POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=true
    POWERLEVEL9K_VIRTUALENV_SHOW_WITH_PYENV=true
    POWERLEVEL9K_VPN_IP_FOREGROUND=2
    POWERLEVEL9K_VPN_IP_VISUAL_IDENTIFIER_EXPANSION=

  } else {
    local distro line
    read line </etc/os-release
    distro=${${${line#*=}#*\"}%\"*}

    local right_segments=()
    if [[ $distro   != $usual_distro ]] right_segments+=("%F{white}${distro}%f")
    if [[ $HOST     != $usual_host   ]] right_segments+=('%F{blue}%m%f')
    if [[ $USERNAME != $usual_user   ]] right_segments+=('%(!.%F{red}%n%f.%F{green}%n%f)')
    # if (( $+commands[tmux] )) {
    if [[ $TMUX ]] && [[ $TMUX != *tmate* ]] {
      right_segments+=('${(j: :)${(f)"$(tmux lsw -F "#{?#{==:#{pane_tty},$TTY},%B%F{white#},%F{blue#}}#{?#{!=:#W,zsh},#W,%%}#{?#{!=:#{window_panes},1},+,}%f%b" 2>/dev/null)"}}')
    }
    right_segments+=('%F{green}'$ptime'%f')

    RPROMPT=${(j: | :)right_segments}

    git_prompt_info () {
      local gitref=${$(git branch --show-current 2>/dev/null):-$(git rev-parse --short HEAD 2>/dev/null)}
      local gitroot=$(git rev-parse --show-toplevel 2>/dev/null)
      gitroot=${$(realpath --relative-to=. $gitroot 2>/dev/null):#(.|$PWD)}
      print -rP -- "%F{magenta}${gitroot}%F{white}${gitroot:+:}%F{blue}${gitref}%F{red}${$(git status --porcelain 2>/dev/null):+*}%f"
    }
    # TODO: use vcs_info module?

    local segments=()
    # segments+='%(?..%U%F{red}%? <-%f%u )'                                          # retcode if non-zero
    # segments+='${${pipestatus#0}:+%U%F{red\}${(j:%f|%F{red\}:)pipestatus} <-%f%u }'  # retcodes if non-zero
    segments+='${${pipestatus#0}:+%U%F{red\}${(j:|:)pipestatus} <-%f%u }'  # retcodes if non-zero
    segments+='%B%F{magenta}%U%~%u%f%b '                                             # folder
    segments+='%U$(git_prompt_info)%u${$(git rev-parse HEAD 2>/dev/null):+ }'        # git info
    segments+='%B%F{white}%(!.'$'\n''#.'$'\n''->>)%f%b '                             # prompt symbol

    PROMPT=${(j::)segments}
  }
}

PROMPT2='%B%F{blue}->…%f%b '

dt () {
  emulate -L zsh

  local h_m=(${(s: :)${(%):-%D{%L %M}}})

  local hour=${h_m[1]:s/10/Ŧ/:s/11/Ł/:s/12/0/}
  local -i minute=${h_m[2]}

  local fivers="${$(( minute/5 )):s/10/Ŧ/:s/11/Ł/}"
  local spillover="${$(( minute%5 )):/0}"

  print -r -- "${hour}.${fivers}${spillover:+:}${spillover}"
}
