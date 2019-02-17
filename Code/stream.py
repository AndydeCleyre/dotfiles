#!/usr/bin/env python3

import sys

from requests import get
from plumbum import local
from plumbum.cli.terminal import ask
from plumbum.cmd import peerflix, xclip, mpv

vpn = local['~/Code/vpn.py']

uris = sys.argv[1:] or xclip('-sel', 'clip', '-o').splitlines()
for uri in uris:
    if uri.startswith('magnet:?xt=urn:btih:') or uri.endswith('.torrent'):
        r = get('https://api.duckduckgo.com', {'q': 'ip', 'format': 'json'})
        location = r.json()['Answer'].split('>')[1].split('<')[0]
        if ask(f"Your IP address indicates you're in {location}. Connect to VPN?", True):
            vpn['up', 'us'].run_fg()
        peerflix['-kdr', uri].run_fg()
        if ask(f"Disconnect from VPN?", True):
            vpn['down'].run_fg()
    else:
        mpv[uri].run_fg()
