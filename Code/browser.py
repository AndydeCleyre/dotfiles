#!/usr/bin/env python3
import re
import sys

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


def route(*uris):
    for uri in uris:
        uri = re.sub(r'^browser:/?/?', '', uri)
        if any((
            re.match(r'https?://(.+\.)?gfycat\.com/.+\.webm', uri),
            re.match(r'https?://(www\.)?(youtube|vrv)\.com?/(watch|embed)', uri),
            re.match(r'https?://i\.imgur\.com/', uri) and uri.endswith('v.jpg'),
            uri.endswith('.torrent'),
            uri.startswith('magnet:?xt=urn:btih:'),
            # v.reddit
        )):
            notify_send('-a', "browser.py", "Attempting to stream . . .")
            local['~/Code/stream.sh'](uri)
        elif any((
            uri.endswith('.jpg'),
            uri.startswith('https://i.imgur.com/'),
            uri.startswith('https://i.redd.it/'),
        )):
            notify_send('-a', "browser.py", "Opening image . . .")
            gwenview[uri] & BG(stderr=sys.stderr)
        elif re.match(r'https://imgur\.com/(a|gallery)/', uri):
            notify_send('-a', "browser.py", "Splitting imgur album . . .")
            r = get(uri)
            soup = BeautifulSoup(r.text)
            for img in soup.find_all(attrs={'class': 'post-image-container'}):
                route(f"https://i.imgur.com/{img.attrs['id']}.jpg")
        elif sys.stdin.isatty() and local.env.get('_') not in ('/bin/rtv', '/bin/ddgr'):
            if uri.startswith('https://www.reddit.com/r/'):
                notify_send('-a', "browser.py", "Using rtv in existing TTY . . .")
                rtv[uri] & FG
            else:
                notify_send('-a', "browser.py", "Using lynx in existing TTY . . .")
                lynx['-accept_all_cookies', uri] & FG
        else:
            notify_send('-a', "browser.py", "Using Firefox . . .")
            with local.env(GTK_USE_PORTAL=1):
                firefox[uri] & BG(stderr=sys.stderr)


if __name__ == '__main__':
    uris = sys.argv[1:] or xclip('-sel', 'clip', '-o').splitlines()
    route(*uris)
