 #KDE Plasma theme switch to default(User mode)
if [ "$(pacman -Qq | grep plasma-desktop)" ]; then
	/usr/lib/plasma-changeicons breeze-dark 2>/dev/null
	lookandfeeltool --apply "org.kde.breezedark.desktop" 2>/dev/null
fi
chsh -s "$(which bash)"
printf "Would you like to reboot? Make sure you have read the above carefully! (y/N)"
read reboot
if [ "${reboot}" == "y" ]; then
	reboot
fi
