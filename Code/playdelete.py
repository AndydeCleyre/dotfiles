#!/home/andy/.local/share/venvs/126dae705d4842d6e371dc55f7e7f923/venv/bin/python
#!/home/andy/.local/bin/vpy
#!/home/andy/bin/vpy
#!/usr/bin/env python3
import sys
from random import shuffle
import shutil

from plumbum import local, ProcessExecutionError, FG
from plumbum.cli import Application, SwitchAttr, Flag, Set
from plumbum.cli.terminal import choose
from plumbum.colors import red, green
from plumbum.cmd import mpv


class PlayDeleter(Application):

    min_mebs = SwitchAttr(
        ['m', 'min-mebs'], int, argname='MEBIBYTES',
        help="Minimum size, in mebibytes, of video to play"
    )

    depth = SwitchAttr(
        ['d', 'depth'], int, argname='MAXDEPTH',
        help="How many folders deep to search; 0 means no limit",
        default=0
    )

    # biggest_first = Flag(
        # ['b', 'biggest-first'],
        # help="Play matching videos in order from biggest to smallest, instead of randomly"
    # )

    start = SwitchAttr(
        ['s', 'sort', 'start'], Set('big', 'new'),
        help="Sort by property, descending"
    )

    def select_vids(self, paths, exts=('mkv', 'mp4', 'flv', 'avi', 'm4v', 'wmv')):
        vids = []
        for path in paths:
            root = local.path(path)

            def dir_filter(d):
                return len(d - root) < self.depth if self.depth else True

            def vid_filter(f):
                return f.suffix.lower().lstrip('.') in exts and (
                    f.stat().st_size / 2 ** 20 >= self.min_mebs
                    if self.min_mebs else True
                )

            if root.is_dir():
                vids.extend(root.walk(vid_filter, dir_filter))
            elif vid_filter(root):
                vids.append(root)
        return list(set(vids))

    def act(self, vid):
        action = "replay"
        while action == "replay":
            try:
                mpv['--really-quiet', vid] & FG
            except ProcessExecutionError as e:
                print(e | red, file=sys.stderr)
                break
            try:
                action = choose(
                    f"\n{vid} ({vid.stat().st_size / 2 ** 20:.2f} MiB):" | green,
                    [
                        "let it be",
                        "quit",
                        "kill it dead",
                        "replay",
                        "move to . . ."
                    ],
                    "let it be"
                )
            except KeyboardInterrupt:
                action = "quit"
        if action == "quit":
            sys.exit(0)
        elif action == "kill it dead":
            vid.delete()
            print("SPLAT!" | green)
        elif action == "move to . . .":
            while True:
                dest = local.path(input(f"Destination folder: {local.cwd}/"))
                if not dest.is_dir():
                    print(f"{dest} not found." | red)
                elif (dest / vid.name).exists():
                    print(f"{dest / vid.name} already exists!" | red, file=sys.stderr)
                else:
                    try:
                        vid.move(local.path(dest))
                    except shutil.Error as e:
                        print(e | red, file=sys.stderr)
                        continue
                    else:
                        print("WHOOSH!" | green)
                        break

    def main(self, *paths):
        vids = self.select_vids(paths)
        # if self.biggest_first:
        if self.start:
            vids.sort(
                key=lambda v: (
                    v.stat().st_size if self.start == 'big'
                    else v.stat().st_mtime
                ), reverse=True
            )
        else:
            shuffle(vids)
        for vid in vids:
            line = '-' * len(vid)
            print(f"{line}\n{vid}\n{line}" | green)
            self.act(vid)


if __name__ == '__main__':
    PlayDeleter.run()
