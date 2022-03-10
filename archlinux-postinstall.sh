#!/bin/bash
################################################################################
#
# Author  : David Calvert
# Purpose : Arch Linux custom post-installer
# GitHub  : https://github.com/dotdc/archlinux-installer
#
################################################################################

set -e

################################################################################
# Source variables
################################################################################

. config-variables.sh

################################################################################
# Post-install
################################################################################

# Install all packages
echo -e "[${B}INFO${W}] Install ${Y}pacman${W} packages"
pacman -Sy --color auto $(tr '\n' ' ' < /opt/config-pacman-packages.txt)

# Configuration
echo -e "[${B}INFO${W}] Configure system localization"
ln -sf /usr/share/zoneinfo/"${timezone}" /etc/localtime
hwclock --systohc
sed -i "s|^#${locale}.UTF-8|${locale}.UTF-8|" /etc/locale.gen
locale-gen
echo "LANG=${locale}.UTF-8" > /etc/locale.conf
echo "KEYMAP=${keymap}" > /etc/vconsole.conf
echo "${hostname}" > /etc/hostname

# Configure Keymap for GDM
mkdir -p /etc/X11/xorg.conf.d
echo -e "Section \"InputClass\"
    Identifier \"system-keyboard\"
    MatchIsKeyboard \"on\"
    Option \"XkbLayout\" \"${keymap}\"
EndSection" > /etc/X11/xorg.conf.d/00-keyboard.conf


# Configure mkinitcpio hooks
# https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#LVM_on_LUKS
echo -e "[${B}INFO${W}] Generate mkinitcpio hooks"
mkinitcpio_hooks="base udev autodetect keyboard keymap modconf block encrypt lvm2 filesystems keyboard fsck"
sed -i "s|^HOOKS=(.*)|HOOKS=(${mkinitcpio_hooks})|" /etc/mkinitcpio.conf
mkinitcpio -P

# Create user
echo -e "[${B}INFO${W}] Generate user & password"
useradd -m -G wheel -s /bin/bash "${username}"
echo -e "${username} ALL=(ALL) ALL" > /etc/sudoers.d/${username}

# Change password for root & ${username}
echo -e "Change password for user ${Y}root${W} :"
passwd root
echo -e "Change password for user ${Y}${username}${W} :"
passwd "${username}"

# Install bootloader and all necessary packages
# https://wiki.archlinux.org/title/Systemd-boot
echo -e "[${B}INFO${W}] Install & configure bootloader"
bootctl install

echo "default arch
timeout 1" > /boot/loader/loader.conf

uuid="$(blkid -s UUID -o value ${luks_partition})"

echo -e "title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options cryptdevice=UUID=${uuid}:cryptlvm root=/dev/mapper/SYSTEM-root rw" > /boot/loader/entries/arch.conf

mkdir -p /etc/pacman.d/hooks

echo "
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Updating systemd-boot
When = PostTransaction
Exec = /usr/bin/bootctl update" > /etc/pacman.d/hooks/100-systemd-boot.hook

# Install yay
echo -e "[${B}INFO${W}] Install ${Y}yay${W}"
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
chown -R ${username}: .
sudo -u ${username} makepkg -si

# Install AUR Packages
echo -e "[${B}INFO${W}] Install ${Y}AUR${W} packages"
sudo -u ${username} yay -Sy --color auto $(tr '\n' ' ' < /opt/config-aur-packages.txt)

# Start services
echo -e "[${B}INFO${W}] Enable systemctl services"
systemctl enable gdm
systemctl enable NetworkManager
systemctl enable nftables
systemctl enable docker
systemctl enable cups

# Set Gnome default favorites apps
mkdir -p /etc/dconf/profile
mkdir -p /etc/dconf/db/local.d
echo -e "user-db:user
system-db:local" > /etc/dconf/profile/user
echo -e "# Set Gnome default favorites apps
# To find apps:
# find / -iname \"*desktop\" -type f -not -path \"/media*\" 2> /dev/null
[org/gnome/shell]
favorite-apps = ${favorite_apps}
" > /etc/dconf/db/local.d/00-favorite-apps
dconf update

# Install dotfiles for user
mkdir -p /home/${username}/Documents/workspace/repos/
cd /home/${username}/Documents/workspace/repos/
git clone https://github.com/dotdc/dotfiles
cd dotfiles
su ${username} -c "make all"
chown -R ${username}: /home/${username}

# Reboot
echo -e "[${B}INFO${W}] Post-install complete!"
echo -e "[${B}INFO${W}] Type ${Y}CTRL+D${W} and ${Y}reboot${W} to reboot in Arch!"