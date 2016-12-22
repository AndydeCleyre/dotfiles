#!/usr/bin/env python3

from itertools import cycle
from collections import defaultdict

from plumbum.cmd import netstat, sudo
from plumbum.colors import cyan, yellow, green, red, magenta, blue, white, black


ports = defaultdict(lambda: defaultdict(set))
for line in sudo(netstat['-lnptu']).split('\n'):
    if line.startswith('tcp') or line.startswith('udp'):
        proto, _, _, address_port, *_, pid_name = line.split()
        if not pid_name[0].isdigit():
            for word in line.split()[-2::-1]:
                pid_name = ' '.join((word, pid_name))
                if pid_name[0].isdigit():
                    break
        pid, name = pid_name.split('/', 1)
        address, port = address_port.rsplit(':', 1)
        port = int(port)
        ports[port]['name'].add(name)
        ports[port]['proto'].add(proto)
        ports[port]['address'].add(address)
colors = {n: c for n, c in zip(
    {','.join(sorted(ports[p]['name'])) for p in ports},
    cycle([blue, cyan, green, red, magenta, yellow, white, black])
)}
for port in sorted(ports):
    name = ','.join(sorted(ports[port]['name']))
    line = '{:<7}{:<16}{:<10}{}'.format(
        port, name,
        ','.join(sorted(ports[port]['proto'])),
        ','.join(sorted(ports[port]['address']))
    )
    print(colors[name] | line)
