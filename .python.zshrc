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

_envin () {
    venv="$(venvs_path)/$1"
    [[ -d $venv ]] || eval $2 $venv
    touch requirements.txt
    [[ -s requirements.in ]] || echo "# $3" >> requirements.in
    . $venv/bin/activate
    curl -I https://pypi.org/ &> /dev/null && pip install -qU pip pip-tools
    $venv/bin/pip-sync *requirements.txt || pip install -qr requirements.txt
}
envin     () { _envin venv     "python3 -m venv" "Python 3" }
envin2    () { _envin venv2    "virtualenv2"     "Python 2" }
envinpypy () { _envin venvPyPy "pypy3 -m venv"   "PyPy 3"   }

envout () { deactivate }

hpype () {
    [[ "$(command -v highlight)" ]] && highlight -O truecolor -s lucretia -S py ||
    [[ "$(command -v bat)"       ]] && bat -l py -p                             ||
                                       cat -
}

pips () { pip-sync *requirements.txt }

pipc  () { for reqs in *requirements.in; do pip-compile --no-header                   "$reqs" | hpype; done }
pipch () { for reqs in *requirements.in; do pip-compile --no-header --generate-hashes "$reqs" | hpype; done }
pipcs  ()  { pipc ; pips }
pipchs ()  { pipch; pips }

pipa () { printf "%s\n" $@ >> requirements.in && cat requirements.in }
pipacs  () { pipa $@; pipcs  }
pipachs () { pipa $@; pipchs }

pipu  () { for reqs in *requirements.in; do [[ "$#" -gt 0 ]] && pip-compile --no-header                   -P ${(z)${(j: -P :)@}} "$reqs" | hpype || pip-compile --no-header -U                   "$reqs" | hpype; done }
pipuh () { for reqs in *requirements.in; do [[ "$#" -gt 0 ]] && pip-compile --no-header --generate-hashes -P ${(z)${(j: -P :)@}} "$reqs" | hpype || pip-compile --no-header -U --generate-hashes "$reqs" | hpype; done }
pipus  ()  { pipu  $@; pips }
pipuhs ()  { pipuh $@; pips }

pipi () { pip install -U $@ }

pimp    () { pipi   ipython plumbum requests structlog strictyaml }
pimpacs () { pipacs ipython plumbum requests structlog strictyaml }
