#!/usr/bin/env python3
import sys
from configparser import ConfigParser
from itertools import cycle

from plumbum import local
from plumbum.cli import Application
from plumbum.cmd import (
    kreadconfig5 as kread,
    kwriteconfig5 as kwrite,
    latte_dock,
    kwin_x11 as kwin,
    kstart5 as kstart,
    kquitapp5 as kquit
)


CFG = local.path('~/.config/kdeglobals')
SCHEME_PATHS = ('~/.local/share/color-schemes', '/usr/share/color-schemes')


def get_current_scheme():
    return kread('--file', CFG, '--group', 'General', '--key', 'ColorScheme').strip()


def get_next_scheme(all_schemes):
    schemes = cycle(all_schemes)
    old_scheme = get_current_scheme()
    if old_scheme in schemes:
        new_scheme = next(schemes)
        while new_scheme != old_scheme:
            new_scheme = next(schemes)
    return next(schemes)


class Rotator(Application):

    def hooks(self):
        local['~/Code/fix-tg-icons.sh'].run_fg()
        latte_dock['-r'].run_bg(stdout=sys.stdout, stderr=sys.stderr)
        kwin['--replace'].run_bg(stdout=sys.stdout, stderr=sys.stderr)
        kquit('krunner')
        kstart['krunner'].run_bg(stdout=sys.stdout, stderr=sys.stderr)

    def main(self, *schemes):
        schemes = schemes or ('MacaroniTimeInverted', 'MacaroniTime')
        cp = ConfigParser()
        cp.optionxform = str
        next_scheme = get_next_scheme(schemes)
        for path in SCHEME_PATHS:
            scheme_path = local.path(path) / f'{next_scheme}.colors'
            if scheme_path.is_file():
                break
        else:
            sys.exit(f"Scheme {next_scheme} not found in {SCHEME_PATHS}")
        cp.read(scheme_path)
        for section in cp.values():
            if section:
                for key, val in section.items():
                    kwrite('--file', CFG, '--group', section.name, '--key', key, val)
        self.hooks()


if __name__ == '__main__':
    Rotator()

# TODO:
# - konsole
# - gtk
