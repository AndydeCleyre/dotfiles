#!/bin/zsh
mullvad_status () {
    local mullvad_status=$(mullvad status)
    local is_connected=
    if [[ $mullvad_status =~ '.*: Connected to WireGuard .*' ]]; then
        is_connected=1
    fi
    if [[ $1 == --click ]]; then
        if [[ $is_connected ]]; then
            mullvad disconnect
        else
            mullvad connect
        fi
        sleep 1
        notify-send -a Mullvad -i mullvad-vpn "VPN Connection" "$(mullvad status -l)"
    elif [[ $is_connected ]]; then
        print '<font color="#709d3d"></font>'
    else
        # print '<font color="#e64976"></font>'
        print ''
    fi
}
mullvad_status $@
