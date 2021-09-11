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



grepPacmanQuery pamac && pacman -Qq | grep pamac | xargs pacman -Rdd --noconfirm
grepPacmanQuery manjaro-application-utility && pacman -Rcnsdd manjaro-application-utility
removeIfMatched matray
removeIfMatched manjaro-release
removeIfMatched bashrc-manjaro
removeIfMatched manjaro-keyring

(
	cd /etc/pacman.d
	rm mirrorlist
	# Get mirrorlist
	curl -o mirrorlist -sL 'https://archlinux.org/mirrorlist/?country=all&protocol=http&protocol=https&ip_version=4&ip_version=6'

	[ -f /etc/pacman.d/mirrorlist.pacnew ] && rm /etc/pacman.d/mirrorlist.pacnew
	[ -f /etc/pacman.conf.pacnew ] && rm /etc/pacman.conf.pacnew
	
	# Delete crappy unrecognized pacman option by Manjaro
	sed -i '/SyncFirst/d' /etc/pacman.conf
	sed -i '/HoldPkg/d' /etc/pacman.conf
	
	# Use $VISUAL instead?
	printf "==> Uncomment mirrors from your country.\nPress 1 for Nano, 2 for vim, or any other key for your default \$EDITOR.\n"
	read -rn 1 whateditor
	case "$whateditor" in
		"1") nano /etc/pacman.d/mirrorlist ;;
		"2") vim /etc/pacman.d/mirrorlsit ;;
		*) $EDITOR /etc/pacman.d/mirrorlist ;;
	esac
	
	# Backup just in case
	cp /etc/pacman.d/mirrorlist "${tmp_dir}/mirrorlist"
)

# I have seen pacui and bmenu in some editions as a dependency
# I have go goddamn idea why this shows up in cat
grepPacmanQuery pacui && pacman -Qq | grep pacui | xargs pacman -Rdd --noconfirm
pacman -Qq pacui &>/dev/null && pacman -Qq | grep pacui | xargs pacman -Rdd --noconfirm
pacman -Qq bmenu &>/dev/null && pacman -Qq | grep bmenu | xargs pacman -Rdd --noconfirm
pacman -Qq pacman-mirrors &>/dev/null && pacman -Qq | grep pacman-mirrors | xargs pacman -Rdd --noconfirm

# Get pacman, mirrorlist and lsb_release from website, not mirrors
pacman -U https://www.archlinux.org/packages/core/x86_64/pacman/download/ https://www.archlinux.org/packages/core/any/pacman-mirrorlist/download/ https://www.archlinux.org/packages/community/any/lsb-release/download/ --noconfirm

\mv -f "${tmp_dir}/mirrorlist" /etc/pacman.d/mirrorlist
# Do it again, because conf gets reset
sed -i '/SyncFirst/d' /etc/pacman.conf



# Change grub
sed -i '/GRUB_DISTRIBUTOR="Manjaro"/c\GRUB_DISTRIBUTOR="Arch"' /etc/default/grub

# Following line enables multilib repository
sed -ie 's/#\(\[multilib\]\)/\1/;/\[multilib\]/,/^$/{//!s/^#//;}' /etc/pacman.conf

# Prevent HoldPkg error
sed -i '/HoldPkg/d' /etc/pacman.conf
# Purge Manjaro's software
pacman -Qq | grep manjaro | xargs pacman -Rdd --noconfirm
# KDE Plasma
pacman -Qq | grep breath | xargs pacman -Rdd --noconfirm

# This should be in front of -Syu to avoid manjaro's linux kernel from updating
pacman -Qq | grep 'linux[0-9]' | xargs pacman -Rdd --noconfirm

# -Syyyyyyyyyyuuuuuuuu calms me down
pacman -Syyuu bash --noconfirm

# As Linus Torvalds said
pacman -Qq | grep mhwd | xargs pacman -Rdd --noconfirm

# Change computer's name if it's manjaro
if [ -f /etc/hostname ]; then
	sed -i '/manjaro/c\Arch' /etc/hostname
	sed -i '/Manjaro/c\Arch' /etc/hostname
fi

sed -i '/manjaro/c\Arch' /etc/hosts
sed -i '/Manjaro/c\Arch' /etc/hosts


	pacman -S nvidia --noconfirm
fi

# Delete line that hides GRUB. Manjaro devs, do you think that noobs don't even know how to press enter?
sed -i '/GRUB_TIMEOUT_STYLE=hidden/d' /etc/default/grub

# Changes Manjaro GRUB theme. Manjaro doesn't have an option to install systemd-boot, Right? I'm just assuming you have a clean install of Manjaro.
curl -fLOs https://github.com/AdisonCavani/distro-grub-themes/releases/download/2.1/ArchLinux.tar

[ -d /boot/grub/themes/archlinux ] && rm -rf /boot/grub/themes/archlinux
mkdir /boot/grub/themes/archlinux

tar -xf ArchLinux.tar -C /boot/grub/themes/archlinux
sed -i '/GRUB_THEME=/c GRUB_THEME="/boot/grub/themes/archlinux/theme.txt"' /etc/default/grub

# Generate GRUB stuff
grub-mkconfig -o /boot/grub/grub.cfg
[ -d /sys/firmware/efi ] && grub-install

# Locale fix
# It scared the daylights out of me when I realized gnome-terminal won't start without this part
[ -f /etc/locale.conf.pacsave ] && \mv -f /etc/locale.conf.pacsave /etc/locale.conf
locale-gen


# Deletes Manjaro-Sway repo
grepPacmanQuery sway && sed -ie '/[manjaro-sway]/,+2d' /etc/pacman.conf

# Greeter bg remove (Doesn't really work idk why)
if [ -f /etc/lightdm/unity-greeter.conf ]; then
	sed -i '/background/d' /etc/lightdm/unity-greeter.conf
	sed -i '/default-user-image/d' /etc/lightdm/unity-greeter.conf
fi

if [ -f /etc/lightdm/lightdm-gtk-greeter.conf ]; then
	sed -i '/background/d' /etc/lightdm/lightdm-gtk-greeter.conf
	sed -i '/default-user-image/d' /etc/lightdm/lightdm-gtk-greeter.conf
fi

# Screenfetch takes an eternity to run in VMs. I have no damn idea why.
neofetch
printf "Now it's Arch! Enjoy!\n"
printf "There could be some leftover Manjaro backgrounds and themes/settings(especially lightdm),\nso you might have to tweak your desktop environment a bit.\n"

if grepPacmanQuery deepin-desktop-base; then
	printf "When you reboot, the theme will be changed to stock white but the font won't,\nso change it to dark again and it'll be fixed..\n"
	printf "And especially on VMs after login everything will be white.\nBlindly press on the middle of the screen and you'll be logged in.\n"
fi

if systemctl list-unit-files | grep enabled | grep -q sddm; then
	printf "You seem to run SDDM.\nMake sure you change the SDDM theme to something else like breeze because the default theme looks horrible!\n"
fi

if grepPacmanQuery i3; then
	pacman -S i3status i3blocks --noconfirm
fi

if grepPacmanQuery gnome; then
	pacman -Qq | grep gnome-layout-switcher | xargs pacman -Rdd --noconfirm
fi

if [ -f /etc/arch-release ]; then
	sed -i '/Manjaro/c\Arch' /etc/arch-release
fi
