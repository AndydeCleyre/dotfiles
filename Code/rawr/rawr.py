#!/home/andy/.local/bin/vpy
#!/usr/bin/env python3
import sys

from plumbum import FG
from plumbum.cli.terminal import choose
from plumbum.cmd import aria2c
from plumbum.colors import blue, green, magenta, yellow
from rarbgapi import RarbgAPI


search_args = {}
search_args.update({
    'search_string': ' '.join(sys.argv[1:]),
    'format_': 'json_extended'
})

results = {
    ' '.join((
        r.filename,
        str(r._raw['seeders']) | green,
        str(r._raw['leechers']) | yellow,
        f"{r._raw['size'] / 1024**3:.2f} GiB" | blue,
        r._raw['pubdate'].split()[0] | magenta
    )): r.download
    for r in RarbgAPI().search(**search_args)
}
if not results:
    sys.exit(1)

results.update({"Nothing": "Nothing"})
uri = choose("What should we get?", results, default="Nothing")
if uri == "Nothing":
    sys.exit()
aria2c['--seed-time=0', uri] & FG
