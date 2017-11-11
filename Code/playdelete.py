#!/usr/bin/env python3
import sys
from random import shuffle

from plumbum import local, ProcessExecutionError
from plumbum.cmd import mpv
from plumbum.cli.terminal import choose
from plumbum.cli import Application, SwitchAttr


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

    def select_vids(self, paths, exts=('mkv', 'mp4', 'flv', 'avi', 'm4v', 'wmv')):
        vids = []
        for path in paths:
            root = local.path(path)
            dir_filter = lambda d: len(root - d) < self.depth if self.depth else lambda d: True
            vid_filter = lambda f: f.lower().rsplit('.', 1)[-1] in exts and ((f.stat().st_size / 2 ** 20 >= self.min_mebs) if self.min_mebs else True)
            vids.extend(root.walk(vid_filter, dir_filter))
        return vids

    def act(self, vid):
        action = "replay"
        while action == "replay":
            try:
                mpv(vid)
            except ProcessExecutionError as e:
                print(e, file=sys.stderr)
                break
            try:
                action = choose(
                    f"\n{vid}:\n\n(Ctrl-c to quit)",
                    ["let it be", "kill it dead", "replay", "move to . . ."],
                    "let it be"
                )
            except KeyboardInterrupt:
                sys.exit(0)
        if action == "kill it dead":
            vid.delete()
            print("SPLAT!")
        elif action == "move to . . .":
            while True:
                dest = local.path(input("Destination folder: "))
                if not dest.is_dir():
                    print(dest, "not found.")
                else:
                    vid.move(local.path(dest))
                    print("WHOOSH!")
                    break

    def main(self, *paths):
        vids = self.select_vids(paths)
        shuffle(vids)
        for vid in vids:
            self.act(vid)


if __name__ == '__main__':
    PlayDeleter.run()
