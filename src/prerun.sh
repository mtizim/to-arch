if pacman -Qq | grep -q sway || pgrep -x sway &>/dev/null || [ "$XDG_CURRENT_DESKTOP" = "sway" ]; then
	printf "You seem to use Sway. This script breaks Sway, and will make it UNUSABLE!\n"
	printf "See README for more info. Type \"I agree\" if you know the consequences and want to continue.\n"

	read agree
	if [ "$agree" = "I agree" ]; then
		printf "You agreed, don't file an issue whining about your broken Sway installation.\n"
	else
		printf "You disagreed.\n"
		exit 1
	fi
	[ $? == 1 ] && exit 1;
fi
[ $? == 1 ] && exit 1;

printf "Although this is fully tested on multiple machines and editions,\nthe result might not be good if you have an unusual installation.\nAlso this script comes with ABSOLUTELY NO WARRANTY!\n"
read -rp "==>Press Enter to continue"
