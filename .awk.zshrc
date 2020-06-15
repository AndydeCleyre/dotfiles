_numth () {  # <num> [delimiter [filter-regex]]
    awk -F ${2:- } '/'"${3:-.*}"'/ {print $'"$1"'}'
}
1st () {  # [delimiter [filter-regex]]
    _numth 1 $@
}
2nd () { _numth 2 $@ }  # [delimiter [filter-regex]]
3rd () { _numth 3 $@ }  # [delimiter [filter-regex]]
for num in {4..20}; do
    eval "${num}th () { _numth $num \$@ }"
done
last () { awk -F ${1:- } '/'"${2:-.*}"'/ {print $NF}' }
