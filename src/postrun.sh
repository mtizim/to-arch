# KDE Plasma theme switch to default (user mode)
if pacman -Qq | grep -q plasma-desktop; then
	/usr/lib/plasma-changeicons breeze-dark 2>/dev/null
	lookandfeeltool --apply "org.kde.breezedark.desktop" 2>/dev/null
fi
chsh -s "/bin/bash"
if pacman -Qq | grep -q sway; then
	workdir="$(pwd)"
	rm -rf ~/.config/sway
	mkdir ~/.config/sway
	curl -o config -fLs https://raw.githubusercontent.com/swaywm/sway/master/config.in
	sed -i '/alacritty/c\foot' ~/.config/sway/config
	sudo pacman -S dmenu --noconfirm
	cd "${workdir}"
fi
printf "Would you like to reboot? Make sure you have read the above carefully! (y/N)"
read -r reboot
# If we're already using Bash (#!/usr/bin/env bash), why not make use of its neat features
[ "$(tr '[:upper:]' '[:lower:]' <<< "$reboot")" = "y" ] && reboot
