#!/usr/bin/env python3
import sys
import re
from contextlib import suppress

from plumbum import local, BG, FG
from plumbum.cli import Application, Flag, SwitchAttr
from plumbum.colors import blue, dark_gray, green, red, yellow
from plumbum.cmd import (
    fdmove,
    lsof,
    pstree,
    s6_log,
    s6_svc,
    s6_svscan,
    s6_svscanctl,
    s6_svstat,
    tail
)

# .s6-svscan/crash  ?
# .s6-svscan/finish ?
SVCS_PATHS = ('./svcs', '../svcs', '~/svcs', '/etc/svcs', '/svcs')


class Essex(Application):
    """Simply manage services"""

    PROGNAME = green
    VERSION = '0.1' | blue
    COLOR_USAGE = green
    COLOR_GROUPS = {'Meta-switches': dark_gray, 'Switches': yellow, 'Subcommands': blue}
    SUBCOMMAND_HELPMSG = False

    svcs_dir = SwitchAttr(
        ['d', 'directory'], argname='SERVICES_DIRECTORY',
        help=f"folder of services to manage; defaults to the first existing match from {SVCS_PATHS}",
    )

    def main(self):
        if self.svcs_dir:
            self.svcs = local.path(self.svcs_dir)
        else:
            for p in SVCS_PATHS:
                folder = local.path(p)
                if folder.is_dir():
                    self.svcs = folder
                    break
            else:
                self.svcs = local.path(SVCS_PATHS[0])
        self.logs = self.svcs.dirname / 'svc-logs'

    # make into decorator?
    def fail_if_unsupervised(self):
        r, out, err = s6_svscanctl[self.svcs].run(retcode=None)
        if r == 100:
            print(f"{self.svcs} not currently supervised." | red, file=sys.stderr)
            sys.exit(1)
        elif r:
            print('\n'.join(filter(None, (out, err))).strip() | red, file=sys.stderr)
            sys.exit(r)


@Essex.subcommand('cat')
class EssexCat(Application):
    """View services' run, finish, and log commands"""

    def main(self, svc_name, *extra_svc_names):
        for svc_name in (svc_name, *extra_svc_names):
            svc = self.parent.svcs / svc_name
            for file in ('run', 'finish'):
                doc = (svc / file)
                if doc.is_file():
                    print(f"{doc | green}:")
                    print(doc.read())
            logger = svc / 'log' / 'run'
            if logger.is_file():
                print(f"{logger | blue}:")
                print(logger.read())


@Essex.subcommand('start')
class EssexStart(Application):
    """Start individual services"""

    def main(self, svc_name, *extra_svc_names):
        self.parent.fail_if_unsupervised()
        s6_svscanctl('-a', self.parent.svcs)
        for svc_name in (svc_name, *extra_svc_names):
            s6_svc['-u', self.parent.svcs / svc_name] & FG


@Essex.subcommand('stop')
class EssexStop(Application):
    """Stop individual services"""

    def main(self, svc_name, *extra_svc_names):
        for svc_name in (svc_name, *extra_svc_names):
            s6_svc['-wD', '-d', self.parent.svcs / svc_name] & FG


@Essex.subcommand('list')
class EssexList(Application):
    """List all known services"""

    enabled_only = Flag(
        ['e', 'enabled'],
        help="only list enabled services (configured to be running)"
    )

    def main(self):
        if self.parent.svcs.is_dir():
            if self.enabled_only:
                print('\n'.join(p for p in self.parent.svcs if 'run' in p and 'down' not in p))
            else:
                print('\n'.join(p for p in self.parent.svcs if 'run' in p))


@Essex.subcommand('status')
class EssexStatus(Application):
    """View the current states of services"""

    enabled_only = Flag(
        ['e', 'enabled'],
        help="only list enabled services (configured to be running)"
    )

    def main(self, *svc_names):
        self.parent.fail_if_unsupervised()
        s6_svscanctl('-a', self.parent.svcs)
        errors = False
        for svc in svc_names or (p for p in self.parent.svcs if 'run' in p):
            svc = self.parent.svcs / svc
            if 'run' in svc:
                if self.enabled_only and 'down' in svc:
                    continue
                statline = s6_svstat(svc)
                try:
                    d = parse_statline(statline)
                except AttributeError:
                    print(statline | blue)
                else:
                    statline = '\t'.join(filter(None, (
                        f"{svc.name}:",
                        d['runstate'],
                        d['pid_exitcode_num'],
                        f"(configured to be {d['enabledstate']})" if d['enabledstate'] else False
                    )))
                    print(statline | (green if d['runstate'] == 'up' else red))
            else:
                print(f"{svc} doesn't exist" | red, file=sys.stderr)
                errors = True
        if errors:
            sys.exit(1)


