i  () { ipython  }
i2 () { ipython2 }

pipi () { pip install -U $@ }  # <req> [req...]

# get path of folder containing all venvs for the current folder or specified project path
venvs_path () {  # [projectpath]
    [[ "$#" -gt 0 ]] && reqsdir="$(realpath "$1")" || reqsdir="$(pwd)"
    echo "$HOME/.local/share/venvs/$(echo -n "$reqsdir" | md5sum | cut -d ' ' -f 1)"
}

# run script with its venv
_vpy  () { "$(venvs_path $(dirname $(realpath "$2")))/$1/bin/python" "${@:2}" }  # <venvname> <script> [args]
vpy   () { _vpy venv     "$@" }  # <script> [args]
vpy2  () { _vpy venv2    "$@" }  # <script> [args]
vpypy () { _vpy venvPyPy "$@" }  # <script> [args]

# generate a shebang line for running a specified script with its venv
_vpyshebang  () { printf "#!$(venvs_path $(dirname $(realpath "$2")))/$1/bin/python" "${@:2}" }  # <venvname> <script> [args]
vpyshebang   () { _vpyshebang venv     "$@" }  # <script> [args]
vpy2shebang  () { _vpyshebang venv2    "$@" }  # <script> [args]
vpypyshebang () { _vpyshebang venvPyPy "$@" }  # <script> [args]

# specify the venv interpreter in a new or existing sublime text project file
vpysubl () {
    pip install -qU plumbum
    python -c "
from plumbum import local
from json import loads, dumps
try:
    spfile = [f for f in local.cwd.list() if f.endswith('.sublime-project')].pop()
except IndexError:
    spfile = local.cwd / f'{local.cwd.name}.sublime-project'
    spfile.write('{}')
sp = loads(spfile.read())
sp.setdefault('settings', {})
sp['settings']['python_interpreter'] = '$(venvs_path)/venv/bin/python'
spfile.write(dumps(sp))
    "
}

# activate venv for the current folder and install requirements, creating venv if necessary
_envin () {  # <venvname> <venvinitcmd>
    venv="$(venvs_path)/$1"
    [[ -d $venv ]] || eval $2 $venv
    . $venv/bin/activate
    # pip install -qU pip pip-tools
    pip install -qU 'pip<19.2' pip-tools  # pip<19.2 until https://github.com/jazzband/pip-tools/issues/853 is closed
    [[ ! -f requirements.txt ]] || $venv/bin/pip-sync *requirements.txt
}
envin     () { _envin venv     "python3 -m venv" }
envin2    () { _envin venv2    "virtualenv2"     }
envinpypy () { _envin venvPyPy "pypy3 -m venv"   }
activate  () { . $(venvs_path)/venv/bin/activate }  # activate without installing anything
envout    () { deactivate                        }

# pipe pythonish syntax through this to make it colorful
hpype () {
    [[ "$(command -v highlight)" ]] && highlight -O truecolor -s moria -S py ||
    [[ "$(command -v bat)"       ]] && bat -l py -p                          ||
                                       cat -
}

# install packages according to all found or specified requirements.txt files (sync)
pips () { [[ "$#" -gt 0 ]] && pip-sync $@ || pip-sync *requirements.txt }  # [reqstxt...]

# compile requirements.txt files from all found requirements.in files (compile)
pipc  () { for reqs in *requirements.in; do pip-compile --no-header                   "$reqs" | hpype; done }
pipch () { for reqs in *requirements.in; do pip-compile --no-header --generate-hashes "$reqs" | hpype; done }

# compile, then sync
pipcs  () { pipc ; pips }
pipchs () { pipch; pips }

# add loose requirements to requirements.in (add)
pipa () { printf "%s\n" $@ >> requirements.in && cat requirements.in | hpype }  # <req> [req...]
# add, then compile
pipac   () { pipa   $@; echo; pipc  }  # <req> [req...]
pipach  () { pipa   $@; echo; pipch }  # <req> [req...]
# add, then compile, then sync
pipacs  () { pipac  $@; pips }  # <req> [req...]
pipachs () { pipach $@; pips }  # <req> [req...]

# recompile with upgraded versions of all or specified packages (upgrade)
pipu  () { for reqs in *requirements.in; do [[ "$#" -gt 0 ]] && pip-compile --no-header                   -P ${(z)${(j: -P :)@}} "$reqs" | hpype || pip-compile --no-header -U                   "$reqs" | hpype; done }  # [req...]
pipuh () { for reqs in *requirements.in; do [[ "$#" -gt 0 ]] && pip-compile --no-header --generate-hashes -P ${(z)${(j: -P :)@}} "$reqs" | hpype || pip-compile --no-header -U --generate-hashes "$reqs" | hpype; done }  # [req...]

# upgrade, then sync
pipus  () { pipu  $@; pips }  # [req...]
pipuhs () { pipuh $@; pips }  # [req...]

# inject loose requirements.in dependencies into pyproject.toml
# run either from the folder with pyproject.toml, or one below
# to categorize, name files <category>-requirements.in
pypc () {
    pip install -qU plumbum tomlkit
    python -c "
from plumbum import local
import tomlkit


suffix = 'requirements.in'
pyproject = local.cwd / 'pyproject.toml'
if not pyproject.is_file():
    pyproject = local.cwd.up() / 'pyproject.toml'
reqsins = pyproject.up() // f'*/*{suffix}' + pyproject.up() // f'*{suffix}'
if pyproject.is_file():
    toml_data = tomlkit.parse(pyproject.read())
    for reqsin in reqsins:
        pyproject_reqs = [
            line
            for line in reqsin.read().splitlines()
            if line.strip() and not line.startswith('#')
        ]
        extras_catg = reqsin.name.rsplit(suffix, 1)[0].rstrip('-.')
        if not extras_catg:
            toml_data['tool']['flit']['metadata']['requires'] = pyproject_reqs
        else:
            # toml_data['tool']['flit']['metadata'].setdefault('requires-extra', {})  # enable on close of https://github.com/sdispater/tomlkit/issues/49
            if 'requires-extra' not in toml_data['tool']['flit']['metadata']:         # remove when #49 is fixed
                toml_data['tool']['flit']['metadata']['requires-extra'] = {}          # remove when #49 is fixed
            toml_data['tool']['flit']['metadata']['requires-extra'][extras_catg] = pyproject_reqs
    pyproject.write(tomlkit.dumps(toml_data))
    "
}
