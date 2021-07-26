#!/bin/zsh
# connected_color=$(python3 -c "print(''.join(hex(int(i))[2:] for i in '$(kreadconfig5 --group Colors:Button --key ForegroundPositive)'.split(',')))")
connected_color=$(python3 -c "print(''.join(hex(int(i))[2:] for i in '$(kreadconfig5 --group Colors:Button --key ForegroundActive)'.split(',')))")
mullvad_status () {
    local mullvad_status=$(mullvad status)
    local is_connected=
    if [[ $mullvad_status =~ '.*: Connected to (WireGuard|OpenVPN) .*' ]] is_connected=1
    if [[ $1 == --click ]] {
        if [[ $is_connected ]] {
            mullvad disconnect
        } else {
            mullvad connect
        }
        sleep 1
        notify-send -a Mullvad -i mullvad-vpn "VPN Connection" "$(mullvad status -l)"
    } elif [[ $is_connected ]] {
        print "<font color=\"#${connected_color}\"></font>"
    } else {
        print ''
    }
}
mullvad_status $@
