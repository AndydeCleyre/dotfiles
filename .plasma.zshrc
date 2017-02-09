fix-plasma () {
    hardcode-tray -a --change-color "#d3dae3 #c2b790" --theme Papirus-Dark
    sudo sed -i -r 's/(audio-volume-[^"]+)/\1-panel/g' /usr/share/plasma/plasmoids/org.kde.plasma.volumewin7mixer/contents/code/icon.js
    kquitapp5 plasmashell
    kstart5 plasmashell
}
