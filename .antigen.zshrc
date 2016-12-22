. /usr/share/zsh/scripts/antigen/antigen.zsh
antigen use oh-my-zsh
antigen bundle docker
antigen bundle extract
antigen bundle fasd; alias j="fasd_cd -d"
antigen bundle git
antigen bundle git-flow-avh
antigen bundle mercurial
antigen bundle nmap
antigen bundle pip
antigen bundle rsync  # rsync-{copy,move,synchronize,update}
antigen bundle supervisor
antigen bundle systemd  # sc-{start,stop,status,restart} [service]
antigen bundle zsh-users/zsh-completions src
antigen bundle zsh-users/zsh-syntax-highlighting
antigen apply
# antigen theme dpoggi
# antigen theme avit  # minimal
# antigen theme desyncr/zshrc themes/af-magic-mod
antigen theme ~/Code dpoggi-andy
