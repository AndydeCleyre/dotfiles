#!/home/andy/.local/bin/vpy
#!/usr/bin/env python3
import sys
from time import sleep

from plumbum import FG, local, CommandNotFound
from plumbum.cli.terminal import choose
from plumbum.cmd import aria2c
from plumbum.colors import blue, green, magenta, yellow
from rarbgapi import RarbgAPI


def mk_search_args():
    try:
        sys.argv.remove('-a')
    except ValueError:
        search_args = {}
    else:
        search_args = {'category': RarbgAPI.CATEGORY_ADULT}
    search_args.update({
        'search_string': ' '.join(sys.argv[1:]),
        'format_': 'json_extended'
    })
    return search_args


def get_results(search_args):
    results = None
    max_attempts = 3
    attempts = max_attempts
    while attempts and not results:
        if attempts < max_attempts:
            print(f"Retrying . . .")
            sleep(1)
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
        attempts -= 1
    return results


def choose_result(results):
    results.update({"Nothing": "Nothing"})
    uri = choose("What should we get?", results, default="Nothing")
    return None if uri == "Nothing" else uri


def main():
    results = get_results(mk_search_args())
    if not results:
        sys.exit(1)
    uri = choose_result(results)
    if uri is None:
        sys.exit()
    try:
        (((
            local['xclip']['-sel', 'clip'] > sys.stdout
        ) >= sys.stderr) << uri)()
    except CommandNotFound:
        print(uri)
    aria2c['--seed-time=0', uri] & FG


if __name__ == '__main__':
    main()
