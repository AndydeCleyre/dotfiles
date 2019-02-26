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
        try:
            pid, name = pid_name.split('/', 1)
        except ValueError:
            pid, name = '--'
            # pid, name = (pid_name,) * 2
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
    name, protos, addrs = map(
        lambda k: ','.join(sorted(ports[port][k])),
        ('name', 'proto', 'address')
    )
    line = f"{port:<7}{name:<16}{protos:<10}{addrs}"
    print(colors[name] | line)
