#!/usr/bin/env python3

from sys import argv

from plumbum.cmd import tree
from plumbum import FG, local
from plumbum.cli import Application, SwitchAttr


class Tree(Application):

    default_depth = '3'

    def main(self, folder='.', depth=None):
        if folder.isdigit() and not(local.path(folder).isdir() and depth and depth.isdigit()):
            depth, folder = folder, depth or '.'
        _tree = tree['-C', '-L', depth or self.default_depth, folder]
        pager = local[local.env['PAGER']]
        (_tree | pager) & FG


if __name__ == '__main__':
    Tree.run()
