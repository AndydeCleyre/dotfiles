#!/usr/bin/env python3
from plumbum.cmd import playerctl
from plumbum import ProcessExecutionError


fmt = " | font='Iosevka Light' size=21"
# event calendar clock height 34px

get = playerctl['metadata']

def resize(txt, size, pre='» ', post=' «', ellipsis='center'):
    free = size - len(txt)
    if free >= 0:
        a, b = divmod(free, 2)
        return f"{pre}{' ' * a}{txt}{' ' * (a + b)}{post}"
    elif ellipsis == 'end':
        return f"{pre}{txt[:size - 1]}…{post}"
    elif ellipsis == 'center':
        a, b = divmod(size - 1, 2)
        return f"{pre}{txt[:a + b]}…{txt[-a:]}{post}"

try:
    title, artist = get('title'), get('artist')
except ProcessExecutionError:
    print(f"{fmt} iconName=spotify-indicator bash=spotify onclick=bash")
else:
    # size = len(artist)
    size = min(15, max(len(artist), len(title)))
    print(f"{resize(artist, size)}{fmt}")
    print(f"{resize(title,  size)}{fmt}")
    print('---')
    print(f"{title}       {fmt}", "iconName=media-album-track")
    print(f"{artist}      {fmt}", "iconName=view-media-artist")
    print(f"{get('album')}{fmt}", "iconName=media-album-cover")
