#!/usr/bin/env bash
# Inspired by mariuszkurek/convert.sh


#no. no manjaro. manjaro bad. convert fast. right now.
CONVERTER_MANJARNO(){
## System-wide jobs. The core part, this breaks and you system gets borked.
## If you use doas instead of sudo, then simply change the sudo to doas.
sudo bash -c '
# Run `pacman -Qq` and grep a pattern quietly
grepPacmanQuery() { # $1 - Pattern to grep for in the output of `pacman -Qq`
	pacman -Qq | grep "$1" -q
}

# Remove a package if it matched `pacman -Qq`
removeIfMatched() { # $1 - Pattern
	grepPacmanQuery "$1" && pacman -Rsdd "$1" --noconfirm
	true
}

# Temporary directory to store all our stuff in
tmp_dir="$(mktemp -d)"

pacman -Syy neofetch micro vim --noconfirm
neofetch
printf "This is your current distro state.\n"

if grepPacmanQuery pamac; then
	# Pamac is there for a reason, and I'"'"'m not hostile towards it.
	printf "\nDo you want to remove pamac?(y/N)\n"
	read -rn 1 a
	case "$a" in
		[Yy]*) pacman -Qq | grep pamac | xargs pacman -Rdd --noconfirm ;;
		*) printf "Leaving pamac alone.\n" ;;
	esac
fi
grepPacmanQuery manjaro-application-utility && pacman -Rcnsdd manjaro-application-utility --noconfirm
removeIfMatched matray
removeIfMatched manjaro-release
removeIfMatched bashrc-manjaro
removeIfMatched manjaro-keyring


(
	cd /etc/pacman.d
	rm mirrorlist
	# Get mirrorlist
	curl -o mirrorlist -sL '"'"'https://archlinux.org/mirrorlist/?country=all&protocol=http&protocol=https&ip_version=4&ip_version=6'"'"'



	[ -f /etc/pacman.d/mirrorlist.pacnew ] && rm /etc/pacman.d/mirrorlist.pacnew
	[ -f /etc/pacman.conf.pacnew ] && rm /etc/pacman.conf.pacnew

	# Delete crappy unrecognized pacman option by Manjaro
	sed -i '"'"'/SyncFirst/d'"'"' /etc/pacman.conf
	sed -i '"'"'/HoldPkg/d'"'"' /etc/pacman.conf

	# Use $VISUAL instead?
	printf "==> Uncomment mirrors from your country.\nPress 1 for Nano, 2 for vim, 3 for vi, 4 for micro, or any other key for your default \$EDITOR.\n"
	read -rn 1 whateditor
	case "$whateditor" in
		"1") nano /etc/pacman.d/mirrorlist ;;
		"2") vim /etc/pacman.d/mirrorlist ;;
		"3") vi /etc/pacman.d/mirrorlist ;;
		"4") micro /etc/pacman.d/mirrorlist ;;
		*) $EDITOR /etc/pacman.d/mirrorlist ;;
	esac

	# Backup just in case
	cp /etc/pacman.d/mirrorlist "${tmp_dir}/mirrorlist"
)

# I have seen pacui and bmenu in some editions as a dependency
grepPacmanQuery pacui && pacman -Qq | grep pacui | xargs pacman -Rdd --noconfirm
pacman -Qq pacui &>/dev/null && pacman -Qq | grep pacui | xargs pacman -Rdd --noconfirm
pacman -Qq bmenu &>/dev/null && pacman -Qq | grep bmenu | xargs pacman -Rdd --noconfirm

# Manjaro uses a different mirrorlist package to identify from the Arch one.
pacman -Qq pacman-mirrors &>/dev/null && pacman -Qq | grep pacman-mirrors | xargs pacman -Rdd --noconfirm

# Get pacman, mirrorlist and lsb_release from website, not mirrors
pacman -U --overwrite \*  https://www.archlinux.org/packages/core/x86_64/pacman/download/ https://www.archlinux.org/packages/core/any/pacman-mirrorlist/download/ https://www.archlinux.org/packages/community/any/lsb-release/download/ --noconfirm

