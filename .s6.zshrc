DRUDGEHOUSE="$HOME/s6-services"
DUPWAIT=.5
DDOWNWAIT=2


drudge_status () {
    if [[ $# -eq 0 ]]; then
        set -- $(for svc in "$DRUDGEHOUSE"/*; do basename "$svc"; done)
    fi
    s6-svscanctl "$DRUDGEHOUSE" &> /dev/null
    if [[ $? -eq 100 ]]; then
        echo "$DRUDGEHOUSE not currently supervised."
        echo "Supervision can be started by running dstart (same as drudgery_start)."
    fi
    local drudge
    for drudge in "$@"; do
        dstatus="$(s6-svstat $DRUDGEHOUSE/$drudge 2> /dev/null)"
        [[ $? -eq 1 ]] && dstatus="unsupervised"
        echo "$drudge \t$dstatus"
    done
}

drudgery_start () {
    if [[ $# -gt 0 ]]; then
        echo "This command takes no arguments! Abort!"
    else
        s6-svscan "$DRUDGEHOUSE" &> /dev/null &
        disown
        sleep $DUPWAIT
        drudge_status
    fi
}

drudgery_stop () {
    if [[ $# -gt 0 ]]; then
        echo "This command takes no arguments! Abort!"
    else
        s6-svscanctl -an7 "$DRUDGEHOUSE"
    fi
}

drudge_up () {
    if [[ $# -eq 0 ]]; then
        echo "Please specify a service, by name."
    else
        local drudge
        for drudge in "$@"; do
            s6-svc -u "$DRUDGEHOUSE/$drudge" && sleep $DUPWAIT
            drudge_status "$drudge"
        done
    fi
}

drudge_down () {
    if [[ $# -eq 0 ]]; then
        echo "Please specify a service, by name."
    else
        local drudge
        for drudge in "$@"; do
            s6-svc -d "$DRUDGEHOUSE/$drudge" && sleep $DDOWNWAIT
            drudge_status "$drudge"
        done
    fi
}

drudge_sync () {
    if [[ $# -eq 0 ]]; then
        s6-svscanctl -an "$DRUDGEHOUSE"
        set -- $(for svc in "$DRUDGEHOUSE"/*; do basename "$svc"; done)
    fi
    local drudge
    for drudge in "$@"; do
        if [[ -f "$DRUDGEHOUSE/$drudge/down" ]]; then
            s6-svc -d "$DRUDGEHOUSE/$drudge" && sleep $DDOWNWAIT
        else
            s6-svc -u "$DRUDGEHOUSE/$drudge" && sleep $DUPWAIT
        fi
        drudge_status "$drudge"
    done
}

drudge_enable () {
    if [[ $# -eq 0 ]]; then
        echo "Please specify a service, by name."
    else
        local drudge
        for drudge in "$@"; do
            rm -f "$DRUDGEHOUSE/$drudge/down"
            drudge_status "$drudge"
        done
    fi
}

drudge_disable () {
    if [[ $# -eq 0 ]]; then
        echo "Please specify a service, by name."
    else
        local drudge
        for drudge in "$@"; do
            touch "$DRUDGEHOUSE/$drudge/down"
            drudge_status "$drudge"
        done
    fi
}

alias drudgery_status="drudge_status"
alias drudgery_sync="drudge_sync"
alias dstatus="drudge_status"
alias dstart="drudgery_start"
alias dstop="drudgery_stop"
alias dup="drudge_up"
alias ddown="drudge_down"
alias dsync="drudge_sync"
alias denable="drudge_enable"
alias ddisable="drudge_disable"

_drudgery_complete() { reply=( "${(ps:\n:)$(ls $DRUDGEHOUSE)}" ) }
compctl -K _drudgery_complete drudge_status drudge_up drudge_down drudge_sync drudge_enable drudge_disable
