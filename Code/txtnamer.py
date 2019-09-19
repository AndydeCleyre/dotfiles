#!/home/andy/bin/vpy
#!/usr/bin/env python3
"""Rename multiple files with any text editor."""

from sys import argv

from plumbum import local
from plumbum.colors import red, green


old_names = argv[1:] or local.cwd.list()
with local.tempdir() as tmp:
    names_file = tmp / 'txtnamer_names'
    names_file.write('\n'.join(old_names))
    local[local.env['EDITOR']](names_file)
    new_names = names_file.read().strip().splitlines()
if len(new_names) == len(old_names):
    for old_path, new_path in zip(
        map(local.path, old_names), map(local.path, new_names)
    ):
        if old_path != new_path:
            print(
                old_path.name | red,
                new_path.name | green, '', sep='\n'
            )
            old_path.move(new_path)
