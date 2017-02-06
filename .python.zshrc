alias i="ipython"
alias i2="ipython2"
alias spip="sudo pip"
alias spip2="sudo pip2"

envin () {
    touch requirements.txt requirements.in
    [[ -d ./venv ]] || python -m venv venv
    . ./venv/bin/activate
    pip install -U pip-tools
    pip-sync || pip install -r requirements.txt
}

envin2 () {
    touch requirements.txt requirements.in
    [[ -d ./venv2 ]] || virtualenv2 venv2
    . ./venv2/bin/activate
    pip install -U pip-tools
    pip-sync || pip install -r requirements.txt
}

envout () { deactivate }

pipa () { printf "%s\n" $@ >> requirements.in && cat requirements.in }
pipc () { pip-compile --no-header }
pipch () { pip-compile --no-header --generate-hashes }
pips () { pip-sync }
pipu () { [[ "$#" -gt 0 ]] && pip-compile -P $@ || pip-compile -U }

pipi () { pip install -U $@ }
pimp () { pip install -U pip ipython plumbum requests pip-tools structlog ruamel-yaml }
freeze () { pip freeze | egrep -i "$@" }

