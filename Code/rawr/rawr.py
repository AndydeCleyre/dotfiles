#!/home/andy/.local/bin/vpy
#!/usr/bin/env python3
import sys
from time import sleep

from plumbum import FG, local, CommandNotFound
from plumbum.cli.terminal import choose, ask
from plumbum.cmd import aria2c, grep, df
from plumbum.colors import blue, green, magenta, yellow
from rarbgapi import RarbgAPI


def mk_search_args():
    try:
        sys.argv.remove('-a')
    except ValueError:
        search_args = {}
    else:
        search_args = {'categories': [RarbgAPI.CATEGORY_ADULT]}
    search_args.update({
        'search_string': ' '.join(sys.argv[1:]),
        'extended_response': True
    })
    return search_args


def get_results(search_args):
    results = None
    max_attempts = 6
    attempts = max_attempts
    while attempts and not results:
        if attempts < max_attempts:
            print(f"Retrying . . .")
            sleep(1)
        results = {
            ' '.join((
                r.filename,
                str(r.seeders) | green,
                str(r.leechers) | yellow,
                f"{r.size / 1024**3:.2f} GiB" | blue,
                r.pubdate.split()[0] | magenta
            )): r.download
            for r in RarbgAPI().search(**search_args)
            # for r in RarbgAPI(retries=12).search(**search_args)
        }
        attempts -= 1
    return results


def choose_result(results):
    results.update({"Nothing": "Nothing"})
    uri = choose("What should we get?" | magenta, results, default="Nothing")
    return None if uri == "Nothing" else uri


def show_connection():
    try:
        print(local['mullvad']('status', '-l') | yellow)
    except CommandNotFound:
        try:
            print((local['nmcli']['-o'] | grep['-E', '^[^ ]+: connected'])() | yellow)
        except CommandNotFound:
            try:
                print(local['https']('--body', 'ipinfo.io') | yellow)
            except CommandNotFound:
                try:
                    print(local['curl']('ipinfo.io') | yellow)
                except CommandNotFound:
                    print(local['wget']('-qO', '-', 'ipinfo.io') | yellow)


def clip(text):
    try:
        (((local['xclip']['-sel', 'clip'] > sys.stdout) >= sys.stderr) << text)()
    except CommandNotFound:
        (((local['pbcopy'] > sys.stdout) >= sys.stderr) << text)()


def main():
    try:
        results = get_results(mk_search_args())
    except KeyboardInterrupt:
        results = None
    if not results:
        sys.exit(1)
    print(f"{df('-h', '-P', '.').splitlines()[-1].split()[3]} available" | yellow)
    uri = choose_result(results)
    if uri is None:
        sys.exit()
    try:
        clip(uri)
    except CommandNotFound:
        print(uri | blue)
    else:
        print("Magnet URI copied to clipboard" | green)
    show_connection()
    if ask("Begin download with aria2" | magenta, True):
        aria2c['--seed-time=0', uri] &FG


if __name__ == '__main__':
    main()
