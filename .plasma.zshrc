fix-plasma () {
    hardcode-tray -a --change-color "#d3dae3 #c2b790" --theme Papirus-Dark

    mixer="/usr/share/plasma/plasmoids/org.kde.plasma.volumewin7mixer/contents"
    sudo sed -i -r 's/return icon;/return icon + "-panel";/g' $mixer/code/icon.js
    sudo sed -i -r "s/'mic-on'/'audio-input-microphone-high-panel'/g" $mixer/ui/MixerItem.qml
    sudo sed -i -r "s/'video-television'/'disper-panel'/g" $mixer/ui/MixerItem.qml

    panel_icons="/usr/share/icons/Papirus-Dark/24x24/panel"
    for level in high medium low muted; do
        sudo ln -sf $panel_icons/microphone-sensitivity-$level.svg $panel_icons/microphone-sensitivity-$level-panel.svg
    done

    sudo sed -i -r 's/width: Math\.round\(parent\.width \* 0\.9\)/width: 24/g' /usr/share/plasma/plasmoids/org.kde.plasma.colorpicker/contents/ui/main.qml

#    kquitapp5 plasmashell && kstart5 plasmashell

    pkill latte-dock && latte-dock &
    disown
}
