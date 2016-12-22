alias i="ipython"
alias i2="ipython2"
alias spip="sudo pip"
alias spip2="sudo pip2"

envin () {
    [[ -d ./venv ]] || pyvenv venv
    . ./venv/bin/activate
    touch requirements.txt
    pip install -r requirements.txt
}

envin2 () {
    [[ -d ./venv2 ]] || virtualenv2 venv2
    . ./venv2/bin/activate
    touch requirements.txt
    pip install -r requirements.txt
}

pimp () { pip install -U pip ipython plumbum requests }

envout () { deactivate }

freeze () {
    pip freeze | egrep -i "$@" >> requirements.txt
    nano requirements.txt
}
