fix-plasma () {
    # transparent panel:
    cd ~/Code/plasma-transparent-panel
    git pull
    python ./transparentpanel.py Arc-Color East -right -bottomright
    kquitapp5 plasmashell
    kstart5 plasmashell
}
