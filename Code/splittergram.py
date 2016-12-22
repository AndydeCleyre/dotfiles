#!/usr/bin/env python3

from sys import argv

from plumbum.cmd import split
from plumbum import local, FG


for file in map(local.path, argv[1:]):
    # replace 2 with 1 most of the time, but variable dependent on file size
    # get file size. probably with file.stat()['st_something']
    # divide the size by 1500M
    # 
    split['-b', '1500M', '-d', '-a', '2', '--verbose', file, file.basename + '.'] & FG