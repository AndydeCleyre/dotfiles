#!/usr/bin/env python3
import sys
from contextlib import suppress
from hashlib import md5

from plumbum import local, CommandNotFound
from plumbum.cli import Application, Flag, SwitchAttr, Range
from plumbum.colors import blue, dark_gray, green, red, yellow
from plumbum.cmd import (
    s6_log, s6_svc, s6_svscan, s6_svscanctl, s6_svstat,
    fdmove, lsof, pstree, tail
)


# TO CONSIDER:
# .s6-svscan/crash?
# .s6-svscan/finish poweroff? (kill after timeout?)
# timeouts?
# check env var for SVCS_PATHS?
# EssexOff doesn't wait for hanging procs?


class ColorApp(Application):
    PROGNAME = green
    VERSION = '0.1' | blue
    COLOR_USAGE = green
    COLOR_GROUPS = {'Meta-switches': dark_gray, 'Switches': yellow, 'Subcommands': blue}
    ALLOW_ABBREV = True


class Essex(ColorApp):
    """Simply manage services"""

    SUBCOMMAND_HELPMSG = False
    DEFAULT_PATHS = ('./svcs', '~/svcs', '/etc/svcs', '/svcs')

    svcs_dir = SwitchAttr(
        ['d', 'directory'], argname='SERVICES_DIRECTORY',
        help=(
            "folder of services to manage; "
            f"defaults to the first existing match from {DEFAULT_PATHS}, "
            'unless a colon-delimited SERVICES_PATHS env var exists;'
        )
    )

    logs_dir = SwitchAttr(
        ['l', 'logs-directory'], argname='SERVICES_LOGS_DIRECTORY',
        help=(
            "folder of services' log files; "
            f"defaults to SERVICES_DIRECTORY/../svcs-logs"
        )
    )

    def main(self):
        if self.svcs_dir:
            self.svcs_dir = local.path(self.svcs_dir)
        else:
            try:
                svcs_paths = local.env['SERVICES_PATHS'].split(':')
            except KeyError:
                svcs_paths = self.DEFAULT_PATHS
            for folder in map(local.path, svcs_paths):
                if folder.is_dir():
                    self.svcs_dir = folder
                    break
            else:
                self.svcs_dir = local.path(svcs_paths[0])
        self.svcs_dir.mkdir()
        self.logs = self.logs_dir or self.svcs_dir.up() / 'svcs-logs'
        self.svcs = tuple(f for f in self.svcs_dir if 'run' in f)

    def fail_if_unsupervised(self):
        r, out, err = s6_svscanctl[self.svcs_dir].run(retcode=None)
        if r == 100:
            print(f"{self.svcs_dir} not currently supervised." | red, file=sys.stderr)
            sys.exit(1)
        elif r:
            print('\n'.join(filter(None, (out, err))).strip() | red, file=sys.stderr)
            sys.exit(r)

    def is_up(self, svc_name):
        return s6_svstat('-o', 'up', self.svcs_dir / svc_name).strip() == 'true'

    def stop(self, svc, announce=False):
        if announce:
            print("Stopping", svc, ". . .")
        s6_svc['-wD', '-d', svc].run_fg()

    def start(self, svc, announce=False):
        if announce:
            print("Starting", svc)
        s6_svc['-u', svc].run_fg()


@Essex.subcommand('cat')
class EssexCat(ColorApp):
    """View services' run, finish, and log commands"""

    def main(self, svc_name, *extra_svc_names):

        def display(docpath, color=green):
            try:
                local['bat'][docpath, '-l', 'sh'].run_fg()
            except CommandNotFound:
                over, under = map(lambda c: c * (len(docpath) + 1), '━─')
                print(f"{over}\n{docpath | color}:\n{under}")
                try:
                    local['highlight'][
                        '--stdout',
                        '--syntax', 'sh',
                        '--out-format', 'truecolor',
                        '--style', 'lucretia',
                        docpath
                    ].run_fg()
                except CommandNotFound:
                    print(docpath.read())

        for svc in (
            self.parent.svcs_dir / sn
            for sn in (svc_name, *extra_svc_names)
        ):
            for file in ('run', 'finish', 'crash'):
                # if (doc := svc / file).is_file():
                doc = svc / file  #
                if doc.is_file():  #
                    display(doc)
            # if (logger := svc / 'log' / 'run').is_file():
            logger = svc / 'log' / 'run'  #
            if logger.is_file():  #
                display(logger, blue)


@Essex.subcommand('start')
class EssexStart(ColorApp):
    """Start individual services"""

    def main(self, svc_name, *extra_svc_names):
        self.parent.fail_if_unsupervised()
        s6_svscanctl('-a', self.parent.svcs_dir)
        for svc in (
            self.parent.svcs_dir / sn
            for sn in (svc_name, *extra_svc_names)
        ):
            self.parent.start(svc)


@Essex.subcommand('stop')
class EssexStop(ColorApp):
    """Stop individual services"""

    def main(self, svc_name, *extra_svc_names):
        for svc in (
            self.parent.svcs_dir / sn
            for sn in (svc_name, *extra_svc_names)
        ):
            self.parent.stop(svc, announce=True)


