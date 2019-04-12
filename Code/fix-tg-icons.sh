#!/bin/bash
set -e

cd ~/.local/share/TelegramDesktop/tdata/ticons
rm -rf *.png

cp /usr/share/icons/Papirus/24x24/panel/telegram-* ./
sed -i 's/dfdfdf/c2b790/' *.svg
sed -i 's/4285f4/a94d37/' *.svg
sed -i 's/c2b790/a94d37/' telegram-attention-panel.svg

inkscape -z -e icon_22_0.png -w 256 -h 256 telegram-panel.svg
inkscape -z -e icon_22_1.png -w 256 -h 256 telegram-attention-panel.svg
inkscape -z -e iconmute_22_1.png -w 256 -h 256 telegram-mute-panel.svg
rm -rf *.svg

ln -s icon_22_0.png iconmute_22_0.png
for f in {2..2000}; do ln -s icon_22_1.png icon_22_$f.png; done
for f in {2..2000}; do ln -s iconmute_22_1.png iconmute_22_$f.png; done
