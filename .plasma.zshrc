fix-plasma () {
    hardcode-tray -a --change-color "#d3dae3 #c2b790" --theme Papirus-Dark

    sudo sed -i -r 's/return icon;/return icon + "-panel";/g' /usr/share/plasma/plasmoids/org.kde.plasma.volumewin7mixer/contents/code/icon.js
    sudo sed -i -r "s/'mic-on'/'audio-input-microphone-high-panel'/g" /usr/share/plasma/plasmoids/org.kde.plasma.volumewin7mixer/contents/ui/MixerItem.qml
    sudo sed -i -r "s/'video-television'/'disper-panel'/g" /usr/share/plasma/plasmoids/org.kde.plasma.volumewin7mixer/contents/ui/MixerItem.qml
    # fix slider bar color

    for level in high medium low muted; do
        sudo ln -sf /usr/share/icons/Papirus-Dark/24x24/panel/microphone-sensitivity-$level.svg /usr/share/icons/Papirus-Dark/24x24/panel/microphone-sensitivity-$level-panel.svg
    done

    kquitapp5 plasmashell && kstart5 plasmashell
}