@Essex.subcommand('list')
class EssexList(ColorApp):
    """List all known services"""

    enabled_only = Flag(
        ['e', 'enabled'],
        help="only list enabled services (configured to be running)"
    )

    def main(self):
        if self.parent.svcs_dir.is_dir():
            if self.enabled_only:
                print(*(s for s in self.parent.svcs if 'down' not in s), sep='\n')
            else:
                print(*self.parent.svcs, sep='\n')


@Essex.subcommand('status')
class EssexStatus(ColorApp):
    """View the current states of (all or specified) services"""

    enabled_only = Flag(
        ['e', 'enabled'],
        help="only list enabled services (configured to be running)"
    )

    def main(self, *svc_names):
        self.parent.fail_if_unsupervised()
        s6_svscanctl('-a', self.parent.svcs_dir)
        cols = (
            'up',
            'wantedup',
            'normallyup',
            'ready',
            'paused',
            'pid',
            'exitcode',
            'signal',
            'signum',
            'updownsince',
            'readysince',
            'updownfor',
            'readyfor'
        )
        errors = False
        for svc in (
            self.parent.svcs_dir / sn
            for sn in (svc_names or self.parent.svcs)
        ):
            if 'run' in svc:
                if self.enabled_only and 'down' in svc:
                    continue
                stats = {
                    col: False if val == 'false' else val
                    for col, val in zip(
                        cols, s6_svstat('-o', ','.join(cols), svc).split()
                    )
                }
                statline = f"{svc.name:<20} {'up' if stats['up'] else 'down':<5} {stats['updownfor'] + 's':<10} {stats['pid'] if stats['pid'] != '-1' else stats['exitcode']:<6} {'autorestarts' if stats['wantedup'] else '':<13} {'autostarts' if stats['normallyup'] else '':<11}"
                print(statline | (green if stats['up'] else red))
            else:
                print(f"{svc} doesn't exist" | red, file=sys.stderr)
                errors = True
        if errors:
            sys.exit(1)


@Essex.subcommand('tree')
class EssexTree(ColorApp):
    """View the process tree from the supervision root"""

    def main(self):
        self.parent.fail_if_unsupervised()
        pstree[
            '-apT', lsof('-t', self.parent.svcs_dir / '.s6-svscan' / 'control').splitlines()[0]
        ].run_fg()


@Essex.subcommand('enable')
class EssexEnable(ColorApp):
    """Configure individual services to be up, without actually starting them"""

    def main(self, svc_name, *extra_svc_names):
        errors = False
        for svc in (
            self.parent.svcs_dir / sn
            for sn in (svc_name, *extra_svc_names)
        ):
            if svc.is_dir():
                (svc / 'down').delete()
            else:
                print(f"{svc} doesn't exist" | red, file=sys.stderr)
                errors = True
        if errors:
            sys.exit(1)


@Essex.subcommand('disable')
class EssexDisable(ColorApp):
    """Configure individual services to be down, without actually stopping them"""

    def main(self, svc_name, *extra_svc_names):
        errors = False
        for svc in (
            self.parent.svcs_dir / sn
            for sn in (svc_name, *extra_svc_names)
        ):
            if svc.is_dir():
                (svc / 'down').touch()
            else:
                print(f"{svc} doesn't exist" | red, file=sys.stderr)
                errors = True
        if errors:
            sys.exit(1)


@Essex.subcommand('on')
class EssexOn(ColorApp):
    """Start supervising all services"""

    def main(self):
        r, out, err = s6_svscanctl[self.parent.svcs_dir].run(retcode=None)
        if r == 100:
            (
                fdmove['-c', '2', '1'][s6_svscan][self.parent.svcs_dir] |
                s6_log['T', self.parent.logs / '.svscan']
            ).run_bg()
        elif r:
            print('\n'.join(filter(None, (out, err))).strip() | red, file=sys.stderr)
            sys.exit(r)
        else:
            print(self.parent.svcs_dir, "already supervised" | yellow, file=sys.stderr)


@Essex.subcommand('off')
class EssexOff(ColorApp):
    """Stop all services and their supervision"""

    def main(self):
        self.parent.fail_if_unsupervised()
        for svc in self.parent.svcs:
            self.parent.stop(svc, announce=self.parent.is_up(svc))
            # yes, even when not is_up, to catch failed-start loops
            # timeout? (s6-svc -T milliseconds)
        s6_svscanctl['-anpt', self.parent.svcs_dir].run_fg()


@Essex.subcommand('sync')
class EssexSync(ColorApp):
    """Start or stop services to match their configuration"""

    def main(self, *svc_names):
        self.parent.fail_if_unsupervised()
        s6_svscanctl['-an', self.parent.svcs_dir].run_fg()
        for svc in (
            self.parent.svcs_dir / sn
            for sn in (svc_names or self.parent.svcs)
        ):
            is_up = self.parent.is_up(svc)
            if (svc / 'down').exists():
                self.parent.stop(svc, announce=is_up)
                # yes, even when not is_up, to catch failed-start loops
                # timeout? (s6-svc -T milliseconds)
            elif not is_up:
                self.parent.start(svc, announce=True)


