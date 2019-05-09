#!/usr/bin/env python3
# import re
import sys

from bs4 import BeautifulSoup
from plumbum import local, FG, BG
from plumbum.cmd import (
    firefox,
    gwenview,
    lynx,
    mpv,
    rtv,
    xclip,
)
from requests import get


def route(*uris):
    for uri in uris:
        if any((
            uri.startswith('magnet:?xt=urn:btih:'),
            uri.endswith('.torrent'),
            '://www.youtube.com/watch' in uri,
            # v.reddit
        )):
            local['~/Code/stream.sh'](uri)
        elif any((
            uri.startswith('https://i.imgur.com/'),
            uri.startswith('https://i.redd.it/'),
        )):
            gwenview[uri] & BG(stderr=sys.stderr)
        elif any((
            uri.startswith('https://imgur.com/a/'),
            uri.startswith('https://imgur.com/gallery/'),
        )):
            r = get(uri)
            soup = BeautifulSoup(r.text)
            for img in soup.find_all(attrs={'class': 'post-image-container'}):
                route(f"https://i.imgur.com/{img.attrs['id']}.jpg")
        elif sys.stdin.isatty():
            if uri.startswith('https://www.reddit.com/r/'):
                rtv[uri] & FG
            else:
                lynx['-accept_all_cookies', uri] & FG
        else:
            with local.env(GTK_USE_PORTAL=1):
                firefox[uri] & BG(stderr=sys.stderr)


if __name__ == '__main__':
    uris = sys.argv[1:] or xclip('-sel', 'clip', '-o').splitlines()
    route(*uris)
