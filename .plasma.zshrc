fix-plasma () {
    hardcode-tray -a --change-color "d3dae3 c2b790" --theme Papirus-Dark
    # transparent panel:
    cd ~/Code/plasma-transparent-panel
    git pull
    python ./transparentpanel.py Arc-Color East -right -bottomright
    kquitapp5 plasmashell
    kstart5 plasmashell
}
