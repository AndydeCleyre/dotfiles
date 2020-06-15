alias sussex="sudo essex -d /var/svcs"
alias tin="s6-tai64n"
alias tout="s6-tai64nlocal"
_essex () {
    local cmds=(cat disable enable list log new off on pid print pt reload sig start status stop sync tree upgrade)
    local svc_cmds=(cat disable enable log pid print reload sig start status stop sync upgrade)
    local sigs=(alrm abrt quit hup kill term int usr1 usr2 stop cont winch)
    local folder_options=(-d --directory -l --logs-directory)
    local svcs_dir=$HOME/svcs
    local cmd_idx=2
    # TODO: properly handle options/subcmds (differently, and with menu-descriptions)...
    # TODO: maybe template this as a file with pyratemp
    # TODO: add more completions, obviously
    # TODO: _normal for cmd
    # TODO: e.g. stop fumbles over newline-"excludes..."
    while (( ${folder_options[(I)${words[cmd_idx]}]} )); do
        cmd_idx=$(( cmd_idx+2 ))
    done
    if (( ${svc_cmds[(I)${words[$cmd_idx]}]} )); then
        local subcmd=${words[$cmd_idx]}
        if [[ $subcmd == sig ]]; then
            _arguments \
                "$(( cmd_idx-1 )):Commands:($cmds)" \
                "$cmd_idx:Signals:($sigs)" \
                "*:Services:($svcs_dir/[^.]*(/:t))"
        else
            _arguments \
                "$(( cmd_idx-1 )):Commands:($cmds)" \
                "*:Services:($svcs_dir/[^.]*(/:t))"
        fi
        _message "$(
            essex $subcmd --help \
            | tail -n +3 \
            | grep -Ev '^Meta-switches:|^Usage:|^\s+(-|excludes -)|^$'
        )"
    else
        _arguments \
            "1:Commands:($cmds)"
    fi
}
compdef _essex essex 2>/dev/null