\mv -f "${tmp_dir}/mirrorlist" /etc/pacman.d/mirrorlist
# Do it again, because conf gets reset
sed -i '"'"'/SyncFirst/d'"'"' /etc/pacman.conf

# # Deletes the Manjaro UEFI entry. It'"'"'s a very dangerous operation if misused, but I tested this multiple times and it was good.
#if [ -d /sys/firmware/efi ]; then
	#efibootmgr>/tmp/efi_count_tmp
	#count="$(grep -ic Manjaro /tmp/efi_count_tmp)"
	#if (( count > 1 )); then
		#continue
	#else
		#efibootmgr -b "$(efibootmgr | grep Manjaro | sed '"'"'s/*//'"'"' | cut -f 1 -d'"'"' '"'"' | cut -c5-)" -B
	#fi
#fi

# Change grub
sed -i '"'"'/GRUB_DISTRIBUTOR="Manjaro"/c\GRUB_DISTRIBUTOR="Arch"'"'"' /etc/default/grub

# Following line enables multilib repository
sed -ie '"'"'s/#\(\[multilib\]\)/\1/;/\[multilib\]/,/^$/{//!s/^#//;}'"'"' /etc/pacman.conf

# Prevent HoldPkg error
sed -i '"'"'/HoldPkg/d'"'"' /etc/pacman.conf

# Purge Manjaro'"'"'s software
pacman -Qq | grep manjaro | xargs pacman -Rdd --noconfirm
# KDE Plasma
pacman -Qq | grep breath | xargs pacman -Rdd --noconfirm

# This should be in front of -Syu to avoid manjaro'"'"'s linux kernel from updating
pacman -Qq | grep '"'"'linux[0-9]'"'"' | xargs pacman -Rdd --noconfirm

#Manjaro SwayWM edition
if [ "$(cat /etc/pacman.conf | grep '"'"'\[manjaro-sway\]'"'"')" ]; then
	sudo sed -ie '"'"'/\[manjaro-sway\]/,+2d'"'"' /etc/pacman.conf
fi
###################
#TODO:Probably some kind of custom hook in manjarno.
#/usr/share/libalpm/hooks/*
###################
# -Syyyyyyyyyyuuuuuuuu calms me down
[ -f /etc/lsb-release ] && mv /etc/lsb-release /etc/lsb-release.bak
pacman -Syyu --overwrite \* bash lsb-release --noconfirm

# As Linus Torvalds said
pacman -Qq | grep mhwd | xargs pacman -Rdd --noconfirm 2>/dev/null

# Change computer'"'"'s name if it'"'"'s manjaro
if [ -f /etc/hostname ]; then
	sed -i '"'"'/manjaro/c\Arch'"'"' /etc/hostname
	sed -i '"'"'/Manjaro/c\Arch'"'"' /etc/hostname
fi

sed -i '"'"'/manjaro/c\Arch'"'"' /etc/hosts
sed -i '"'"'/Manjaro/c\Arch'"'"' /etc/hosts

# linux-lts is generally more stable(especially for Intel graphics, uhd620 seems to have a black screen issue since 5.11)
printf "What kernel? Press 1 for linux-lts(more stable), 2 for normal linux.\n"
read -rn 1 whatkernel
case "$whatkernel" in
        "2") pacman -S linux linux-headers --noconfirm ;;
        *) pacman -S linux-lts linux-lts-headers --noconfirm ;;
esac

# Fück you nvidia
pacman -Qq | grep nvidia | xargs pacman -Rdd --noconfirm 2>/dev/null
if [ "$(lspci | grep -i nvidia)" ]; then
    pacman -S nvidia-dkms --noconfirm
fi

# Some wallpaper removal. I heard that it'"'"'s in budgie and xfce editions.
grepPacmanQuery illyria-wallpaper && pacman -Rdd illyria-wallpaper --noconfirm

# Delete line that hides GRUB. Manjaro devs, do you think that noobs don'"'"'t even know how to press enter?
sed -i '"'"'/GRUB_TIMEOUT_STYLE=hidden/d'"'"' /etc/default/grub

