#!/usr/bin/env python3

from plumbum.cmd import ark, poweriso, stream_unrar, unrar, notify_send
from plumbum.cli import Application
from plumbum import local


class Extract(Application):

    def is_partial_archive(self, first_file):
        first_file = local.path(first_file)
        # maybe use regex here to match part01, part1, part001,
        # and determine the number of digits to use
        # until then, settle for repetitive code
        # pattern something like "\.part(%d+)\.rar$"
        # or \.part(0*)1\.rar$
        # case-insensitive
        lead = first_file.rsplit('.', 2)[0]
        if first_file.basename.endswith('.part01.rar'):
            next_part = 2
            while True:
                next_str = str(next_part).zfill(2)
                if local.path('{}.part{}.rar.part'.format(lead, next_str)).exists():
                    return True
                elif not local.path('{}.part{}.rar'.format(lead, next_str)).exists():
                    return False
                next_part += 1
        elif first_file.basename.endswith('.part1.rar'):
            part = 2
            while True:
                next_str = str(next_part).zfill(1)
                if local.path('{}.part{}.rar.part'.format(lead, next_str)).exists():
                    return True
                elif not local.path('{}.part{}.rar'.format(lead, next_str)).exists():
                    return False
                part += 1
        return False

    def main(self, *archives):
        if self.is_partial_archive(archives[0]):
            stream_unrar('-a', archives[0], '-d', local.path(archives[0]).dirname)
            notify_send("Extraction complete!")
        else:
            for archive in [local.path(file) for file in archives]:
                if str(archive).casefold().endswith('.dmg'):
                    folder = archive.dirname / archive.basename.rsplit('.', 1)[0]
                    while True:
                        if not folder.exists():
                            break
                        folder = local.path(str(folder) + '.new')
                    poweriso('extract', archive, '/', '-od', folder)
                    notify_send("Extraction complete!")
                else:
                    # temporary modifications while ark has broken rar support
                    #if str(archive).casefold().endswith('.rar'):
                    #    unrar('e', archive)
                    #else:
                    ark('-a', '-b', '-o', local.path(archive).dirname, archive)

if __name__ == '__main__':
    Extract.run()
