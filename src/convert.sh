pacman -Syy neofetch --noconfirm
neofetch
printf "This is your current distro state.\n"
if [ "$(pacman -Qq | grep pamac)" ]; then
	pacman -Qq | grep pamac | xargs pacman -Rdd --noconfirm
fi

if [ "$(pacman -Qq | grep manjaro-application-utility)" ]; then
	yes | pacman -Rcnsdd manjaro-application-utility --noconfirm
fi

if [ "$(pacman -Qq | grep matray)" ]; then
	yes | pacman -Rsdd matray --noconfirm
fi

if [ "$(pacman -Qq | grep manjaro-release)" ]; then
	yes | pacman -Rsdd manjaro-release
fi

if [ "$(pacman -Qq | grep bashrc-manjaro)" ]; then
	yes | pacman -Rsdd bashrc-manjaro
fi

if [ "$(pacman -Qq | grep manjaro-keyring)" ]; then
	yes | pacman -Rsdd manjaro-keyring
fi

#Some more seamless stuff
p_w_d="$(directory)"

cd /etc/pacman.d
rm mirrorlist
#Get mirrorlist
curl -o mirrorlist -sL 'https://archlinux.org/mirrorlist/?country=all&protocol=http&protocol=https&ip_version=4&ip_version=6'

if [ -f /etc/pacman.d/mirrorlist.pacnew ]; then
	rm /etc/pacman.d/mirrorlist.pacnew
fi

if [ -f /etc/pacman.conf.pacnew ]; then
	mv /etc/pacman.conf.pacnew /etc/pacman.conf
fi

#Delete crappy unrecognized pacman option by manjaro
sed -i '/SyncFirst/d' /etc/pacman.conf
sed -i '/HoldPkg/d' /etc/pacman.conf

printf "==> Uncomment mirrors from your country.\n"
${EDITOR} /etc/pacman.d/mirrorlist

#backup just in case
cp /etc/pacman.d/mirrorlist /tmp/mirrorlist

cd "${directory}"
#I have seen pacui and bmenu in some editions as a dependency
#I have go goddamn idea why this shows up in cat
if [ "$(pacman -Qq pacui)" ]; then
	pacman -Qq | grep pacui | xargs pacman -Rdd --noconfirm
fi

if [ "$(pacman -Qq bmenu)" ]; then
	pacman -Qq | grep bmenu | xargs pacman -Rdd --noconfirm
fi

if [ "$(pacman -Qq pacman-mirrors)" ]; then
	pacman -Qq | grep pacman-mirrors | xargs pacman -Rdd --noconfirm
fi

#Get pacman and mirrorlist and lsb_release from website, not mirrors
pacman -U https://www.archlinux.org/packages/core/x86_64/pacman/download/ https://www.archlinux.org/packages/core/any/pacman-mirrorlist/download/ https://www.archlinux.org/packages/community/any/lsb-release/download/ --noconfirm

\mv -f /tmp/mirrorlist /etc/pacman.d/mirrorlist
#Do it again, because conf gets resetted
sed -i '/SyncFirst/d' /etc/pacman.conf

if [ -d /sys/firmware/efi ]; then
	#Deletes the Manjaro UEFI entry. Very dangerous operation if misused, but I tested this multiple times and it was good.
	efibootmgr -b "$(efibootmgr | grep Manjaro | sed 's/*//' | cut -f 1 -d' ' | sed 's/Boot//')" -B
fi

#Change grub
sed -i '/GRUB_DISTRIBUTOR="Manjaro"/c\GRUB_DISTRIBUTOR="Arch"' /etc/default/grub

# following line enables multilib repository
sed -ie 's/#\(\[multilib\]\)/\1/;/\[multilib\]/,/^$/{//!s/^#//;}' /etc/pacman.conf

#Prevent HoldPkg error
sed -i '/HoldPkg/d' /etc/pacman.conf
#purge manjaro's software
pacman -Qq | grep manjaro | xargs pacman -Rdd --noconfirm
#KDE Plasma
pacman -Qq | grep breath | xargs pacman -Rdd --noconfirm

#This should be in front of -Syu to avoid manjaro's linux kernel from updating
pacman -Qq | grep linux[0-9] | xargs pacman -Rdd --noconfirm

