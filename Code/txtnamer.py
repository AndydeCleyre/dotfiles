#!/usr/bin/env python3

"""Rename multiple files with Sublime Text."""

from sys import argv

from plumbum import local
from plumbum.colors import red, green
from plumbum.cmd import konsole


edit = konsole['-e', 'micro']
old_names = argv[1:] or local.path().list()
with local.tempdir() as tmp:
    name_file = tmp / 'txtnamer_names'
    name_file.write('\n'.join(old_names), 'utf8')
    edit(name_file)
    new_names = name_file.read('utf8').strip().splitlines()
if len(new_names) == len(old_names):
    for old_path, new_path in zip(
        map(local.path, old_names), map(local.path, new_names)
    ):
        if old_path != new_path:
            print(old_path.name | red, new_path.name | green, '', sep='\n')
            old_path.move(new_path)