# Changes Manjaro GRUB theme. Manjaro doesn'"'"'t have an option to install systemd-boot, Right? I'"'"'m just assuming you have a clean install of Manjaro.
if ! [ "$(bootctl is-installed | grep -i yes)" ]; then
	curl -fLs https://github.com/AdisonCavani/distro-grub-themes/releases/latest/download/arch.tar -o /tmp/arch.tar
	[ -d /boot/grub/themes/archlinux ] && rm -rf /boot/grub/themes/archlinux
	mkdir /boot/grub/themes/archlinux
	tar -xf /tmp/arch.tar -C /boot/grub/themes/archlinux
	sed -i '"'"'/GRUB_THEME=/c GRUB_THEME="/boot/grub/themes/archlinux/theme.txt"'"'"' /etc/default/grub
	# Generate GRUB stuff
	[ -f /boot/grub/grub.cfg ] && rm /boot/grub/grub.cfg
	[ -f /boot/grub/grub.cfg.new ] && rm /boot/grub/grub.cfg.new
	grub-mkconfig -o /boot/grub/grub.cfg

else
    bootctl update
    printf "Systemd-boot users have to edit the updated the entries manually.\nYou'"'"'re on your own."
fi
# Locale fix
# It scared the daylights out of me when I realized gnome-terminal won'"'"'t start without this part
[ -f /etc/locale.conf.pacsave ] && \mv -f /etc/locale.conf.pacsave /etc/locale.conf
locale-gen



# Greeter bg remove (Doesn'"'"'t really work idk why)
if [ -f /etc/lightdm/unity-greeter.conf ]; then
	sed -i '"'"'/background/d'"'"' /etc/lightdm/unity-greeter.conf
	sed -i '"'"'/default-user-image/d'"'"' /etc/lightdm/unity-greeter.conf
fi

if [ -f /etc/lightdm/lightdm-gtk-greeter.conf ]; then
	sed -i '"'"'/background/d'"'"' /etc/lightdm/lightdm-gtk-greeter.conf
	sed -i '"'"'/default-user-image/d'"'"' /etc/lightdm/lightdm-gtk-greeter.conf
fi

# I know... sorry...
[ -f /etc/os-release ] && sed -i '"'"'s/Manjaro/Arch/g'"'"' /etc/os-release
[ -f /etc/os-release ] && sed -i '"'"'s/ID=manjaro/ID=arch/g'"'"' /etc/os-release
[ -f /etc/os-release ] && sed -i '"'"'s/ANSI_COLOR="32;1;24;144;200"/ANSI_COLOR="38;2;23;147;209"/g'"'"' /etc/os-release
[ -f /etc/os-release ] && sed -i '"'"'s/manjaro/archlinux/g'"'"' /etc/os-release
[ -f /etc/os-release ] && sed -i '"'"'s/manjarolinuxlinux/archlinux/g'"'"' /etc/os-release
[ -f /etc/os-release ] && sed -i '"'"'s/archlinuxlinux/archlinux-logo/g'"'"' /etc/os-release


[ -f /etc/issue ] && sed -i '"'"'s/Manjaro/Arch/g'"'"' /etc/issue

# Screenfetch takes an eternity to run in VMs. I have no damn idea why.
neofetch
printf "Now it'"'"'s Arch! Enjoy!\n"
printf "There could be some leftover Manjaro backgrounds and themes/settings,\nso you might have to tweak your desktop environment a bit.\n"

if grepPacmanQuery deepin-desktop-base; then
	printf "When you reboot, the theme will be changed to stock white but the font won'"'"'t,\nso change it to dark again and it'"'"'ll be fixed..\n"
	printf "And especially on VMs after login everything will be white.\nBlindly press on the middle of the screen and you'"'"'ll be logged in.\n"
fi

if systemctl list-unit-files | grep enabled | grep -q sddm; then
	printf "You seem to run SDDM.\nMake sure you change the SDDM theme to something else like breeze because the default theme looks horrible!\n"
