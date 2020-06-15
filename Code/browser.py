#!/home/andy/.local/bin/vpy
#!/home/andy/bin/vpy
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
    tuir,
    w3m,
    wget,
    xclip,
)
from requests import get


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


streamer = Browser(
    "Attempting to stream . . .",
    lambda uri: re.match(
        r'(.*\.torrent$)'
        r'|(magnet:\?xt=urn:btih:)'
        r'|(https?://(www\.)?(m\.)?(youtube|vrv)\.com?/(watch|embed))'
        r'|(https?://youtu\.be/)'
        r'|(https?://vimeo\.com/\d+)'
        r'|(https?://([^/]+\.)?gfycat\.com/.)'
        r'|(https?://i\.imgur\.com/.*(v\.jpg|\.mp4|\.gifv)$)'
        r'|(https://v\.redd\.it/)', uri
    ),
    local['~/Code/stream.sh']
)


img_viewer = Browser(
    "Opening image . . .",
    lambda uri: re.match(
        r'(.*\.(jp|pn)g$)'
        r'|(https://i\.imgur\.com/)'
        r'|(https://i\.redd\.it/)', uri
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
        r'|(https://photos\.app\.goo\.gl/)', uri
    ),
    lambda uri: get_ice_cmd('googlephotos')[uri] & BG(stderr=sys.stderr)
)


ttyreddit = Browser(
    "Using tuir in existing TTY . . .",
    lambda uri: uri.startswith('https://www.reddit.com/r/') and sys.stdin.isatty(),
    lambda uri: (
        tuir[
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
    lambda uri: w3m[uri] & FG
)


def route(*uris: str):
    for uri in uris:
        uri = re.sub(r'^browser:/{0,2}', '', uri)

        # streamer.run(uri)
        # continue

        for browser in (
            streamer,
            img_viewer,
            imgur_splitter,
            gmaps,
            gphotos,
            ttyreddit,
            ttyweb,
            gcalendar,
        ):
            # notify_send('-a', "browser.py debugging", '_'+ps('ocmd=', os.getppid()), os.getppid())
            # notify_send('-a', "browser.py debugging", "Checking for match:", browser)
            if browser.match(uri):
                notify_send('-t', 1000, '-a', "browser.py", browser.notice, uri)
                browser.run(uri)
                break
        else:
            notify_send('-t', 1000, '-a', "browser.py", "Using Firefox . . .", uri)
            with local.env(GTK_USE_PORTAL=1):
                firefox[uri] & BG(stderr=sys.stderr)


if __name__ == '__main__':
    uris = sys.argv[1:] or xclip('-sel', 'clip', '-o').splitlines()
    route(*uris)
