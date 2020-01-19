#!/home/andy/.local/bin/vpy
#!/usr/bin/env python3
import html
import re
import sys
from contextlib import suppress
from random import choice

from plumbum.cmd import playerctl, notify_send
from plumbum import ProcessExecutionError
from requests import get
from requests.exceptions import ConnectionError

from vault import LASTFM_API_KEY, LASTFM_USER


PLAYER_BLACKLIST = ('Gwenview', 'plasma-browser-integration', 'mpv', 'chromium.instance')
MAX_WIDTH = 24


def now_playing_locally(player_blacklist=()):
    player = next(filter(
        lambda p: not any(p.startswith(name) for name in player_blacklist),
        playerctl('--list-all').split()
    ))
    details = {
        detail: playerctl['-p', player, 'metadata'](detail).strip()
        for detail in ('title', 'artist', 'album')
    }
    details['status'] = playerctl('-p', player, 'status').strip()
    return details


def now_playing_lastfm(api_key, user):
    base = 'http://ws.audioscrobbler.com/2.0/'
    try:
        r = get(
            base,
            {
                'api_key': api_key,
                'format': 'json',
                'method': 'user.getRecentTracks',
                'user': user
            },
            timeout=6
        )
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
                        'album': track['album']['#text'],
                        'status': "Last.fm"
                    }


def now_playing(lfm_api_key=LASTFM_API_KEY, lfm_user=LASTFM_USER, player_blacklist=PLAYER_BLACKLIST):
    try:
        return now_playing_locally(player_blacklist)
    except (StopIteration, ProcessExecutionError):
        return now_playing_lastfm(lfm_api_key, lfm_user)


def resize(txt, size, pre='~', post='~', ellipsis='random'):
    free = size - len(txt)
    if ellipsis == 'random':
        ellipsis = choice(('center', 'end'))
    if free >= 0:
        body = f"{txt:^{size}}"
    elif ellipsis == 'end':
        body = f"{txt[:size - 1]}…"
    elif ellipsis == 'center':
        a, b = divmod(size - 1, 2)
        body = f"{txt[:a + b]}…{txt[-a:]}"
    return f"{pre}{body}{post}"


def simplify_title(title):
    stabilized = title
    while True:
        title = re.sub(
            r'( \(?feat(\.|uring) [^\)]+(\)|$))?'
            r'( \(with [^\)]+\))?'
            r'( \(Instrumental\))?'
            r'( \[Extended\])?'
            r'( \(.*Edit\))?'
            r'( \(.*Version\))?'
            r'( \(.*[Mm]ix\))?'
            r'( \[[^\]]+ vs\. [^\]]+\])?'
            r'$', '', title
        )
        title = re.sub(
            r' +- +(.*('
                r'Remaster(ed)?|Single|Stereo|Mono|Long|Re-Record(ed|ing)|Acoustic|'
                r'Bonus Track|Edit|Live( [Aa]t .*)?|Version|([Rr]e?|N\.)?[Mm]i?x|'
                r'Instrumental|Rework|Take|Vocals?|\d{4}'
            r'))?', ' - ', title
        ).rstrip('- ')
        if title == stabilized:
            break
        stabilized = title
    return title


def notify(details):
    if details:
        notify_send(
            '-a', details['status'],
            details['title'],
            f"by {details['artist']}\non {details['album']}"
        )
    else:
        notify_send('-a', "Music", "Nothing playing")


def colorize(text, colorhex='#B8BB26'):
    return f"<font color=\"#{colorhex.lstrip('#')}\">{html.escape(text)}</font>"


def display(details):
    title, artist = simplify_title(details['title']), details['artist']
    size = min(MAX_WIDTH, max(len(artist), len(title)))

    rotation = [artist] * 2 + [title] * 3
    print(resize(choice(rotation), size))

    # print(colorize(resize(choice(rotation), size)))  # https://github.com/Zren/plasma-applet-commandoutput/issues/12


if __name__ == '__main__':
    details = now_playing()
    if '--click' in sys.argv[1:]:
        notify(details)
    elif details:
        display(details)
    else:
        print('~~~')
