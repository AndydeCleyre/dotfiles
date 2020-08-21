#!/home/andy/.local/bin/vpy
#!/home/andy/bin/vpy
#!/usr/bin/env python3
import sys
from itertools import count
from contextlib import suppress

from plumbum import local, FG, CommandNotFound


def extract(archive):
    first_choice = local.path(archive).with_suffix('')
    new_folder = first_choice
    c = count()
    while new_folder.exists():
        new_folder = local.path(f'{first_choice}.{next(c)}')
    new_folder.mkdir()
    local['7z']['x', f'-o{new_folder}', archive] & FG
    print(f"Destination: {new_folder}")


if __name__ == '__main__':
    for arg in sys.argv[1:]:
        with suppress(CommandNotFound):
            local['notify-send']('-i', 'ark', 'Extracting . . .', arg)
        extract(arg)
        with suppress(CommandNotFound):
            local['notify-send']('-i', 'ark', 'Finished extracting!', arg)
