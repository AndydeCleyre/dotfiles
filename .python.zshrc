i () { ipython }
alias i2="ipython2"
alias spip="sudo pip3"
spipi () { sudo pip install -U $@ }
alias spip2="sudo pip2"
spipi2 () { sudo pip2 install -U $@ }

envin () {
    touch requirements.txt
    [[ -s requirements.in ]] || echo "# python 3" >> requirements.in
    [[ -d ./venv ]] || python3 -m venv venv
    . ./venv/bin/activate
    pip install -qU pip-tools
    ./venv/bin/pip-sync || pip install -qr requirements.txt
}

envin2 () {
    touch requirements.txt
    [[ -s requirements.in ]] || echo "# python 2" >> requirements.in
    [[ -d ./venv2 ]] || virtualenv2 venv2
    . ./venv2/bin/activate
    pip install -qU pip-tools
    ./venv2/bin/pip-sync || pip install -qr requirements.txt
}

envinpypy () {
    touch requirements.txt
    [[ -s requirements.in ]] || echo "# pypy 3" >> requirements.in
    [[ -d ./venvpypy ]] || pypy3 -m venv venvpypy
    . ./venvpypy/bin/activate
    pip install -qU pip-tools
    ./venvpypy/bin/pip-sync || pip install -qr requirements.txt
}

envout () { deactivate }

pipa () { printf "%s\n" $@ >> requirements.in && cat requirements.in }
#pipc () { pip-compile --no-header }
pipc () { pip-compile --no-header | highlight -O truecolor -s solarized-light -S py }
#pipch () { pip-compile --no-header --generate-hashes }
pipch () { pip-compile --no-header --generate-hashes | highlight -O truecolor -s solarized-light -S py }
pips () { pip-sync $@ }
pipu () { [[ "$#" -gt 0 ]] && pip-compile --no-header -P $@ || pip-compile --no-header -U }

pipi () { pip install -U $@ }
pimp () { pip install -U pip ipython plumbum requests pip-tools structlog ruamel-yaml }
freeze () { pip freeze | egrep -i "$@" }

_pipa_complete() { reply=( "${(ps: :)$(cat $ZSH_PIP_CACHE_FILE)}" ) }
compctl -K _pipa_complete pipa
