#!/bin/bash
set -e

TAB_DIR="$HOME/.config/ff-tabs"
mkdir -p "$TAB_DIR"
TAB_FILE="$TAB_DIR/$(date +%Y.%m.%d_%H.%M.%S).txt"
MAX_BACKUPS=5

if [[ -f "$TAB_FILE" ]]; then
    for (( i="$MAX_BACKUPS"; i>=1; i-- )); do
        mv "$TAB_FILE.$i" "$TAB_FILE.$((i+1))" || true
    done
    mv "$TAB_FILE" "$TAB_FILE.1"
    rm "$TAB_FILE.$((MAX_BACKUPS+1))" || true
fi

xclip -sel clip -o > "$TAB_FILE"
notify-send -i firefox "Saved $(xclip -sel clip -o | wc -l) URLs to file:" "$(xclip -sel clip -o | head)\n. . ."
