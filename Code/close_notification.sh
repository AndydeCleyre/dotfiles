#!/bin/sh
x=$(xdotool getmouselocation | cut -f 1 -d ' ' | cut -f 2 -d ':')
y=$(xdotool getmouselocation | cut -f 2 -d ' ' | cut -f 2 -d ':')
xdotool mousemove 1865 110
xdotool click 1
xdotool mousemove $x $y
