i  () { ipython  }
i2 () { ipython2 }

venvs_path () {
    [[ "$#" -gt 0 ]] && reqsdir="$(realpath $1)" || reqsdir="$(pwd)"
    echo "$HOME/.local/share/venvs/$(echo -n $reqsdir | md5sum | cut -d ' ' -f 1)"
}

_vpy  () { "$(venvs_path $(dirname $(realpath $2)))/$1/bin/python" "${@:2}" }
vpy   () { _vpy venv     "$@" }
vpy2  () { _vpy venv2    "$@" }
vpypy () { _vpy venvPyPy "$@" }

_vpyshebang  () { printf "#!$(venvs_path $(dirname $(realpath $2)))/$1/bin/python" "${@:2}" }
vpyshebang   () { _vpyshebang venv     "$@" }
vpy2shebang  () { _vpyshebang venv2    "$@" }
vpypyshebang () { _vpyshebang venvPyPy "$@" }

_envin () {
    venv="$(venvs_path)/$1"
    [[ -d $venv ]] || eval $2 $venv
    touch requirements.txt
    [[ -s requirements.in ]] || echo "# $3" >> requirements.in
    . $venv/bin/activate
    # curl -I https://pypi.org/ &> /dev/null && pip install -qU pip pip-tools
    pip install -qU pip pip-tools
    $venv/bin/pip-sync *requirements.txt || pip install -qr requirements.txt
}
envin     () { _envin venv     "python3 -m venv" "Python 3" }
envin2    () { _envin venv2    "virtualenv2"     "Python 2" }
envinpypy () { _envin venvPyPy "pypy3 -m venv"   "PyPy 3"   }

envout () { deactivate }

hpype () {
    [[ "$(command -v highlight)" ]] && highlight -O truecolor -s moria -S py ||
    [[ "$(command -v bat)"       ]] && bat -l py -p                          ||
                                       cat -
}

pips () { [[ "$#" -gt 0 ]] && pip-sync $@ || pip-sync *requirements.txt }

pipc  () { for reqs in *requirements.in; do pip-compile --no-header                   "$reqs" | hpype; done }
pipch () { for reqs in *requirements.in; do pip-compile --no-header --generate-hashes "$reqs" | hpype; done }
pipcs  () { pipc ; pips }
pipchs () { pipch; pips }

pipa () { printf "%s\n" $@ >> requirements.in && cat requirements.in | hpype }
pipac   () { pipa  $@; echo; pipc }
pipacs  () { pipac $@; pips       }
pipach  () { pipa   $@; pipch }
pipachs () { pipach $@; pips  }

pipu  () { for reqs in *requirements.in; do [[ "$#" -gt 0 ]] && pip-compile --no-header                   -P ${(z)${(j: -P :)@}} "$reqs" | hpype || pip-compile --no-header -U                   "$reqs" | hpype; done }
pipuh () { for reqs in *requirements.in; do [[ "$#" -gt 0 ]] && pip-compile --no-header --generate-hashes -P ${(z)${(j: -P :)@}} "$reqs" | hpype || pip-compile --no-header -U --generate-hashes "$reqs" | hpype; done }
pipus  () { pipu  $@; pips }
pipuhs () { pipuh $@; pips }

pipi () { pip install -U $@ }

pimp    () { pipi   ipython plumbum requests structlog strictyaml }
pimpacs () { pipacs ipython plumbum requests structlog strictyaml }

pypc () {
    pip install plumbum tomlkit
    python -c "
from plumbum import local
import tomlkit


suffix = 'requirements.in'
pyproject, reqsins = local.cwd / 'pyproject.toml', local.cwd // f'*/*{suffix}'
if not pyproject.is_file():
    pyproject, reqsins = local.cwd.up() / 'pyproject.toml', local.cwd // f'*{suffix}'
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
