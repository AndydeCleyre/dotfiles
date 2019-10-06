#!/home/andy/bin/vpy
#!/usr/bin/env python3
import re
import sys
from configparser import ConfigParser
from dataclasses import dataclass
from shlex import split
from typing import Callable, Any

from bs4 import BeautifulSoup
from plumbum import local, FG, BG
from plumbum.cmd import (
    firefox,
    gwenview,
    lynx,
    notify_send,
    rtv,
    xclip,
)
from requests import get


def get_ice_cmd(appname):
    cp = ConfigParser()
    cp.read(local.path('~') / f".local/share/applications/{appname}.desktop")
    parts = split(cp['Desktop Entry']['exec'])
    return local[parts[0]][parts[1:-1]]


def get_imgur_album_images(uri):
    r = get(uri)
    soup = BeautifulSoup(r.text)
    return [
        f"https://i.imgur.com/{img.attrs['id']}.jpg"
        for img in soup.find_all(
            attrs={'class': 'post-image-container'}
        )
    ]


@dataclass
class Browser:
    notice: str
    match: Callable[[str], bool]
    run: Callable[[str], Any]


streamer = Browser(
    "Attempting to stream . . .",
    lambda uri: any((
        uri.endswith('.torrent'),
        uri.startswith('magnet:?xt=urn:btih:'),
        re.match(r'^https?://(www\.)?(m\.)?(youtube|vrv)\.com?/(watch|embed)', uri),
        re.match(r'^https?://youtu\.be/', uri),
        re.match(r'^https?://(.+\.)?gfycat\.com/.+\.webm', uri),
        re.match(r'^https?://i\.imgur\.com/', uri) and uri.endswith('v.jpg'),
        uri.startswith('https://v.redd.it/'),
    )),
    lambda uri: local['~/Code/stream.sh'](uri)
)


imager = Browser(
    "Opening image . . .",
    lambda uri: any((
        uri.endswith('.jpg'),
        uri.startswith('https://i.imgur.com/'),
        uri.startswith('https://i.redd.it/'),
    )),
    lambda uri: gwenview[uri] & BG(stderr=sys.stderr)
)


imgur_splitter = Browser(
    "Splitting imgur album . . .",
    lambda uri: re.match(r'^https://imgur\.com/(a|gallery)/', uri),
    lambda uri: route(*get_imgur_album_images(uri))
)


gmaps = Browser(
    "Opening map . . .",
    lambda uri: uri.startswith('https://www.google.com/maps/'),
    lambda uri: get_ice_cmd('googlemaps')[uri] & BG(stderr=sys.stderr)
)


gphotos = Browser(
    "Opening photos . . .",
    lambda uri: any((
        uri.startswith('https://photos.google.com/'),
        uri.startswith('https://photos.app.goo.gl/')
    )),
    lambda uri: get_ice_cmd('googlephotos')[uri] & BG(stderr=sys.stderr)
)


ttyreddit = Browser(
    "Using rtv in existing TTY . . .",
    lambda uri: uri.startswith('https://www.reddit.com/r/') and sys.stdin.isatty() and local.env.get('_') not in ('/bin/rtv',),
    lambda uri: rtv[uri] & FG
)


ttyweb = Browser(
    "Using lynx in existing TTY . . .",
    lambda uri: sys.stdin.isatty() and local.env.get('_') not in ('/bin/rtv',),
    lambda uri: lynx['-accept_all_cookies', uri] & FG
)


def route(*uris):
    for uri in uris:
        uri = re.sub(r'^browser:/{0,2}', '', uri)
        for browser in (streamer, imager, imgur_splitter, gmaps, gphotos, ttyreddit, ttyweb):
            if browser.match(uri):
                notify_send('-a', "browser.py", browser.notice, uri)
                browser.run(uri)
                break
        else:
            notify_send('-a', "browser.py", "Using Firefox . . .", uri)
            with local.env(GTK_USE_PORTAL=1):
                firefox[uri] & BG(stderr=sys.stderr)


if __name__ == '__main__':
    uris = sys.argv[1:] or xclip('-sel', 'clip', '-o').splitlines()
    route(*uris)
