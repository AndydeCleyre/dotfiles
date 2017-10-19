#!/usr/bin/env python3
from sys import argv, exit
from random import shuffle

from plumbum import local, ProcessExecutionError
from plumbum.cmd import mpv
from plumbum.cli.terminal import choose


if __name__ == '__main__':
    vids, exts = [], ('mkv', 'mp4', 'flv', 'avi', 'm4v', 'wmv')  # maybe use mimetypes instead
    for path in argv[1:]:
        root = local.path(path)
        vids.extend(root.walk(lambda f: f.lower().rsplit('.', 1)[-1] in exts))
    shuffle(vids)
    for vid in vids:
        action = "replay"
        while action == "replay":
            try:
                mpv(vid)
            except ProcessExecutionError as e:
                print(e)
                break
            try:
                action = choose(
                    f"What should we do with {vid}? (Ctrl-c to quit)",
                    ["let it be", "kill it dead", "replay"],
                    "let it be"
                )
            except KeyboardInterrupt:
                exit(0)
        if action == "kill it dead":
            vid.delete()
            print("SPLAT!")