#-Syyyyyyyyyyuuuuuuuu calms me down
yes | pacman -Syyuu bash

#As Linus Torvalds said
pacman -Qq | grep mhwd | xargs pacman -Rdd --noconfirm

#Change computer's name if it's manjaro
if [ -f /etc/hostname ]; then
	sed -i '/manjaro/c\Arch' /etc/hostname
	sed -i '/Manjaro/c\Arch' /etc/hostname
fi
sed -i '/manjaro/c\Arch' /etc/hosts
sed -i '/Manjaro/c\Arch' /etc/hosts

#linux-lts is generally more stable(especially for intel graphics, uhd620 seems to have a black screen issue since 5.11)
pacman -S linux-lts linux-lts-headers --noconfirm


#Fück you nvidia
if [ "$(lspci | grep -i nvidia)" ]; then
	pacman -Qq | grep nvidia | xargs pacman -Rdd --noconfirm
	pacman -S nvidia --noconfirm
fi
#Delete line that hides grub. Manjaro devs, do you think that noobs don't even know how to press enter?
sed -i '/GRUB_TIMEOUT_STYLE=hidden/d' /etc/default/grub

#Changes Manjaro grub theme. Manjaro doesn't have an option to install systemd-boot, Right? I'm just assuming you have a clean install of Manjaro.
curl -fLOs https://github.com/AdisonCavani/distro-grub-themes/releases/download/2.1/ArchLinux.tar

if ! [ -d /boot/grub/themes/archlinux ]; then
	mkdir /boot/grub/themes/archlinux
else
	rm -rf /boot/grub/themes/archlinux
	mkdir /boot/grub/themes/archlinux
fi

tar -xf ArchLinux.tar -C /boot/grub/themes/archlinux
sed -i '/GRUB_THEME=/c GRUB_THEME="/boot/grub/themes/archlinux/theme.txt"' /etc/default/grub

#Generate grub stuff
grub-mkconfig -o /boot/grub/grub.cfg
if [ -d /sys/firmware/efi ]; then
	grub-install
fi

#Locale fix
#It scared the daylights out of me when I realized gnome-terminal won't start without this part
if [ -f /etc/locale.conf.pacsave ]; then
	\mv -f /etc/locale.conf.pacsave /etc/locale.conf
fi
locale-gen


#Deletes Manjaro-Sway repo
if [ "$(pacman -Qq | grep sway)" ]; then
	sed -ie '/[manjaro-sway]/,+2d' /etc/pacman.conf
fi

#Greeter bg remove(Doesn't really work idk why)
if [ -f /etc/lightdm/unity-greeter.conf ]; then
	sed -i '/background/d' /etc/lightdm/unity-greeter.conf
	sed -i '/default-user-image/d' /etc/lightdm/unity-greeter.conf
fi

if [ -f /etc/lightdm/lightdm-gtk-greeter.conf ]; then
	sed -i '/background/d' /etc/lightdm/lightdm-gtk-greeter.conf
	sed -i '/default-user-image/d' /etc/lightdm/lightdm-gtk-greeter.conf
fi

#Screenfetch takes an eternity to run in VMs. I have no damn idea why.
neofetch
printf "Now it\'s Arch! Enjoy!\n"
printf "There could be some leftover Manjaro backgrounds and themes/settings(especially lightdm),\nso you might have to tweak your desktop environment a bit.\n"
if [ "$(pacman -Qq | grep deepin-desktop-base)" ]; then
	printf "When you reboot, the theme will be changed to stock white but the font won\'t,\nso change it to dark again and it\'ll be fixed..\nAnd especially on VMs after login everything will be white.\nBlindly press on the middle of the screen and you\'ll be logged in.\n"
fi
if [ "$(systemctl list-unit-files | grep enabled | grep sddm)" ]; then
	printf "You seem to run SDDM.\nMake sure you change the SDDM theme to something else like breeze because the default theme looks horrible!"
fi

if [ "$(pacman -Qq | grep i3)" ]; then
	pacman -S i3status i3blocks --noconfirm
fi

if [ "$(pacman -Qq | grep gnome)" ]; then
	pacman -Qq | grep gnome-layout-switcher | xargs pacman -Rdd --noconfirm
fi

if [ -f /etc/arch-release ]; then
	sed -i '/Manjaro/c\Arch' /etc/arch-release
fi
