#!/bin/bash
set -e

plain_color=`python3 -c "print(''.join(hex(int(i))[2:] for i in '$(kreadconfig5 --group Colors:Window --key ForegroundNormal)'.split(',')))"`
alert_color=`python3 -c "print(''.join(hex(int(i))[2:] for i in '$(kreadconfig5 --group Colors:Window --key DecorationFocus)'.split(',')))"`

cd ~/.local/share/TelegramDesktop/tdata/ticons
rm -rf *.png

cp /usr/share/icons/Papirus/24x24/panel/telegram-* ./
sed -i "s/dfdfdf/$plain_color/" *.svg
sed -i "s/4285f4/$alert_color/" *.svg
sed -i "s/$plain_color/$alert_color/" telegram-attention-panel.svg

inkscape -z -e icon_22_0.png -w 256 -h 256 telegram-panel.svg
inkscape -z -e icon_22_1.png -w 256 -h 256 telegram-attention-panel.svg
inkscape -z -e iconmute_22_1.png -w 256 -h 256 telegram-mute-panel.svg
rm -rf *.svg

ln -s icon_22_0.png iconmute_22_0.png
for f in {2..2000}; do ln -s icon_22_1.png icon_22_$f.png; done
for f in {2..2000}; do ln -s iconmute_22_1.png iconmute_22_$f.png; done
