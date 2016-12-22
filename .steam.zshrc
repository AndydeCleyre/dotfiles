fix-controller () {
    sudo modprobe uinput
    sudo chmod 0660 /dev/uinput
    sudo chown root:games /dev/uinput
}

steam-clean () {
	find ~/.steam/root/ \( -name 'libgcc_s.so*' -o -name 'libstdc++.so*' -o -name 'libxcb.so*' -o -name 'libgpg-error.so*' \) -print -delete
	find ~/.steam/root/ \( -name 'libgcc_s.so*' -o -name 'libstdc++.so*' -o -name 'libxcb.so*' -o -name 'libgpg-error.so*' \) -print -delete
	find ~/.local/share/Steam/ \( -name 'libgcc_s.so*' -o -name 'libstdc++.so*' -o -name 'libxcb.so*' -o -name 'libgpg-error.so*' \) -print -delete
}
