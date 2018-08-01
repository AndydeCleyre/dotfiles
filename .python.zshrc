i () { ipython }
i2 () { ipython2 }

venv_path () {
    [[ "$#" -gt 0 ]] && reqspath="$(realpath $1)" || reqspath="$(pwd)"
    echo "$HOME/.local/share/venvs/$(echo -n $reqspath | md5sum | cut -d ' ' -f 1)"
}

envin () {
    venv="$(venv_path)/venv"
    [[ -d $venv ]] || python3 -m venv $venv
    touch requirements.txt
    [[ -s requirements.in ]] || echo "# python 3" >> requirements.in
    . $venv/bin/activate
    curl -I https://pypi.org/ &> /dev/null && pip install -qU pip-tools
    $venv/bin/pip-sync *requirements.txt || pip install -qr requirements.txt
}

envin2 () {
    venv="$(venv_path)/venv2"
    [[ -d $venv ]] || virtualenv2 $venv
    touch requirements.txt
    [[ -s requirements.in ]] || echo "# python 2" >> requirements.in
    . $venv/bin/activate
    curl -I https://pypi.org/ &> /dev/null && pip install -qU pip-tools
    $venv/bin/pip-sync *requirements.txt || pip install -qr requirements.txt
}

envinpypy () {
    venv="$(venv_path)/venvPyPy"
    [[ -d $venv ]] || pypy3 -m venv $venv
    touch requirements.txt
    [[ -s requirements.in ]] || echo "# pypy3" >> requirements.in
    . $venv/bin/activate
    curl -I https://pypi.org/ &> /dev/null && pip install -qU pip-tools
    $venv/bin/pip-sync *requirements.txt || pip install -qr requirements.txt
}

envout () { deactivate }

type highlight &> /dev/null && hpype () { highlight -O truecolor -s lucretia -S py } || hpype () { cat - }

pipa () { printf "%s\n" $@ >> requirements.in && cat requirements.in }
pipc () { for reqs in *requirements.in; do pip-compile --no-header "$reqs" | hpype; done }
pipch () { for reqs in *requirements.in; do pip-compile --no-header --generate-hashes "$reqs" | hpype; done }
pips () { pip-sync *requirements.txt }
pipu () { for reqs in *requirements.in; do [[ "$#" -gt 0 ]] && pip-compile --no-header -P $@ "$reqs" | hpype || pip-compile --no-header -U "$reqs" | hpype; done }
pipuh () { for reqs in *requirements.in; do [[ "$#" -gt 0 ]] && pip-compile --no-header --generate-hashes -P $@ "$reqs" | hpype || pip-compile --no-header -U --generate-hashes "$reqs" | hpype; done }

pipcs () { pipc; pips }
pipchs () { pipch; pips }
pipacs () { pipa $@; pipcs }
pipachs () { pipa $@; pipchs }
pipus () { pipu $@; pips }
pipuhs () { pipuh $@; pips }

pipi () { pip install -U $@ }
pimp () { pip install -U pip ipython plumbum requests pip-tools structlog strictyaml }
freeze () { pip freeze | egrep -i "$@" }

_pipa_complete() { reply=( "${(ps: :)$(cat $ZSH_PIP_CACHE_FILE)}" ) }
compctl -K _pipa_complete pipa
