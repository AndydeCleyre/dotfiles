#!/bin/zsh -e

# -- Dependencies --
# - karousel
# - qdbus6
# - x11-utils (xprop)
# - xdotool

this=$0

usage () {
  print -rlu2 'Usage:' "  $this [--shift|--swipe] RIGHT|LEFT|UP|DOWN"
  return 1
}

if [[ $1 != (--(shift|swipe)|RIGHT|LEFT|UP|DOWN) ]]  usage

shift=
swipe=
if [[ $1 == --shift ]] {
  shift=1
  shift
} elif [[ $1 == --swipe ]] {
  swipe=1
  shift
}

floating=
if [[ $(xprop -id "$(xdotool getactivewindow)" _NET_WM_STATE) != *_NET_WM_STATE_(BELOW|MAXIMIZED)* ]]  floating=1

direction=$1
if [[ $direction != (RIGHT|LEFT|UP|DOWN) ]]  usage

if [[ ! $floating ]] && [[ $swipe ]] {
  case $direction {
    RIGHT) direction=LEFT  ;;
    LEFT)  direction=RIGHT ;;
    UP)    direction=DOWN  ;;
    DOWN)  direction=UP    ;;
  }
}

kwin-do () { qdbus6 org.kde.kglobalaccel /component/kwin invokeShortcut $1 }

karousel-focus () {  # RIGHT|LEFT|UP|DOWN
  case $1 {
    RIGHT) kwin-do karousel-focus-next     ;;
    LEFT)  kwin-do karousel-focus-previous ;;
    UP)    kwin-do 'Switch Window Up'      ;;
    DOWN)  kwin-do 'Switch Window Down'    ;;
  }
}

karousel-move () {  # RIGHT|LEFT|UP|DOWN
  case $1 {
    RIGHT) kwin-do karousel-column-move-${(L)1} ;;
    LEFT)  kwin-do karousel-column-move-${(L)1} ;;
    UP)    kwin-do karousel-window-move-${(L)1} ;;
    DOWN)  kwin-do karousel-window-move-${(L)1} ;;
  }
}

kwin-move () {  # RIGHT|LEFT|UP|DOWN
  case $1 {
    RIGHT) kwin-do "Window Pack ${(C)1}" ;;
    LEFT)  kwin-do "Window Pack ${(C)1}" ;;
    UP)    kwin-do "Window Pack ${(C)1}" ;;
    DOWN)  kwin-do "Window Pack ${(C)1}" ;;
  }
}

kwin-resize () {  # RIGHT|LEFT|UP|DOWN
  case $1 {
    RIGHT) kwin-do 'Window Grow Horizontal'   ;;
    LEFT)  kwin-do 'Window Shrink Horizontal' ;;
    UP)    kwin-do 'Window Shrink Vertical'   ;;
    DOWN)  kwin-do 'Window Grow Vertical'     ;;
  }
}

if [[ $floating ]] {
  if [[ $shift ]] {
    kwin-resize $direction
  } else {
    kwin-move $direction
  }
} else {
  if [[ $shift ]] {
    karousel-move $direction
  } else {
    karousel-focus $direction
  }
}
