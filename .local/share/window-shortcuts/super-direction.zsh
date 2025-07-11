#!/bin/zsh -e

# -- Dependencies --
# - karousel
# - qdbus6
# - x11-utils (xprop)
# - xdotool

# -- Useful Commands --
# qdbus6 org.kde.kglobalaccel /component/kwin shortcutNames

this=$0

usage () {
  print -rlu2 'Usage:' "  $this [--shift|--swipe|--pinch] RIGHT|LEFT|UP|DOWN|SPACE"
  return 1
}

if [[ $1 != (--(shift|swipe|pinch)|RIGHT|LEFT|UP|DOWN|SPACE) ]]  usage

shift=
swipe=
pinch=
if [[ $1 == --shift ]] {
  shift=1
  shift
} elif [[ $1 == --swipe ]] {
  swipe=1
  shift
} elif [[ $1 == --pinch ]] {
  pinch=1
  shift
}

floating=
if [[ $(xprop -id "$(xdotool getactivewindow)" _NET_WM_STATE) != *_NET_WM_STATE_(BELOW|FULLSCREEN)* ]]  floating=1

direction=$1
if [[ $direction != (RIGHT|LEFT|UP|DOWN|SPACE) ]]  usage

kwin-do () { qdbus6 org.kde.kglobalaccel /component/kwin invokeShortcut $1 }

if [[ $direction == SPACE ]] {
  if [[ $floating ]] {
    kwin-do 'Window Maximize Vertical'
  } else {
    kwin-do karousel-cycle-preset-widths
  }
  return
}

if [[ ! $floating ]] && [[ $swipe ]] {
  case $direction {
    RIGHT) direction=LEFT  ;;
    LEFT)  direction=RIGHT ;;
    UP)    direction=DOWN  ;;
    DOWN)  direction=UP    ;;
  }
}

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

karousel-resize () {  # RIGHT|LEFT
  case $1 {
    RIGHT) kwin-do karousel-column-width-increase ;;
    LEFT)  kwin-do karousel-column-width-decrease ;;
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
  if [[ $shift || $pinch ]] {
    kwin-resize $direction
  } else {
    kwin-move $direction
  }
} else {
  if [[ $shift ]] {
    karousel-move $direction
  } elif [[ $pinch ]] {
    karousel-resize $direction
  } else {
    karousel-focus $direction
  }
}
