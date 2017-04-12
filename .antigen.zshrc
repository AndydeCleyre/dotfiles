export ZSH_CACHE_DIR="$HOME/.cache/zsh"
mkdir -p "$ZSH_CACHE_DIR"
. /usr/share/zsh/share/antigen.zsh
antigen bundle aws
antigen bundle colored-man-pages
antigen bundle docker
antigen bundle extract
antigen bundle fasd; alias j="fasd_cd -d"
antigen bundle git
antigen bundle git-flow-avh
antigen bundle mercurial
antigen bundle nmap
antigen bundle pip
antigen bundle rsync  # rsync-{copy,move,synchronize,update}
antigen bundle systemd  # sc-{start,stop,status,restart} [service]
antigen bundle zsh-users/zsh-completions src
antigen bundle zsh-users/zsh-syntax-highlighting
setopt promptsubst
# antigen theme avit  # minimal
antigen theme ~/Code dpoggi-andy
antigen apply
