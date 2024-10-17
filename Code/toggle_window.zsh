#!/bin/zsh -ex

# -- Usage --
# ./toggle_window.zsh LAUNCH_CMD [ WM_CLASS [ CHECK_CMD ] ]

# -- Defaults --
# WM_CLASS and CHECK_CMD each default to the value of LAUNCH_CMD

# -- Examples --
# ./toggle_window.zsh dolphin
# ./toggle_window.zsh wezterm-gui org.wezfurlong.wezterm
# ./toggle_window.zsh firefox firefox firefox-bin
# ./toggle_window.zsh \
#   'flatpak run --branch=stable --arch=x86_64 --command=telegram-desktop --file-forwarding org.telegram.desktop' \
#   telegram-desktop telegram-deskto
# Yes, "telegram-deskto" without a final p. Hmm.

# -- Dependencies --
# - procps (pgrep)
# - wmctrl
# - x11-utils (xprop)
# - xdotool

launch_cmd=(${(z)1})
wm_class=${2:-$1}
check_cmd=${3:-$1}

if [[ $(xprop -id $(xdotool getactivewindow) WM_CLASS) =~ \"$wm_class\" ]] {
  xdotool getactivewindow windowminimize
} else {
  wmctrl -xR $wm_class || true
}

pgrep -u $USER -x $check_cmd || exec $launch_cmd &
