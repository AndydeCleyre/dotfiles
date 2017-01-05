#!/bin/bash

cd ~/.TelegramDesktop/tdata/ticons
rm -r *

# blue -> grey
# convert /usr/share/pixmaps/telegram.png -modulate 51,0,100 ./ico_22.png
# or not:
cp /usr/share/pixmaps/telegram.png ./ico_22.png


# white center -> transparent center (base):
# convert ico_22.png -fuzz 40% -transparent white ico_22.png
# or not.

# blue -> orangered (unmuted, messages):
convert /usr/share/pixmaps/telegram.png -modulate 100,120,0 ico_22_1.png
# or not:
#cp /usr/share/pixmaps/telegram.png ico_22_1.png

# blue -> dark blue (muted, no messages):
# convert ico_22.png -modulate 50,100,100 icomute_22_0.png
# or not:
#cp /usr/share/pixmaps/telegram.png icomute_22_0.png
#convert /usr/share/pixmaps/telegram.png -modulate 60,0,100 icomute_22_0.png
cp ico_22.png icomute_22_0.png

# orangered -> dark orangered (muted, messages):
convert ico_22_1.png -modulate 50,100,100 icomute_22_1.png
# or not:
#cp /usr/share/pixmaps/telegram.png icomute_22_1.png

for f in {2..2000}; do ln -s ico_22_1.png ico_22_$f.png; done
for f in {2..2000}; do ln -s icomute_22_1.png icomute_22_$f.png; done
