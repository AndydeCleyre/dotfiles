#!/usr/bin/env python3

from sys import stdout
from contextlib import suppress

from plumbum.cmd import find, grep
from plumbum import ProcessExecutionError, BG, cli


class Finder(cli.Application):
    null = cli.Flag(
        ['0', 'n', 's', 'null', 'spaces'],
        help=r"Delimit results with the null character (\0) rather than newlines."
    )

    def main(self, *args):
        if self.null:
            cmd = find['-L', '.', '-iname', '*{}*'.format(args[0]), '-print0']
            # cmd = cmd['-print0']
        else:
            cmd = find['-L', '.', '-iname', '*{}*'.format(args[0])]
        for term in args[1:]:
            cmd = (cmd | grep['-i', term])
        with suppress(ProcessExecutionError):
            (cmd & BG(stdout=stdout)).wait()


if __name__ == '__main__':
    Finder.run()