def parse_statline(statline):
    # ptrn = r'(?P<runstate>up|down) \((?P<pid_exitcode>pid|exitcode) (?P<pid_exitcode_num>\d+)\) \d+ seconds(, normally (?P<enabledstate>up|down))?(, ready \d+ seconds)?'
    ptrn = r'(?P<runstate>up|down) \((?P<pid_exitcode>pid|exitcode) (?P<pid_exitcode_num>\d+)\) \d+ seconds(, normally (?P<enabledstate>up|down))?.*'
    return re.match(ptrn, statline).groupdict()


@Essex.subcommand('tree')
class EssexTree(Application):
    """View the process tree from the supervision root"""

    def main(self):
        self.parent.fail_if_unsupervised()
        pstree[
            '-apT', lsof('-t', self.parent.svcs / '.s6-svscan' / 'control').splitlines()[0]
        ] & FG


@Essex.subcommand('enable')
class EssexEnable(Application):
    """Configure individual services to be up, without actually starting them"""

    def main(self, svc_name, *extra_svc_names):
        errors = False
        for svc_name in (svc_name, *extra_svc_names):
            svc = self.parent.svcs / svc_name
            if svc.is_dir():
                (svc / 'down').delete()
            else:
                print(f"{svc} doesn't exist" | red, file=sys.stderr)
                errors = True
        if errors:
            sys.exit(1)


@Essex.subcommand('disable')
class EssexDisable(Application):
    """Configure individual services to be down, without actually stopping them"""

    def main(self, svc_name, *extra_svc_names):
        errors = False
        for svc_name in (svc_name, *extra_svc_names):
            svc = self.parent.svcs / svc_name
            if svc.is_dir():
                (svc / 'down').touch()
            else:
                print(f"{svc} doesn't exist" | red, file=sys.stderr)
                errors = True
        if errors:
            sys.exit(1)


@Essex.subcommand('on')
class EssexOn(Application):
    """Start supervising all services"""

    def main(self):
        r, out, err = s6_svscanctl[self.parent.svcs].run(retcode=None)
        if r == 100:
            (
                fdmove['-c', '2', '1'][s6_svscan][self.parent.svcs] |
                s6_log['T', self.parent.logs / '.svscan']
            ) & BG
        elif r:
            print('\n'.join(filter(None, (out, err))).strip() | red, file=sys.stderr)
            sys.exit(r)
        else:
            print(self.parent.svcs, "already supervised" | yellow, file=sys.stderr)


@Essex.subcommand('off')
class EssexOff(Application):
    """Stop all services and their supervision"""

    def main(self):
        self.parent.fail_if_unsupervised()
        s6_svscanctl['-anpt', self.parent.svcs] & FG


@Essex.subcommand('sync')
class EssexSync(Application):
    """Start or stop services to match their configuration"""

    def main(self, *svc_names):
        self.parent.fail_if_unsupervised()
        s6_svscanctl['-an', self.parent.svcs] & FG
        for svc in svc_names or (p for p in self.parent.svcs if 'run' in p):
            svc = self.parent.svcs / svc
            s6_svc['-d' if (svc / 'down').exists() else '-u', svc] & FG


@Essex.subcommand('log')
class EssexLog(Application):
    """View a service's log"""

    lines = SwitchAttr(
        ['n', 'lines'], argname='LINES',
        help="print only the last LINES lines from the service's current log file, or prepend a '+' to start at line LINES",
        default='+1'
    )

    follow = Flag(
        ['f', 'follow'],
        help="continue printing new lines as they are added to the log file"
    )

    def main(self, svc_name='.svscan'):
        log = self.parent.logs / svc_name / 'current'
        if self.follow:
            with suppress(KeyboardInterrupt):
                tail['-n', self.lines, '--follow=name', log] & FG
        else:
            tail['-n', self.lines, log] & FG


