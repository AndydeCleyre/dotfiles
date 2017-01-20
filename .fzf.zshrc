nanof() {
    local file
    file="$(fasd -Rfl "$1" | fzf -1 -0 --no-sort +m)" && nano "${file}" || return 1
}
snanof() {
    local file
    file="$(fasd -Rfl "$1" | fzf -1 -0 --no-sort +m)" && sudo nano "${file}" || return 1
}
sublf() {
    local file
    file="$(fasd -Rfl "$1" | fzf -1 -0 --no-sort +m)" && subl "${file}" || return 1
}
cdf() {
    local dir
    dir="$(fasd -Rdl "$1" | fzf -1 -0 --no-sort +m)" && cd "${dir}" || return 1
}
lessf() {
    local file
    file="$(fasd -Rfl "$1" | fzf -1 -0 --no-sort +m)" && less "${file}" || return 1
}
catf() {
    local file
    file="$(fasd -Rfl "$1" | fzf -1 -0 --no-sort +m)" && cat "${file}" || return 1
}
scatf() {
    local file
    file="$(fasd -Rfl "$1" | fzf -1 -0 --no-sort +m)" && sudo cat "${file}" || return 1
}
