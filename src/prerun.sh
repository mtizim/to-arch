if [ $EUID -eq 0 ]; then
	if [ "$(pacman -Qq | grep kde-plasma-desktop)" ]; then
		printf "This script should not be run as root since KDE Plasma stores its settings in the normal userspace.\nPermissions will be eleveted automatically for system-wide tasks."
		exit 1
	fi
fi
printf "I HAVE ABSOLUTELY NO RESPONSIBILITY FOR ANY ERRORS!\n"
printf "This script only works on systems on an IPv4 network!\nDO NOT RUN THIS SCRIPT IF YOU ARE USING IPv6!\n"
read -rp "==>Press Enter to continue"
