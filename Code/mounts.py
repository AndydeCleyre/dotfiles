#!/usr/bin/env python3

from collections import defaultdict

from plumbum.cmd import mount
from plumbum.colors import green, red, magenta


blacklist = {
    'fs': [
        'cgroup'
    ],
    'point': [
        '/boot/efi', '/sys', '/sys/kernel/security', '/sys/fs/pstore',
        '/proc', '/dev/mqueue', '/sys/fs/cgroup', '/run/user/1000',
        '/run', '/dev/shm', '/dev/hugepages', '/sys/firmware/efi/efivars',
        '/dev', '/dev/pts', '/sys/kernel/debug', '/sys/kernel/config',
        '/proc/sys/fs/binfmt_misc'
    ],
    'device': []
}

filesystems = defaultdict(list)
for line in mount().strip().splitlines():
    device, _on, mount_point, _type, filesystem, options = line.split()
    if filesystem not in blacklist['fs'] and \
    mount_point not in blacklist['point'] and \
    device not in blacklist['device']:
        options = options.strip('()').split(',')
        filesystems[filesystem].append('{}: {} [{}]'.format(
            red | mount_point,
            green | device,
            magenta | ', '.join(options)
        ))
print()
for filesystem in sorted(filesystems):
    print(green | '{}'.format(filesystem), '-' * len(filesystem), sep='\n')
    print('\n'.join(sorted(filesystems[filesystem])), '\n')
    # print((column['-t'] < '\n'.join(sorted(filesystems[filesystem])))())
