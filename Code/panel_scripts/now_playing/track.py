#!/home/andy/.local/bin/vpy --no-env
#!/home/andy/.local/bin/vpy
#!/usr/bin/env python3
import re
import sys

from collections import defaultdict
from contextlib import suppress
from random import choice

import httpx
from plumbum import CommandNotFound, ProcessExecutionError, local
from plumbum.cmd import notify_send, playerctl

from vault import LASTFM_API_KEY, LASTFM_USER


MAX_WIDTH = 24

PLAYER_BLACKLIST_REGEXP = r'Gwenview|plasma-browser-integration|mpv|chromium\.instance'

STATUS_ICONS = {
    'Playing': '▶',
    # 'Playing': '⏵',
    # 'Playing': '',
    # 'Playing': '契',
    # 'Playing': '',
    # 'Playing': '',
    # 'Playing': '奈',
    # 'Playing': '',
    # 'Playing': '金',
    # 'Playing': '喇',

    'Paused': '⏸',
    # 'Paused': '',
    # 'Paused': '',
    # 'Paused': '懶',
    # 'Paused': '',
    # 'Paused': '',
    # 'Paused': '',
    # 'Paused': '',
    # 'Paused': '',
    # 'Paused': '',

    'Stopped': '⏹',
    # 'Stopped': '栗',
    # 'Stopped': '',
    # 'Stopped': '',
    # 'Stopped': '',
    # 'Stopped': 'ﭥ',
    # 'Stopped': 'ﭦ',

    'Last.fm': '',
    # 'Last.fm': '',
    # 'Last.fm': '',

    'NetworkError': '',
}


def now_playing_locally(player_blacklist_regexp=r'$'):
    try:
        player = next(
            name for name in playerctl('--list-all').split()
            if not re.match(player_blacklist_regexp, name)
        )
    except StopIteration:
        return None
    try:
        details = {
            detail: playerctl['-p', player, 'metadata'](detail).strip()
            for detail in ('title', 'artist', 'album')
        }
        details['status'] = playerctl('-p', player, 'status').strip()
    except ProcessExecutionError as e:
        pass
        # notify_send('-a', "Music", "Error", e)
    else:
        return details


def now_playing_lastfm(api_key, user):
    try:
        with suppress(CommandNotFound):
            local['nm-online']('-x')
    except ProcessExecutionError as e:
        return defaultdict(str, status="NetworkError", error=str(e))
    else:
        base = 'http://ws.audioscrobbler.com/2.0/'
        try:
            r = httpx.get(base, params={
                'api_key': api_key,
                'format': 'json',
                'method': 'user.getRecentTracks',
                'user': user
            })
        except httpx.exceptions.NetworkError as e:
            return defaultdict(str, status="NetworkError", error=str(e))
        else:
            if r.status_code == httpx.codes.OK:
                track = r.json()['recenttracks']['track'][0]
                with suppress(KeyError):
                    if track['@attr']['nowplaying']:
                        return {
                            'title': track['name'],
                            'artist': track['artist']['#text'],
                            'album': track['album']['#text'],
                            'status': "Last.fm"
                        }


def now_playing(lfm_api_key=LASTFM_API_KEY, lfm_user=LASTFM_USER, player_blacklist_regexp=PLAYER_BLACKLIST_REGEXP):
    return now_playing_locally(player_blacklist_regexp) or now_playing_lastfm(lfm_api_key, lfm_user)


def resize(txt, size, pre='~', post='~', ellipsis='random', placement='center'):
    free = size - len(txt)
    if ellipsis == 'random':
        ellipsis = choice(('center', 'end'))
    if free >= 0:
        if placement == 'center':
            body = f"{txt:^{size}}"
        elif placement == 'end':
            body = f"{txt:>{size}}"
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
            r'( \[?feat(\.|uring) [^\]]+(\]|$))?'
            r'( \(?feat(\.|uring) [^\)]+(\)|$))?'
            r'( \(with [^\)]+\))?'
            r'( \(Instrumental\))?'
            r'( \[Extended\])?'
            r'( \([^\)]*Edit\))?'
            r'( \([^\)]*Version\))?'
            r'( \([^\)]*[Mm]ix\))?'
            r'( \[[^\]]*[Mm]ix\])?'
            r'( \[[^\]]+ vs\. [^\]]+\])?'
            r'$', '', title
        )
        title = re.sub(
            r' +- +(.*('
                r'Remaster(ed)?|Single|Stereo|Mono|Long|Re-Record(ed|ing)|Acoustic|'
                r'Bonus Track|Edit|Live( [Aa]t .*)?|Version|([Rr]e?|N\.)?[Mm]i?x|'
                r'Instrumental|Rework|Take|Vocals?|\d{4}|Dub'
            r'))?', ' - ', title
        ).rstrip('- ')
        if title == stabilized:
            break
        stabilized = title
    return title


def notify(details):
    if details:
        notify_send(
            '-a', "Music",
            details['status'],
            '\n'.join(filter(None, (
                details['title'],
                (f"\nby {details['artist']}") if details['artist'] else '',
                (f"\non {details['album']}") if details['album'] else ''
            )))
        )
    else:
        notify_send('-a', "Music", "Nothing playing")


def display(details):
    if not details:
        print(STATUS_ICONS['Stopped'])
        return
    title = (
        simplify_title(details['title'])
        or STATUS_ICONS.get(details['status'], details['status'])
    )
    artist = (
        details['artist']
        or STATUS_ICONS.get(details['status'], details['status'])
    )
    rotation = [artist] * 2 + [title] * 3
    size = min(MAX_WIDTH, max(len(artist), len(title)))
    pre = (
        STATUS_ICONS.get(details['status'], '~') + ' '
        if size > 1 else ''
    )
    print(resize(choice(rotation), size, pre=pre, post=''))


if __name__ == '__main__':
    details = now_playing()
    if '--click' in sys.argv[1:]:
        notify(details)
    else:
        display(details)
