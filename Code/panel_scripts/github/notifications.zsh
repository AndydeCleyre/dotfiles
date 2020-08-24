#!/bin/zsh
#      
if [[ $1 == --click ]]; then
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
    if [[ $resp[1] == default ]]; then
        xdg-open 'https://github.com/notifications?query=is%3Aunread'
    fi
else
    # message_count=$(gh api notifications | jq length)
    message_count=$(gh api notifications | jello 'len(_)')
    if (( message_count > 0 )); then
        print -r '<font color="#709d3d"></font>'
    else
        print -r '<font color="#c2b790"></font>'
    fi
fi
