#!/usr/bin/env python3
from sys import argv, exit
from contextlib import suppress

from plumbum.cmd import locate, grep
from plumbum import ProcessExecutionError


cmd = locate['-i', argv[1]]
for term in argv[2:]:
    cmd = (cmd | grep['-i', term])
with suppress(ProcessExecutionError):
    try:
        cmd.run_fg()
    except KeyboardInterrupt:
        print("\nSearch Canceled")
        exit(1)

