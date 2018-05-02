#!/usr/bin/env python3
from contextlib import suppress
from random import choice
import re

from plumbum.cmd import playerctl
from plumbum import ProcessExecutionError
from requests import get
from requests.exceptions import ConnectionError

from vault import LASTFM_API_KEY, LASTFM_USER


fmt = "| font='Iosevka Custom' size=15"


def now_playing(api_key=LASTFM_API_KEY, user=LASTFM_USER):
    try:
        player = [
            *filter(
                lambda p: not p.startswith('Gwenview'),
                playerctl('--list-all').split()
            )
        ][0]
        return {
            detail: playerctl['-p', player, 'metadata'](detail)
            for detail in ('title', 'artist', 'album')
        }
    except (IndexError, ProcessExecutionError):
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


def resize(txt, size, pre='» ', post=' «', ellipsis='random'):
    free = size - len(txt)
    if ellipsis == 'random':
        ellipsis = choice(('center', 'end'))
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
        title = re.sub(
            r' - (Full Length )?(\d+ (- )?)?(Digital )?(Remaster(ed)?|Single|Stereo)( Version)?$',
            '',
            title
        )
        # size = len(artist)
        size = min(17, max(len(artist), len(title)))
        print(resize(artist, size), fmt)
        print(resize(title, size), fmt)
        print('---')
        print(title, fmt, "iconName=media-album-track")
        print(artist, fmt, "iconName=view-media-artist")
        print(album, fmt, "iconName=media-album-cover")
