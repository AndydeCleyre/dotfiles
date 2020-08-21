#!/bin/bash

terminal=${1:-konsole}
# terminal=${1:-alacritty}
if [[ $(xprop -id $(xdotool getactivewindow) WM_CLASS) =~ \"$terminal\" ]]; then
    xdotool getactivewindow windowminimize
else
    wmctrl -xR $terminal
fi

pgrep -u "$(whoami)" -x $terminal || exec $terminal &
