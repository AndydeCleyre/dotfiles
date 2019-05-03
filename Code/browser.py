#!/usr/bin/env python3
import sys

from plumbum import local
from plumbum.cmd import xclip, mpv, firefox, lynx, rtv


uris = sys.argv[1:] or xclip('-sel', 'clip', '-o').splitlines()
for uri in uris:
    if any((
        uri.startswith('magnet:?xt=urn:btih:'),
        uri.endswith('.torrent'),
        '://www.youtube.com/watch' in uri,
    )):
        local['~/Code/stream.sh'](uri)
    elif sys.stdin.isatty():
        if uri.startswith('https://www.reddit.com/r/'):
            rtv[uri].run_fg()
        else:
            lynx[uri].run_fg()
    else:
        with local.env(GTK_USE_PORTAL=1):
            firefox[uri].run_bg()
