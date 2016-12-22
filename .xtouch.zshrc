xtouch () {
	touch "$1"
	chmod +x "$1"
}

xnano () {
	xtouch "$1"
	nano "$1"
}

xsubl () {
	xtouch "$1"
	subl "$1"
}
