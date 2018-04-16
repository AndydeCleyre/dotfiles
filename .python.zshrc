i () { ipython }
alias i2="ipython2"
alias spip="sudo pip3"
spipi () { sudo pip install -U $@ }
alias spip2="sudo pip2"
spipi2 () { sudo pip2 install -U $@ }

venv_path () {
    echo "$HOME/.local/share/venvs/$(pwd|md5sum|cut -d ' ' -f 1)"
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

pipa () { printf "%s\n" $@ >> requirements.in && cat requirements.in }
pipc () { for reqs in *requirements.in; do pip-compile --no-header "$reqs" | highlight -O truecolor -s solarized-light -S py; done }
pipch () { for reqs in *requirements.in; do pip-compile --no-header --generate-hashes "$reqs" | highlight -O truecolor -s solarized-light -S py; done }
pips () { pip-sync *requirements.txt }
pipu () { for reqs in *requirements.in; do [[ "$#" -gt 0 ]] && pip-compile --no-header -P $@ "$reqs" || pip-compile --no-header -U "$reqs"; done }
pipuh () { for reqs in *requirements.in; do [[ "$#" -gt 0 ]] && pip-compile --no-header --generate-hashes -P $@ "$reqs" || pip-compile --no-header -U --generate-hashes "$reqs"; done }

pipacs () { pipa $@; pipc; pips }
pipcs () { pipc; pips }
pipchs () { pipch; pips }

pipi () { pip install -U $@ }
pimp () { pip install -U pip ipython plumbum requests pip-tools structlog ruamel-yaml }
freeze () { pip freeze | egrep -i "$@" }

_pipa_complete() { reply=( "${(ps: :)$(cat $ZSH_PIP_CACHE_FILE)}" ) }
compctl -K _pipa_complete pipa
