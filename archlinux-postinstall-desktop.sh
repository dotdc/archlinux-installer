#!/bin/bash
################################################################################
#
# Author  : David Calvert
# Purpose : Arch Linux custom desktop post-installer
# GitHub  : https://github.com/dotdc/archlinux-installer
#
################################################################################

set -e

################################################################################
# Source variables
################################################################################

. config-variables.sh

################################################################################
# Desktop Post-install
################################################################################

# Configure Keymap for GDM (desktop only)
mkdir -p /etc/X11/xorg.conf.d
echo -e "Section \"InputClass\"
    Identifier \"system-keyboard\"
    MatchIsKeyboard \"on\"
    Option \"XkbLayout\" \"${keymap}\"
EndSection" > /etc/X11/xorg.conf.d/00-keyboard.conf

# Install all packages
echo -e "[${B}INFO${W}] Install desktop ${Y}pacman${W} packages"
pacman -Sy --color auto "${desktop_packages[@]}"

# Install yay
echo -e "[${B}INFO${W}] Install ${Y}yay${W}"
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
chown -R ${username}: .
sudo -u ${username} makepkg -si

# Install AUR Packages
echo -e "[${B}INFO${W}] Install ${Y}AUR${W} packages"
sudo -u ${username} yay -Sy --color auto "${aur_packages[@]}"

# Start services
echo -e "[${B}INFO${W}] Enable systemctl services"
systemctl enable gdm
systemctl enable NetworkManager
systemctl enable bluetooth
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
