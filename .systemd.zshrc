for cmd in start stop restart; do
  alias sc-$cmd="sudo systemctl $cmd"
done
alias sc-dr="sudo systemctl daemon-reload"
alias sc-status="systemctl status"
alias sc-list-enabled="systemctl list-unit-files --no-pager | grep enabled"
alias scu="systemctl --user"