fi



if [ -f /etc/lightdm/slick-greeter.conf ]; then
	sed -i '"'"'/background/d'"'"' /etc/lightdm/slick-greeter.conf
	sed -i '"'"'/default-user-image/d'"'"' /etc/lightdm/slick-greeter.conf
fi

if grepPacmanQuery gnome; then
	pacman -Qq | grep gnome-layout-switcher | xargs pacman -Rdd --noconfirm
fi

# if grepPacmanQuery sway; then
# 	pacman -S dmenu --noconfirm
# fi

# This file is known to exist in the gnome edition, but somehow vanishes after reboot.
# Still let'"'"'s change it.
if [ -f /etc/arch-release ]; then
	sed -i '"'"'/Manjaro/c\Arch'"'"' /etc/arch-release
fi



[ -f /.manjaro-tools ] && rm -f /.manjaro-tools
[ -d /var/lib/pacman-mirrors ] && rm -rf /var/lib/pacman-mirrors
' 2>/dev/null # 2>/dev/null is for error redirection.

## User-wide jobs. Some important cleanup jobs, especially for sway. Makes script more seamless.
# KDE Plasma theme switch to default (user mode)
if pacman -Qq | grep -q plasma-desktop; then
	/usr/lib/plasma-changeicons breeze-dark 2>/dev/null
	lookandfeeltool --apply "org.kde.breezedark.desktop" 2>/dev/null
fi

# # Deletes sway config cuz sway edition saves its configs in a packages and sway gets borked after deleteing those.
# # And yes sway will look like plain i3.
# if pacman -Qq | grep -q sway; then
# 	workdir="$(pwd)"
# 	rm -rf ~/.config/sway
# 	mkdir ~/.config/sway
# 	cd ~/.config/sway
# 	curl -o config -fLs https://raw.githubusercontent.com/swaywm/sway/master/config.in
# 	sed -i '/alacritty/c\foot' ~/.config/sway/config
# 	sed -i '/Wallpaper/d' ~/.config/sway/config
# 	cd "${workdir}"
# 	# # I know this part is extremely hacky and weird, but chsh doesn't change foots shell.
# 	#echo "clear;exec bash" >> ~/.zshrc
# fi
# # Some i3 MaNjArO removal.
# if pacman -Qq | grep -q i3; then
# 	sed -i '/nitrogen/d' ~/.i3/config 2>/dev/null
# fi
# There lurks a disgusting application residue in you ~/.config...
# The dreaded name of the package is matray, and it literally sprays your screen with Manjaro news and ads.
# It is seen in the KDE edition.
# [ -d $HOME/.config/matray ] && rm -rf ~/.config/matray
# Reboot if you want.
printf "Would you like to reboot? Make sure you have read the above carefully! (y/N)"
}



# echo $EUID is also possible, but that method is useless in sudo.
if [ "$(id -u)" == "0" ]; then
	printf "This script should not be run as root.\nPermissions will be elevated automatically for system-wide tasks.\n"
	exit 1
fi
# Bash runs commands on sync but parallelly, so this exits every subshell already running in the shell if running as root.
[ $? == 1 ] && exit 1;



DISTRO=$(
printf "This script comes with ABSOLUTELY NO WARRANTY!\nTHIS CAN EVEN BREAK YOUR SYSTEM AND YOU HAVE DECIDED TO RUN IT!\n" 1>&2
printf "What distro? Press 1 if you run Manjaro, 2 if you run EndeavourOS.\n" 1>&2
read -rn 1 whatdistro
case "$whatdistro" in
        "1") echo MANJARNO ;;
        *) echo ENDEAVOUROS ;;
esac
read -rp "==>Press Enter to continue" 1>&2
)

if [ "${DISTRO}" == "MANJARNO" ]; then
    CONVERTER_MANJARNO
else
    CONVERTER_ENDEAVOUROS
fi


# Sometimes the script gives out a non-0 exit code even when there are no errors.
[ $? != 0 ] && exit 0;
