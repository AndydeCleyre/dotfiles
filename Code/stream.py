#!/home/andy/bin/vpy
#!/usr/bin/env python3

import os
import re
import sys
from typing import NamedTuple
from time import sleep
from contextlib import suppress
from hashlib import md5

from requests import get
from plumbum import local, ProcessExecutionError, CommandNotFound, FG
from plumbum.cli.terminal import ask
from plumbum.cmd import (
    kill,
    mpv,
    pgrep,
    ps,
    s6_log,
    tail,
    transmission_cli as tmcli,
    xclip,
)
from plumbum.colors import green, yellow, blue, red


vpn = local['~/Code/vpn.py']
try:
    tree = local['lsd']['--tree']
except CommandNotFound:
    tree = local['tree']['-C']


def guess_video(folder, ignore=('logs',)):
    ignore_dirs = [folder / i for i in ignore]
    return sorted(
        folder.walk(lambda f: all((
            f.is_file(),
            f not in ignore_dirs,
            not any(f in igd for igd in ignore_dirs)
        ))),
        key=lambda f: f.stat().st_size,
        reverse=True
    )[0]


class Proc(NamedTuple):
    pid: str
    cmd: str


def guess_tm_proc(*exclude):
    this_pid = os.getpid()
    family_pids = pgrep('-P', this_pid).split()
    for pid in family_pids:
        if pid not in (this_pid, *exclude):
            cmd = ps('-o', 'cmd=', pid).strip()
            if cmd.split()[0].endswith('/transmission-cli'):
                return Proc(pid, cmd)


def uri_folder(uri, parent='~/Downloads/transmission'):
    return local.path(parent) / md5(uri.encode()).hexdigest()


def clear():
    print(chr(27) + "[2J")


def transmission_stream(uri):
    folder = uri_folder(uri)
    logs = folder / 'logs'
    logs.mkdir()
    (
        tmcli['-seq', '--download-dir', folder, uri] |
        s6_log['t', 's4194304', 'S41943040', logs]
    ).run_bg()
    tm = guess_tm_proc()
    print("Starting sequential torrent download" | green, f"<{tm.cmd | yellow}> ({tm.pid | yellow})")
    while True:
        clear()
        try:
            loot = [p for p in folder if p != logs].pop()
        except IndexError:
            print(f"\n>>Waiting for content in {folder} . . ." | yellow)
            sleep(6)
            continue
        tree[loot] & FG
        tail['-n', 1, logs / 'current'] & FG
        try:
            video = guess_video(folder)
        except (FileNotFoundError, IndexError):
            print(f"\n>>Waiting for content in {folder} . . ." | yellow)
            sleep(6)
            continue
        print(
            f"Looks like you want to watch {video.name | yellow}",
            f"({round(video.stat().st_size / 1048576)} MiB) now."
        )
        if ask("\nIs that right" | green, False):
            try:
                mpv[video] & FG
                replay = False
            except ProcessExecutionError as e:
                print(e, file=sys.stderr)
                replay = True
            if ask("\nTry to play again" | green, replay):
                continue
            break
    tail['-n', 1, logs / 'current'] & FG
    return {'proc': tm, 'folder': folder}


def suggest_vpn(disconnect=False):
    r = get('https://api.duckduckgo.com', {'q': 'ip', 'format': 'json'})
    location = r.json()['Answer'].split('>')[1].split('<')[0]
    print(f"Your IP address indicates you're in {location | yellow}.")
    print(vpn('status').strip() | blue)
    if disconnect:
        if ask(f"\nDisconnect from VPN" | green, True):
            vpn['down'] & FG
    elif ask(f"\nConnect to VPN" | green, True):
        vpn['up', 'us'] & FG


def main():
    uris = sys.argv[1:] or xclip('-sel', 'clip', '-o').splitlines()
    for uri in uris:
        uri = re.sub(r'^stream:/?/?', '', uri)
        if not (uri.startswith('magnet:?xt=urn:btih:') or uri.endswith('.torrent')):
            mpv[uri] & FG
            sys.exit()
        suggest_vpn()
        try:
            transmission_stream(uri)
        except (ProcessExecutionError, KeyboardInterrupt) as e:
            print(e, file=sys.stderr)
        finally:
            tm = guess_tm_proc()
            folder = uri_folder(uri)
            if ask(f"\nKill <{tm.cmd | yellow}> ({tm.pid | yellow}) now", True):
                kill(tm.pid)
        suggest_vpn(disconnect=True)
        if ask(
            f"\n{'Delete' | red} {folder} "
            f"{[f.name for f in folder.list() if f.name not in ('logs',)]}",
            False
        ):
            folder.delete()



if __name__ == '__main__':
    main()
