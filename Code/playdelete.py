#!/usr/bin/env python3
from sys import argv

from plumbum import local
from plumbum.cmd import mpv
from plumbum.cli.terminal import choose


if __name__ == '__main__':
    for mov in argv[1:]:
        action = "replay"
        while action == "replay":
            mpv(mov)
            action = choose(
                f"What should we do with {mov}?",
                ["let it be", "kill it dead", "replay"],
                "let it be"
            )
        if action == "kill it dead":
            local.path(mov).delete()
            print("SPLAT!")
