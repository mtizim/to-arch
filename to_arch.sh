#!/usr/bin/env bash
cat >/tmp/convert.sh <<EOF
pacman -Qq | grep pamac | xargs pacman -Rs --noconfirm manjaro-application-utility
pacman -R matray --noconfirm
pacman -Rdd manjaro-release bashrc-manjaro manjaro-keyring
pacman -U https://www.archlinux.org/packages/core/x86_64/pacman/download/ https://www.archlinux.org/packages/core/any/pacman-mirrorlist/download/ https://www.archlinux.org/packages/community/any/lsb-release/download/
mv /etc/pacman.d/mirrorlist.pacnew /etc/pacman.d/mirrorlist
mv /etc/pacman.conf.pacnew /etc/pacman.conf
#Deletes the Manjaro boot menu
efibootmgr -b "$(efibootmgr | grep Manjaro | sed 's/*//' | cut -f 1 -d' ' | sed 's/Boot//')" -B
sed -i '/GRUB_DISTRIBUTOR="Manjaro"/c\GRUB_DISTRIBUTOR="Arch"' /etc/default/grub
# following line enables multilib repository
sed -ie 's/#\(\[multilib\]\)/\1/;/\[multilib\]/,/^$/{//!s/^#//;}' /etc/pacman.conf
read -p "Uncomment mirrors from your country (press any key to continue)"
$EDITOR /etc/pacman.d/mirrorlist
pacman -Qq | grep manjaro | xargs pacman -R --noconfirm
pacman -Syyuu
pacman -S bash
pacman -Qq | grep linux | grep MANJARO | xargs pacman -R --noconfirm
pacman -S linux-lts
mkinitcpio -P
grub-mkconfig -o /boot/grub/grub.cfg
grub-install
EOF
chmod +x /tmp/convert.sh
sudo /tmp/convert.sh
rm /tmp/convert.sh