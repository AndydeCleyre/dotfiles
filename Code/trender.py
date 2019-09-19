#!/home/andy/bin/vpy
#!/usr/bin/env python3
from json import loads
import sys

from plumbum.cli import Application, ExistingFile, Flag, NonexistentPath
from plumbum.colors import red
from pyratemp import Template


class TemplateRenderer(Application):
    """Use json var_files to render template_file adjacent with the same name but the extension stripped"""

    overwrite = Flag(['f', 'force'], help="Overwrite any existing destination file")

    def main(self, template_file: ExistingFile, *var_files: ExistingFile):
        data = {}
        for vfile in var_files:
            data.update(loads(vfile.read()))
        rstr = Template(filename=template_file, data=data)()
        dest = template_file.with_suffix('')
        if not self.overwrite:
            try:
                NonexistentPath(dest)
            except ValueError as e:
                print(f"{e}"                        | red, file=sys.stderr)
                print("Use -f/--force to overwrite" | red, file=sys.stderr)
                sys.exit(1)
        dest.write(rstr)


if __name__ == '__main__':
    TemplateRenderer()