# cron-like --
# -O : mark the service to run once at most. iow: do not restart the supervised process when it dies. If it is down when the command is received, do not even start it.

@Essex.subcommand('sig')
class EssexSignal(Application):
    """Send a signal to a service"""

# use plumbum's Set validator?
    def main(self, signal, svc_name, *extra_svc_names):
        sigs = {
            'alrm': 'a', 'abrt': 'b', 'quit': 'q',
            'hup': 'h', 'kill': 'k', 'term': 't',
            'int': 'i', 'usr1': '1', 'usr2': '2',
            'stop': 'p', 'cont': 'c', 'winch': 'y'
        }
        try:
            sig = sigs[signal]
        except KeyError:
            print(f"Unknown signal '{signal}'. Expecting one of:" | red, *sigs.keys(), file=sys.stderr)
            sys.exit(1)
        for svc_name in (svc_name, *extra_svc_names):
            s6_svc[f'-{sig}', self.parent.svcs / svc_name] & FG


@Essex.subcommand('new')
class EssexNew(Application):
    """Create a new service"""

    as_user = SwitchAttr(
        ['u', 'as-user'], argname='USERNAME',
        help="non-root user to run the new service as (only works for root)"
    )

    enabled = Flag(
        ['e', 'enable'],
        help="enable the new service after creation"
    )

    on_finish = SwitchAttr(
        ['f', 'finish'], argname='FINISH_CMD',
        help="command to run whenever the supervised process dies (must complete in under 5 seconds)"
    )

    def main(self, svc_name, cmd):
        svc = self.parent.svcs / svc_name
        if svc.exists():
            print(f"{svc} already exists!" | red, file=sys.stderr)
            sys.exit(1)
        svc.mkdir()
        set_user = f's6-setuidgid {self.as_user} ' if self.as_user else ''
        runfile = (svc / 'run')
        runfile.write(f"#!/bin/execlineb -P\nfdmove -c 2 1 {set_user}{cmd}")
        runfile.chmod(0o755)
        if not self.enabled:
            (svc / 'down').touch()
        logger = svc / 'log'
        logger.mkdir()
        runfile = logger / 'run'
        runfile.write(f"#!/bin/execlineb -P\n{set_user}s6-log T {self.parent.logs / svc.name}")
        runfile.chmod(0o755)
        (self.parent.logs / svc.name).mkdir()
        if self.on_finish:
            runfile = (svc / 'finish')
            runfile.write(f"#!/bin/execlineb\nfdmove -c 2 1 {set_user}{self.on_finish}")
            runfile.chmod(0o755)


# @Essex.subcommand('zsh')
# class EssexZsh(Application):
    # """Create a zsh completion file"""
#
    # def main(self, outfile='./_essex'):
        # outfile = local.path(outfile)
        # if outfile.is_dir():
            # outpfile /= '_essex'
        # if outfile.exists():
            # if input(f"Really overwrite {outfile} ? [yN] ").lower() not in ('y', 'yes'):
                # exit(1)
        # txt = local['essex']('-h')
        # subcmds = re.findall(r'^    (\w+) +(\w.*)$', txt, re.M)
        descs = ' '.join(f"'{cmd}:{desc}'" for cmd, desc in subcmds)
        descs = ' '.join(f"'{cmd}:{desc.replace('\'', r'\'')}'" for cmd, desc in subcmds)
        descs = ' '.join(f"'{cmd}:" + desc.replace("'", r"\'") + "'" for cmd, desc in subcmds)
        # descs = ' '.join(f"'{cmd}:" + desc.replace("'", '') + "'" for cmd, desc in subcmds)
        # outfile.write(f"#compdef _essex\n_describe 'command' ({descs})\n")


if __name__ == '__main__':
    for app in (
        EssexCat, EssexDisable, EssexEnable, EssexList, EssexLog,
        EssexNew, EssexOff, EssexOn, EssexSignal, EssexStart,
        EssexStatus, EssexStop, EssexSync, EssexTree
    ):
        app.unbind_switches('help-all', 'v', 'version')
    Essex.run()
