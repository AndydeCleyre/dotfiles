#!/usr/bin/env python3
from sys import argv
from contextlib import suppress
from plumbum.cmd import locate, grep
from plumbum import FG, ProcessExecutionError

cmd = locate['-i', argv[1]]
for term in argv[2:]:
    cmd = (cmd | grep['-i', term])
with suppress(ProcessExecutionError):
    cmd & FG

