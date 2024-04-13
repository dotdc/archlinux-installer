#!/bin/bash
################################################################################
#
# Author  : David Calvert
# Purpose : Arch Linux custom installer
# GitHub  : https://github.com/dotdc/archlinux-installer
#
################################################################################

set -e

################################################################################
# Source variables
################################################################################

. config-variables.sh

################################################################################
# Preparation
################################################################################

# Arch logo from : https://wiki.archlinux.org/title/ASCII_art
# Text generated with : https://textkool.com/en/ascii-art-generator?font=Big&text=Arch%20Installer
echo -e "${B}
                    -@
                   .##@
                  .####@
                  @#####@
                . *######@            ${W}                    _       _____           _        _ _            ${B}
               .##@o@#####@           ${W}     /\            | |     |_   _|         | |      | | |           ${B}
              /############@          ${W}    /  \   _ __ ___| |__     | |  _ __  ___| |_ __ _| | | ___ _ __  ${B}
             /##############@         ${W}   / /\ \ | '__/ __| '_ \    | | | '_ \/ __| __/ _\` | | |/ _ \ '__|${B}
            @######@**%######@        ${W}  / ____ \| | | (__| | | |  _| |_| | | \__ \ || (_| | | |  __/ |    ${B}
           @######\`     %#####o      ${W}  /_/    \_\_|  \___|_| |_| |_____|_| |_|___/\__\__,_|_|_|\___|_|   ${B}
          @######@       ######%
        -@#######h       ######@.\`
       /#####h**\`\`       \`**%@####@
      @H@*\`                    \`*%#@
     *\`                            \`* ${W}"

loadkeys fr
timedatectl set-ntp true

# Disk partition
echo -e "[${B}INFO${W}] Select destination disk for Arch Linux"
echo "Disk(s) available:"
parted -l | awk '/Disk \//{ gsub(":","") ; print "- \033[93m"$2"\033[0m",$3}' | column -t
read -r -p "Please enter destination disk: " system_disk

echo -e "Disk ${Y}${system_disk}${W} will be ${R}ERASED${W} !"
read -r -p "Are you sure you want to proceed? (y/n)" system_disk_format

if [[ "${system_disk_format}" != "y" ]] ; then
    echo "Installation aborted!"
    exit 0
fi

# CREATE PARTED GUID + PARTITIONS
echo -e "[${B}INFO${W}] Format ${Y}${system_disk}${W} and create partitions"
parted "${system_disk}" mklabel gpt
parted "${system_disk}" mkpart "EFI" fat32 1MiB 301MiB
parted "${system_disk}" set 1 esp on
parted "${system_disk}" mkpart "LUKS-SYSTEM" ext4 301MiB 100%

# Guess partition names
if [[ "${system_disk}" =~ "/dev/sd" ]] ; then
  efi_partition="${system_disk}1"
  luks_partition="${system_disk}2"
else
  efi_partition="${system_disk}p1"
  luks_partition="${system_disk}p2"
fi

# LUKS configuration
echo -e "[${B}INFO${W}] Create luks partition on ${Y}${luks_partition}${W}"
cryptsetup luksFormat "${luks_partition}"
echo -e "[${B}INFO${W}] Mount the luks partition as ${Y}cryptlvm${W}"
cryptsetup open "${luks_partition}" cryptlvm

# Create PV/VG
echo -e "[${B}INFO${W}] Create LVM Physical Volume"
pvcreate /dev/mapper/cryptlvm
echo -e "[${B}INFO${W}] Create LVM Volume Group"
vgcreate SYSTEM /dev/mapper/cryptlvm

# Create LVs
echo -e "[${B}INFO${W}] Create LVM Logical Volumes"
lvcreate -L "${lv_swap_size}" SYSTEM -n swap
lvcreate -L "${lv_root_size}" SYSTEM -n root
[[ "${create_home_fs}" == "true" ]] && lvcreate -l "${lv_home_size}" SYSTEM -n home

# Format LVs
echo -e "[${B}INFO${W}] Format LVM Logical Volumes"
mkswap /dev/SYSTEM/swap
mkfs.ext4 /dev/SYSTEM/root
[[ "${create_home_fs}" == "true" ]] && mkfs.ext4 /dev/SYSTEM/home

# Mount LVs
echo -e "[${B}INFO${W}] Mount LVM Logical Volumes"
mount /dev/SYSTEM/root /mnt
[[ "${create_home_fs}" == "true" ]] && mkdir /mnt/home
[[ "${create_home_fs}" == "true" ]] && mount /dev/SYSTEM/home /mnt/home

# Mount EFI
echo -e "[${B}INFO${W}] Mount EFI Partition"
mkdir /mnt/boot
mkfs.fat -F 32 "${efi_partition}"
mount "${efi_partition}" /mnt/boot

# Mount swap
swapon /dev/SYSTEM/swap

# Install Arch
echo -e "[${B}INFO${W}] Install Arch Linux"
pacstrap /mnt --color auto base base-devel linux linux-firmware intel-ucode efibootmgr lvm2

# Generate fstab
echo -e "[${B}INFO${W}] Generate fstab"
genfstab -U /mnt >> /mnt/etc/fstab

# Copy postinstall files to /mnt chroot
echo -e "[${B}INFO${W}] Copy installation material for post-install"
cp -v archlinux-postinstall.sh /mnt/opt
cp -v archlinux-postinstall-desktop.sh /mnt/opt
cp -v config-variables.sh /mnt/opt

echo -e "\nluks_partition=\"${luks_partition}\"" >> /mnt/opt/config-variables.sh

echo -e "[${B}INFO${W}] Installation complete!"
echo -e "[${B}INFO${W}] Please run ${Y}arch-chroot /mnt${W}, ${Y}cd /opt${W} and ${Y}./archlinux-postinstall.sh${W} to continue"