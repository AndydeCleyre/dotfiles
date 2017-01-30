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

pimp () { pip install -U pip ipython plumbum requests pip-tools structlog ruamel-yaml }

envout () { deactivate }

freeze () {
    pip freeze | egrep -i "$@" >> requirements.in
    nano requirements.in
}

pipa () { echo "$@" >> requirements.in }
pipc () { pip-compile }
pips () { pip-sync }
pipi () { pip-sync }
pipu () { pip-compile -U }
