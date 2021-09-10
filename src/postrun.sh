 #KDE Plasma theme switch to default(User mode)
if [ "$(pacman -Qq | grep plasma-desktop)" ]; then
	/usr/lib/plasma-changeicons breeze-dark 2>/dev/null
	lookandfeeltool --apply "org.kde.breezedark.desktop" 2>/dev/null
fi
chsh -s "$(which bash)"
