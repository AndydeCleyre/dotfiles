i () { ipython }
alias i2="ipython2"
alias spip="sudo pip3"
alias spip2="sudo pip2"

envin () {
    touch requirements.txt
    [[ -s requirements.in ]] || echo "# python 3" >> requirements.in
    [[ -d ./venv ]] || python3 -m venv venv
    . ./venv/bin/activate
    pip install -U pip-tools
    pip-sync || pip install -r requirements.txt
}

envin2 () {
    touch requirements.txt
    [[ -s requirements.in ]] || echo "# python 2" >> requirements.in
    [[ -d ./venv2 ]] || virtualenv2 venv2
    . ./venv2/bin/activate
    pip install -U pip-tools
    pip-sync || pip install -r requirements.txt
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

