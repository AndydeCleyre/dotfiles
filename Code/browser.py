#!/home/andy/.local/bin/vpy
#!/usr/bin/env python3
import os
import re
import sys
from configparser import ConfigParser
from dataclasses import dataclass
from shlex import split

from typing import Callable, List, Any
from plumbum.machines.local import LocalCommand

from bs4 import BeautifulSoup
from plumbum import local, FG, BG
from plumbum.cmd import (
    firefox,
    notify_send,
    ps,
    qview,
    telegram_desktop,
    ttrv,
    w3m,
    wget,
    xclip,
)
from httpx import get


def get_ice_cmd(appname: str) -> LocalCommand:
    cp = ConfigParser()
    cp.read(local.path('~') / f".local/share/applications/{appname}.desktop")
    parts = split(cp['Desktop Entry']['exec'])
    return local[parts[0]][parts[1:-1]]


def get_imgur_album_image_uris(uri: str) -> List[str]:
    r = get(uri)
    soup = BeautifulSoup(r.text)
    return [
        f"https://i.imgur.com/{img.attrs['id']}.jpg"
        for img in soup.find_all(
            attrs={'class': 'post-image-container'}
        )
    ]


def fetch_and_view(uri: str):
    with local.tempdir() as tmp:
        wget('-O', tmp / 'img', uri)
        qview[tmp / 'img'] & FG


@dataclass
class Browser:
    notice: str
    match: Callable[[str], bool]
    run: Callable[[str], Any]


tdesktop = Browser(
    "Opening Telegram . . .",
    lambda uri: uri.startswith('tg://'),
    lambda uri: telegram_desktop['--', uri] & BG(stderr=sys.stderr)
)

        # r'(.*\.torrent$)'
        # r'|(magnet:\?xt=urn:btih:)'
streamer = Browser(
    "Attempting to stream . . .",
    lambda uri: re.match(
        r'(https?://youtu\.be/)'
        r'|(https?://(www\.)?(m\.)?(youtube|vrv)\.com?/(watch|embed))'
        r'|(https?://vm\.tiktok\.com/)'
        r'|(https?://vimeo\.com/\d+)'
        r'|(https?://([^/]+\.)?gfycat\.com/.)'
        r'|(https?://i\.imgur\.com/.*(v\.jpg|\.mp4|\.gifv)$)'
        r'|(https://v\.redd\.it/)',
        uri
    ),
    local['~/Code/stream.sh']
)


img_viewer = Browser(
    "Opening image . . .",
    lambda uri: re.match(
        r'(.*\.(jp|pn)g$)'
        r'|(https://i\.imgur\.com/)'
        r'|(https://i\.redd\.it/)',
        uri
    ),
    fetch_and_view
)


imgur_splitter = Browser(
    "Splitting imgur album . . .",
    lambda uri: re.match(r'https://imgur\.com/(a|gallery)/', uri),
    lambda uri: route(*get_imgur_album_image_uris(uri))
)


gcalendar = Browser(
    "Opening calendar . . .",
    lambda uri: uri.startswith('https://calendar.google.com/'),
    lambda uri: get_ice_cmd('googlecalendar')[uri] & BG(stderr=sys.stderr)
)


gmaps = Browser(
    "Opening map . . .",
    lambda uri: uri.startswith('https://www.google.com/maps/'),
    lambda uri: get_ice_cmd('googlemaps')[uri] & BG(stderr=sys.stderr)
)


gphotos = Browser(
    "Opening photos . . .",
    lambda uri: re.match(
        r'(https://photos\.google\.com/)'
        r'|(https://photos\.app\.goo\.gl/)',
        uri
    ),
    lambda uri: get_ice_cmd('googlephotos')[uri] & BG(stderr=sys.stderr)
)


ttyreddit = Browser(
    "Using ttrv in existing TTY . . .",
    lambda uri: uri.startswith('https://www.reddit.com/r/') and sys.stdin.isatty(),
    lambda uri: (
        ttrv[
            ['-s', [*filter(None, uri.split('/'))][-1]]
            if re.match(r'https://www\.reddit\.com/r/[^/]+/?$', uri)
            else uri
        ] & FG
    )
)


ttyweb = Browser(
    "Using w3m in existing TTY . . .",
    lambda uri: (
        sys.stdin.isatty() and
        (
            ps('ocmd=', os.getppid()).split()[0].split('/')[-1] in ('ddgr', 'zsh', '-zsh')
            # ps('ocmd=', os.getppid()).split()[1].split('/')[-1] in ('ddgr', 'zsh', '-zsh')
        )
    ),
    # lambda uri: lynx['-accept_all_cookies', uri] & FG
    lambda uri: w3m[uri] &FG
    # lambda uri: w3m['-o', 'confirm_qq=false', uri] &FG
)


def route(*uris: str, debug=False):
    for uri in uris:
        uri = re.sub(r'^browser:/{0,2}', '', uri)
        uri = re.sub(r'^https://preview\.redd\.it/([^.]+\.png)(\?.*)', r'https://i.redd.it/\1', uri)
        uri = re.sub(r'^https://t\.me/([^/]+)$', r'tg://resolve?domain=\1', uri)
        uri = re.sub(r'^https://t\.me/([^/]+)/([^/]+)$', r'tg://\1?slug=\2', uri)

        for browser in (
            streamer,
            img_viewer,
            imgur_splitter,
            gmaps,
            gphotos,
            ttyreddit,
            gcalendar,
            tdesktop,

            ttyweb,
        ):
            if debug:
                print(f"Checking {browser}")
                print(browser.match(uri))
                continue
            # notify_send('-a', "browser.py debugging", '_'+ps('ocmd=', os.getppid()), os.getppid())
            if browser.match(uri):
                notify_send('-t', 1000, '-a', "browser.py", browser.notice, uri)
                browser.run(uri)
                break
        else:
            if debug:
                print("No match")
                return
            # TODO: maybe move ttyweb matching down here
            # or rather: add a catch-all firefox Browser above, removing below:
            notify_send('-t', 1000, '-a', "browser.py", "Using Firefox . . .", uri)
            firefox[uri] & BG(stderr=sys.stderr)


if __name__ == '__main__':
    if '--debug' in sys.argv:
        sys.argv.remove('--debug')
        debug=True
    else:
        debug=False
    uris = sys.argv[1:] or xclip('-sel', 'clip', '-o').splitlines()
    route(*uris, debug=debug)
