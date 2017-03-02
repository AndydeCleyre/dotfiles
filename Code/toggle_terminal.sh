#!/bin/bash

terminal=konsole

terminal_windows=`xdotool search --class $terminal`

if [[ `echo $terminal_windows | grep $(xdotool getactivewindow)` ]]
then
  for i in $terminal_windows
  do
    xdotool windowminimize $i
  done
else
  for i in $terminal_windows
  do
    xdotool windowactivate $i
  done
fi

pgrep -u "$(whoami)" -x $terminal || exec $terminal &
