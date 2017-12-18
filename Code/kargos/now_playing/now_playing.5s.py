#!/usr/bin/env python3
from contextlib import suppress
import re

from plumbum.cmd import playerctl
from plumbum import ProcessExecutionError
from requests import get
from requests.exceptions import ConnectionError

from vault import LASTFM_API_KEY, LASTFM_USER


fmt = "| font='Iosevka'"
# fmt = "| font='Iosevka Light'"
# fmt = " | font='Iosevka Light' size=20"
# event calendar clock height 34px


def now_playing(api_key=LASTFM_API_KEY, user=LASTFM_USER):
    try:
        return {detail: playerctl['metadata'](detail) for detail in ('title', 'artist', 'album')}
    except ProcessExecutionError:
        base = 'http://ws.audioscrobbler.com/2.0/'
        try:
            r = get(base, params={
                'format': 'json', 'api_key': api_key,
                'method': 'user.getRecentTracks',
                'user': user
            })
        except ConnectionError:
            pass
        else:
            if r.ok:
                track = r.json()['recenttracks']['track'][0]
                with suppress(KeyError):
                    if track['@attr']['nowplaying']:
                        return {
                            'title': track['name'],
                            'artist': track['artist']['#text'],
                            'album': track['album']['#text']
                        }


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


if __name__ == '__main__':
    details = now_playing()
    try:
        title, artist, album = details['title'], details['artist'], details['album']
    except TypeError:
        print(fmt, "iconName=spotify-indicator bash=spotify onclick=bash")
    else:
        title = re.sub(r' - (Full Length )?(\d+ (- )?)?(Digital )?(Remaster(ed)?|Single|Stereo)( Version)?$', '', title)
        # size = len(artist)
        size = min(15, max(len(artist), len(title)))
        print(resize(artist, size), fmt)
        print(resize(title,  size), fmt)
        print('---')
        print(title, fmt, "iconName=media-album-track")
        print(artist, fmt, "iconName=view-media-artist")
        print(album, fmt, "iconName=media-album-cover")