@Essex.subcommand('reload')
class EssexReload(ColorApp):
    """Restart (all or specified) running services whose run scripts have changed"""

    def main(self, *svc_names):
        self.parent.fail_if_unsupervised()
        for svc in (
            self.parent.svcs_dir / sn
            for sn in (svc_names or self.parent.svcs)
            if self.parent.is_up(sn)
        ):
            for run, run_md5 in ((
                svc / 'run',
                svc / 'run.md5'
            ), (
                svc / 'log' / 'run',
                svc / 'log' / 'run.md5'
            )):
                if run_md5.is_file():
                    if md5(run.read().encode()).hexdigest() != run_md5.read().split()[0]:
                        self.parent.stop(svc, announce=True)
                        self.parent.start(svc, announce=True)
                        break


@Essex.subcommand('log')
class EssexLog(ColorApp):
    """View a service's log"""

    lines = SwitchAttr(
        ['n', 'lines'], argname='LINES',
        help=(
            "print only the last LINES lines from the service's current log file, "
            "or prepend a '+' to start at line LINES"
        ),
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
                tail['-n', self.lines, '--follow=name', log].run_fg()
        else:
            tail['-n', self.lines, log].run_fg()


@Essex.subcommand('sig')
class EssexSignal(ColorApp):
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
            print(
                f"Unknown signal '{signal}'. Expecting one of:" | red,
                *sigs.keys(),
                file=sys.stderr
            )
            sys.exit(1)
        for svc in (
            self.parent.svcs_dir / sn
            for sn in (svc_name, *extra_svc_names)
        ):
            s6_svc[f'-{sig}', svc].run_fg()


@Essex.subcommand('new')
class EssexNew(ColorApp):
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
        help=(
            "command to run whenever the supervised process dies "
            "(must complete in under 5 seconds)"
        )
    )

    rotate_at = SwitchAttr(
        ['r', 'rotate-at'], Range(1, 256), argname='MEBIBYTES',
        help="archive each log file when it reaches MEBIBYTES mebibytes",
        default=4
    )

    prune_at = SwitchAttr(
        ['p', 'prune-at'], Range(0, 1024), argname='MEBIBYTES',
        help=(
            "keep up to MEBIBYTES mebibytes of logs before deleting the oldest; "
            "0 means never prune"
        ),
        default=40
    )

    on_rotate = SwitchAttr(
        ['o', 'on-rotate'], argname='PROCESSOR_CMD',
        help=(
            "processor command to run when rotating logs; "
            "receives log via stdin; "
            "its stdout is archived; "
            "PROCESSOR_CMD will be double-quoted"
        )
    )

    # TODO: use skabus-dyntee for socket-logging? maybe
    def main(self, svc_name, cmd):
        svc = self.parent.svcs_dir / svc_name
        if svc.exists():
            print(f"{svc} already exists!" | red, file=sys.stderr)
            sys.exit(1)
        logger = svc / 'log'

        svc.mkdir()
        logger.mkdir()
        (self.parent.logs / svc.name).mkdir()

        shebang = '#!/bin/execlineb -P\n'
        set_user = f's6-setuidgid {self.as_user}  # Run as this user\n' if self.as_user else ''
        hash_run = 'foreground { redirfd -w 1 run.md5 md5sum run }  # Generate hashfile, to detect changes since launch\n'
        err_to_out = 'fdmove -c 2 1  # Send stderr to stdout\n'

        runfile = svc / 'run'
        runfile.write(f"{shebang}{hash_run}{err_to_out}{set_user}{cmd}")
        runfile.chmod(0o755)

        if not self.enabled:
            (svc / 'down').touch()

        logfile = self.parent.logs / svc.name
        rotate = f's{self.rotate_at * 1024 ** 2}  # Archive log when it gets this big (bytes)\n'
        prune = f'S{self.prune_at * 1024 ** 2}  # Purge oldest archived logs when the archive gets this big (bytes)\n'
        process = f'!"{self.on_rotate}"  # Processor (log --stdin--> processor --stdout--> archive)\n' if self.on_rotate else ''
        timestamp = 'T  # Start each line with an ISO 8601 timestamp\n'

        runfile = logger / 'run'
        runfile.write(f"{shebang}{hash_run}s6-log\n{timestamp}{rotate}{prune}{process}{logfile}")
        runfile.chmod(0o755)

        if self.on_finish:
            runfile = svc / 'finish'
            runfile.write(f"#!/bin/execlineb\n{err_to_out}{set_user}{self.on_finish}")
            runfile.chmod(0o755)


if __name__ == '__main__':
    for app in (
        EssexCat, EssexDisable, EssexEnable, EssexList, EssexLog,
        EssexNew, EssexOff, EssexOn, EssexSignal, EssexStart,
        EssexStatus, EssexStop, EssexSync, EssexTree
    ):
        app.unbind_switches('help-all', 'v', 'version')
    Essex()
