#!/usr/bin/env python3

from sys import exit
from collections import OrderedDict as OD
from plumbum import local
from plumbum.cmd import xdg_open, sudo, cp
from plumbum.colors import red, green, blue, magenta


def abortable_ask(choices_dict, allowed=None, append_abort=True):
    if append_abort:
        choices_dict['Ctrl-c'] = 'abort'
    try:
        print(red | '\n'.join(['[{}] {}'.format(choice, consequence) for choice, consequence in choices_dict.items()]))
        r = input()
    except KeyboardInterrupt:
        exit()
    if allowed and r not in allowed:
        return abortable_ask(choices_dict, allowed, False)
    return r

def make_suggestion(line, matching_subtring, replacement_dict):
    if matching_subtring in line:
        suggestion = line
        for old, new in replacement_dict.items():
            suggestion = suggestion.replace(old, new)
        print(blue | ' '*len('[Enter] ') + line)#           <-- hacky alignment
        r = abortable_ask(OD([('Enter', suggestion), ('k', 'keep line as-is'), ('s', "skip this line altogether")]), ['', 'k', 's'])
        if not r:
            line = suggestion
        elif r == 's':
            line = ''
    return line

def main():
    user_home = local.path('~')
    print("Hello! We're going to clone {}'s .zshrc files for the root user, and maybe make some changes along the way.".format(user_home.name))
    abortable_ask(OD([('Enter', "begin")]), [''])
    for zshrc_file in [f.name for f in user_home // '.*zshrc']:
        user_zshrc = (user_home / zshrc_file).read('utf8')
        root_zshrc = ''
        for line in user_zshrc.split('\n'):
            root_line = line
            # print(blue | root_line)
            root_line = make_suggestion(root_line, 'sudo ', {'sudo ': ''})
            root_line = make_suggestion(root_line, '~', {'~': user_home})
            root_zshrc += root_line + '\n'
        with local.tempdir() as tmp:
            file = tmp / zshrc_file
            file.write(root_zshrc, 'utf8')
            # file.write(root_zshrc.encode())
            print(magenta | '{} for root written to'.format(zshrc_file), file)
            print(green | 'Opening for your review and edits . . .')
            xdg_open(file)
            abortable_ask(OD([('Enter', 'overwrite /root/{}'.format(zshrc_file))]), [''])
            sudo[cp[file, '/root/{}'.format(zshrc_file)]]()


if __name__ == '__main__':
    main()
