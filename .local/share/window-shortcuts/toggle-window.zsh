#!/bin/zsh -e

# -- Dependencies --
# - procps (pgrep)
# - wmctrl
# - x11-utils (xprop)
# - xdotool

this=$0

usage () {
  print -rlu2 'Usage:' \
  "  $this LAUNCH_CMD [ WM_CLASS [ CHECK_CMD ] ]" '' \
  '  WM_CLASS and CHECK_CMD each default to the value of LAUNCH_CMD' '' \
  'Examples:' \
  "  $this dolphin" \
  "  $this firefox firefox firefox-bin" \
  "  $this ghostty" \
  "  $this librewolf" \
  "  $this rio" \
  "  $this strawberry" \
  "  $this subl" \
  "  $this Telegram" \
  "  $this wezterm-gui org.wezfurlong.wezterm" \
  "  $this zed dev.zed.Zed zed-editor" \
  "  $this zen-browser zen zen-bin"

  return 1
}

if [[ ! $1 ]] || [[ $1 == --* ]]  usage

launch_cmd=(${(z)1})
wm_class=${2:-$1}
check_cmd=${3:-$1}

if [[ $(xprop -id $(xdotool getactivewindow) WM_CLASS) =~ \"$wm_class\" ]] {
  xdotool getactivewindow windowminimize
} else {
  wmctrl -xR $wm_class || true
}

pgrep -u $USER -x ${check_cmd[1,15]} || exec $launch_cmd &
