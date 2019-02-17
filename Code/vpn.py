#!/usr/bin/env python3
from plumbum import local
from plumbum.cmd import wg, wg_quick
from plumbum.cli.terminal import choose
from plumbum.cli import Application, Set, SwitchAttr


LOCATIONS = ('ca', 'es', 'se', 'uk', 'us')


def current():
    try:
        with local.as_root():
            return wg('show').splitlines()[0].split(': ')[-1]
    except IndexError:
        return None


def print_status():
    print(current() or "Not connected")


def connect(location=None, default=None):
    if location:
        with local.as_root():
            wg_quick('up', f'azirevpn-{location}1')
    else:
        try:
            choice = choose("Where to?", LOCATIONS, default)
        except KeyboardInterrupt:
            print()
        else:
            with local.as_root():
                wg_quick('up', f'azirevpn-{choice}1')


class VPNController(Application):

    def main(self):
        if not self.nested_command:
            print_status()


@VPNController.subcommand('up')
class VPNConnector(Application):

    default_location = SwitchAttr(['default-location', 'd'], default='us')

    def main(self, location: Set(*LOCATIONS)=None):
        connect(location, self.default_location)
        print_status()


@VPNController.subcommand('down')
class VPNDisconnector(Application):

    def main(self):
        # if (vpn := current()):
        vpn = current()  #
        if vpn:  #
            with local.as_root():
                wg_quick('down', vpn)
        print_status()


@VPNController.subcommand('status')
class VPNStatusPrinter(Application):

    def main(self):
        print_status()


if __name__ == '__main__':
    VPNController()
