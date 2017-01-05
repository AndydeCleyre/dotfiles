fix-plasma () {
    # replace breeze plasma icons with papirus plasma icons:
    #sudo unlink /usr/share/plasma/desktoptheme/default/icons
    #sudo rm -rf /usr/share/plasma/desktoptheme/default/icons
    #yaourt -S --noconfirm papirus-plasma-theme
    #sudo ln -s /usr/share/plasma/desktoptheme/papirus/icons /usr/share/plasma/desktoptheme/default/
    # replace the 5.8 splash with the 5.7 splash:
    #sudo cp -r /home/andy/Code/breeze57splash/splash /usr/share/plasma/look-and-feel/org.kde.breeze.desktop/contents/
    # transparent panel:
    cd ~/Code/plasma-transparent-panel
    git pull
    #python ./transparentpanel.py default East -right -bottomright
    python ./transparentpanel.py Arc-Dark East -right -bottomright
    # reload plasma session:
    kquitapp5 plasmashell
    kstart5 plasmashell
}
