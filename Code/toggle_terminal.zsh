#!/bin/zsh

terminal=wezterm-gui
wm_class=org.wezfurlong.wezterm

if [[ $(xprop -id $(xdotool getactivewindow) WM_CLASS) =~ \"$wm_class\" ]] {
  xdotool getactivewindow windowminimize
} else {
  wmctrl -xR $wm_class
}

pgrep -u $USER -x $terminal || exec $terminal &
