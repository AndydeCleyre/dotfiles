#!/bin/zsh
#      
here="$0:P:h"
alert_color=$(python3 -c "print(''.join(hex(int(i))[2:] for i in '$(kreadconfig5 --group Colors:Button --key ForegroundActive)'.split(',')))")
# yaml-merge -m entries =(<<<'{"entries": []}') <sample.json
# data=$(gh api notifications | yaml-merge -m entries =(<<<'{"entries": []}'))

if [[ $1 == --click ]] {
    messages=(${(s:\n:)"$(
        gh api notifications \
        | jello -r '"\n".join(n["repository"]["name"] + ": " + n["subject"]["title"] for n in _)'
    )"})
    body=${(j:<br><br>:)messages}
    resp=(${(f)"$(
        notify-send.py -a GitHub -i github-desktop \
        "Notifications: ${#messages}" "$body" \
        --action default:Go
    )"})
    if [[ $resp[1] == default ]] xdg-open 'https://github.com/notifications?query=is%3Aunread'
} else {
    # tmpl=('@require(entries)' '@(count = len(entries))@count')
    # message_count=$(gh api notifications | jq length)
    message_count=$(gh api notifications | jello 'len(_)')
    # message_count=$(wheezy.template $here/count.wz gh api notifications | jello 'len(_)')
    if (( message_count > 0 )) {
        print -r "<font color=\"#${alert_color}\"></font>"
    } else {
        print -r ''
    }
}
