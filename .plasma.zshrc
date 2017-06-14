fix-plasma () {
    mixer="/usr/share/plasma/plasmoids/org.kde.plasma.volumewin7mixer/contents"
    sudo sed -i -r 's/return icon;/return icon + "-panel";/g' ${mixer}/code/icon.js
    sudo sed -i -r "s/'mic-on'/'audio-input-microphone-high-panel'/g" ${mixer}/ui/MixerItem.qml
    sudo sed -i -r "s/'video-television'/'disper-panel'/g" ${mixer}/ui/MixerItem.qml

    panel_icons="/usr/share/icons/Papirus-Dark/24x24/panel"
    for level in high medium low muted; do
        sudo ln -sf ${panel_icons}/microphone-sensitivity-${level}.svg ${panel_icons}/microphone-sensitivity-${level}-panel.svg
    done

    main_color_old="#d3dae3"
    main_color="#c2b790"
    accent_color_old="#5294e2"
    accent_color="#a94d37"
    hardcode-tray -a -cc "${main_color_old} ${main_color}" "${accent_color_old} ${accent_color}"

    pkill latte-dock && latte-dock 2>/dev/null &
    disown
}
