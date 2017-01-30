alias spacman="sudo pacman"
alias update-mirrors="sudo reflector --save /etc/pacman.d/mirrorlist --sort score --country 'United States' --country 'Canada' --latest 30 -p http"
alias y="yaourt"

export AURUPGRADE=1
export EDITFILES=0
export DIFFEDITCMD="sudo -u $USER SUDO_EDITOR=meld sudoedit"
