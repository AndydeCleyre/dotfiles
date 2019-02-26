#!/usr/bin/env python3

import sys
from contextlib import suppress

from plumbum.cmd import find, grep
from plumbum import ProcessExecutionError, cli


class Finder(cli.Application):
    null = cli.Flag(
        ['0', 'n', 's', 'null', 'spaces'],
        help=r"Delimit results with the null character (\0) rather than newlines."
    )

    def main(self, *args):
        cmd = find['-L', '.', '-iname', f'*{args[0]}*']
        if self.null:
            cmd = cmd['-print0']
        for term in args[1:]:
            cmd = (cmd | grep['-i', term])
        with suppress(ProcessExecutionError):
            (cmd.run_bg(stdout=sys.stdout)).wait()


if __name__ == '__main__':
    Finder()
