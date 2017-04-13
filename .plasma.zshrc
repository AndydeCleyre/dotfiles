fix-plasma () {
    mixer="/usr/share/plasma/plasmoids/org.kde.plasma.volumewin7mixer/contents"
    sudo sed -i -r 's/return icon;/return icon + "-panel";/g' ${mixer}/code/icon.js
    sudo sed -i -r "s/'mic-on'/'audio-input-microphone-high-panel'/g" ${mixer}/ui/MixerItem.qml
    sudo sed -i -r "s/'video-television'/'disper-panel'/g" ${mixer}/ui/MixerItem.qml

    panel_icons="/usr/share/icons/Papirus-Dark/24x24/panel"
    for level in high medium low muted; do
        sudo ln -sf ${panel_icons}/microphone-sensitivity-${level}.svg ${panel_icons}/microphone-sensitivity-${level}-panel.svg
    done

    icon_size="512"
    main_color="#c2b790"
    accent_color="#a94d37"
    main_color_old="#d3dae3"
    accent_color_old="#5294e2"
#    hardcode-tray -a -cc "${main_color_old} ${main_color}" -cc "${accent_color_old} ${accent_color}" --theme Papirus-Dark

    tg_icons="$HOME/.TelegramDesktop/tdata/ticons"
    tg_tmp="/tmp/tg_svgs"
    mkdir -p ${tg_tmp} ${tg_icons}
    for i in '_22':'' '_22_1':'attention-' 'mute_22_0':'' 'mute_22_1':'mute-'; do
        ico=${i%:*}; name=${i#*:}
        sed "s/${main_color_old}/${main_color}/gi" ${panel_icons}/telegram-${name}panel.svg > ${tg_tmp}/telegram-${name}panel.svg
        sed -i "s/${accent_color_old}/${accent_color}/gi" ${tg_tmp}/telegram-${name}panel.svg
        inkscape -z -e ${tg_icons}/ico${ico}.png -w ${icon_size} -h ${icon_size} ${tg_tmp}/telegram-${name}panel.svg &>/dev/null
    done
    for f in {2..2000}; do
        ln -sf ${tg_icons}/ico_22_1.png ${tg_icons}/ico_22_${f}.png
        ln -sf ${tg_icons}/icomute_22_1.png ${tg_icons}/icomute_22_${f}.png
    done

    slack_icons="/usr/lib/slack/resources/app.asar.unpacked/src/static"
    slack_tmp="/tmp/slack_svgs"
    mkdir -p ${slack_tmp}
    for i in '':'rest' '-unread':'unread' '-unread':'highlight'; do
        ico=${i%:*}; name=${i#*:}
        sed "s/${main_color_old}/${main_color}/gi" ${panel_icons}/slack-indicator${ico}.svg > ${slack_tmp}/slack-taskbar-${name}.svg
        sed -i "s/${accent_color_old}/${accent_color}/gi" ${slack_tmp}/slack-taskbar-${name}.svg
        inkscape -z -e ${slack_tmp}/slack-taskbar-${name}.png -w ${icon_size} -h ${icon_size} ${slack_tmp}/slack-taskbar-${name}.svg &>/dev/null
        sudo cp ${slack_tmp}/*png ${slack_icons}/
    done

    hex_icons="$HOME/.config/hexchat/icons"
    hex_tmp="/tmp/hex_svgs"
    mkdir -p ${hex_icons} ${hex_tmp}
    for i in 'indicator':'hexchat' 'highlight':'tray_fileoffer' 'highlight':'tray_highlight' 'highlight':'tray_message'; do
        ico=${i%:*}; name=${i#*:}
        sed "s/${main_color_old}/${main_color}/gi" ${panel_icons}/hexchat-${ico}.svg > ${hex_tmp}/${name}.svg
        sed -i "s/${accent_color_old}/${accent_color}/gi" ${hex_tmp}/${name}.svg
        inkscape -z -e ${hex_icons}/${name}.png -w ${icon_size} -h ${icon_size} ${hex_tmp}/${name}.svg &>/dev/null
    done

    pkill latte-dock && latte-dock 2>/dev/null &
    disown
}
