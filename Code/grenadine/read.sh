#!/bin/bash
set -e

TAB_DIR="$HOME/.config/ff-tabs"
mkdir -p "$TAB_DIR"
cat "$TAB_DIR"/*.txt | xclip -sel clip
notify-send -i firefox "Copied $(xclip -sel clip -o | wc -l) URLs from file:" "$(xclip -sel clip -o | head)\n. . ."
