#!/usr/bin/env python3
import sys
from itertools import count
from contextlib import suppress

from plumbum import local, FG, CommandNotFound


def extract(archive):
    new_folder = local.path(archive.rsplit('.', 1)[0])
    c = count()
    while new_folder.exists():
        new_folder = local.path(f'{new_folder}.{next(c)}')
    new_folder.mkdir()
    local['7z']['x', f'-o{new_folder}', archive] & FG


if __name__ == '__main__':
    for arg in sys.argv[1:]:
        with suppress(CommandNotFound):
            local['notify-send']('-i', '/usr/share/icons/Papirus/64x64/apps/ark.svg', 'Extracting . . .', arg)
        extract(arg)
        with suppress(CommandNotFound):
            local['notify-send']('-i', '/usr/share/icons/Papirus/64x64/apps/ark.svg', 'Finished extracting!', arg)
