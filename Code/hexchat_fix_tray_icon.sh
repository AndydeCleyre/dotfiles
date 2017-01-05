#!/bin/bash

mkdir -p ~/.config/hexchat/icons
cd ~/.config/hexchat/icons
inkscape -z -e tray_message.png -w 256 -h 256 /usr/share/icons/Papirus/16x16/apps/hexchat.svg
cp tray_message.png tray_highlight.png
cp tray_message.png tray_fileoffer.png

# colored -> dark grey:
#gm convert tray_message.png -modulate 51,0,100 hexchat.png
# or colored -> whitish:
gm convert tray_message.png -modulate 200,100,100 hexchat.png
