() {
  emulate -L zsh
  for 1 ( start stop restart enable disable mask daemon-reload ) alias sc-$1="sudo systemctl $1"
  # TODO: is this needed anymore, or does systemctl assist in priv elevation?
}
alias sc-status="systemctl status"
alias scu="systemctl --user"
# alias sc-list-enabled="systemctl list-unit-files --no-pager | grep enabled"
alias sc-list-enabled="jc systemctl list-unit-files | yaml-get -p '.[state = enabled].unit_file'"
